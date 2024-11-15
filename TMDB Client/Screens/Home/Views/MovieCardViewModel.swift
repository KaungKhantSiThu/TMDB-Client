import SwiftUI
import Foundation
import Combine


class MovieCardViewModel: ObservableObject {
    private let movie: Movie
    let imageLoader: ImageLoading
    private let favoriteManager: MoviesFavorites
    
    @Published private(set) var isFavorite: Bool = false
    
    var title: String { movie.title }
    var posterPath: URL? { movie.posterPath }
    var rating: Double? { movie.voteAverage }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        movie: Movie,
        imageLoader: ImageLoading,
        favoriteManager: MoviesFavorites
    ) {
        self.movie = movie
        self.imageLoader = imageLoader
        self.favoriteManager = favoriteManager
    }
    
    func checkFavoriteStatus() {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let isFavorite = try await self.favoriteManager.isFavorite(movieId: self.movie.id)
                    promise(.success(isFavorite))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    // TODO: Proper error handling
                }
            },
            receiveValue: { [weak self] isFavorite in
                self?.isFavorite = isFavorite
            }
        )
        .store(in: &cancellables)
    }
} 
