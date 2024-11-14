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
        
        Task {
            do {
                async let popularMovies = moviesFetcher.fetchMovies(page: 1, category: .popular)
                async let upcomingMovies = moviesFetcher.fetchMovies(page: 1, category: .upcoming)
                
                let sections = [
                    (title: "Popular", movies: try await popularMovies),
                    (title: "Upcoming", movies: try await upcomingMovies)
                ]
                
                state = .loaded(sections)
            } catch {
                state = .failed(error)
            }
        }
    }
    
    func toggleFavorite(for movieId: Movie.ID) async throws {
        try await favoriteManager.toggleFavorite(for: movieId)
        logger.info("Toggled favorite status for movie \(movieId)")
    }
}
