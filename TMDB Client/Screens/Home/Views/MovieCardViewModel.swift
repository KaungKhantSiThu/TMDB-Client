import SwiftUI
import Foundation


class MovieCardViewModel: ObservableObject {
    private let movie: Movie
    let imageLoader: ImageLoading
    private let favoriteManager: MoviesFavorites
    
    @Published private(set) var isFavorite: Bool = false
    
    var title: String { movie.title }
    var posterPath: URL? { movie.posterPath }
    var rating: Double? { movie.voteAverage }
    
    init(
        movie: Movie,
        imageLoader: ImageLoading,
        favoriteManager: MoviesFavorites
    ) {
        self.movie = movie
        self.imageLoader = imageLoader
        self.favoriteManager = favoriteManager
    }
    
    @MainActor
    func checkFavoriteStatus() async {
        do {
            isFavorite = try await favoriteManager.isFavorite(movieId: movie.id)
        } catch {
            print(error.localizedDescription)
            // TODO: Proper error handling
        }
    }
} 
