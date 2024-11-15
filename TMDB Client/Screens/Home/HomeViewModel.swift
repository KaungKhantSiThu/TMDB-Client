//
//  HomeViewModel.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//


import Combine
import OSLog


class HomeViewModel: LoadableObject {
    private let moviesFetcher: MoviesFetching
    private let favoriteManager: MoviesFavorites
    private let logger: Logger
    
    @Published private(set) var state: LoadingState<[(title: String, movies: [Movie])]> = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        moviesFetcher: MoviesFetching,
        favoriteManager: MoviesFavorites,
        logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HomeScreen")
    ) {
        self.moviesFetcher = moviesFetcher
        self.favoriteManager = favoriteManager
        self.logger = logger
    }
    
    @MainActor
    func load() {
        state = .loading
        
        Future<[(title: String, movies: [Movie])], Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    async let popularMovies = self.moviesFetcher.fetchMovies(page: 1, category: .popular)
                    async let upcomingMovies = self.moviesFetcher.fetchMovies(page: 1, category: .upcoming)
                    
                    let sections = [
                        (title: "Popular", movies: try await popularMovies),
                        (title: "Upcoming", movies: try await upcomingMovies)
                    ]
                    promise(.success(sections))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .failed(error)
                }
            },
            receiveValue: { [weak self] sections in
                self?.state = .loaded(sections)
            }
        )
        .store(in: &cancellables)
    }
    
    func toggleFavorite(for movieId: Movie.ID) {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    try await self.favoriteManager.toggleFavorite(for: movieId)
                    self.logger.info("Toggled favorite status for movie \(movieId)")
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error toggling favorite: \(error)")
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)
    }
}
