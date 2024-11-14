import Foundation
import OSLog

actor OfflineFirstMoviesManager: MoviesManager {
    private let remote: MoviesFetching
    private let storage: MoviesStorage
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoviesManager")
    
    init(remote: MoviesFetching, storage: MoviesStorage) {
        self.remote = remote
        self.storage = storage
    }
    
    func fetchMovies(page: Int, category: Category) async throws -> [Movie] {
        logger.info("Fetching movies for page \(page), category: \(category)")
        
        let storedMovies = try await storage.getMovies(category: category)
        
        if !storedMovies.isEmpty && page == 1 {
            logger.debug("Returning \(storedMovies.count) stored movies for category \(category)")
            logger.debug("Movie IDs: \(storedMovies.map { $0.id })")
            
            Task {
                do {
                    let freshMovies = try await remote.fetchMovies(page: page, category: category)
                    try await storage.saveMovies(freshMovies, category: category)
                    logger.debug("Background refresh completed for category \(category)")
                    logger.debug("Fresh movie IDs: \(freshMovies.map { $0.id })")
                } catch {
                    logger.error("Background refresh failed for category \(category): \(error.localizedDescription)")
                }
            }
            return storedMovies
        }
        
        let movies = try await remote.fetchMovies(page: page, category: category)
        if page == 1 {
            try await storage.saveMovies(movies, category: category)
        }
        logger.debug("Fetched \(movies.count) movies from remote for category \(category)")
        logger.debug("Movie IDs: \(movies.map { $0.id })")
        return movies
    }
    
    func fetchDetail(forMovie movieID: Movie.ID) async throws -> Movie {
        // Try to get from storage first
        if let storedMovie = try await storage.getMovie(byId: movieID) {
            // Fetch fresh data in the background, but don't block the current flow
            Task {
                
                let freshMovie = try await remote.fetchDetail(forMovie: movieID)
                try await storage.saveMovie(freshMovie)
                
            }
            return storedMovie
        }
        
        
        // If not in storage, fetch from remote
        let movie = try await remote.fetchDetail(forMovie: movieID)
        try await storage.saveMovie(movie)
        return movie
    }
    
    // These methods don't need offline storage as they're supplementary data
    func fetchCastAndCrew(forMovie movieID: Movie.ID) async throws -> ShowCredits {
        return try await remote.fetchCastAndCrew(forMovie: movieID)
    }
    
    func fetchSimilar(toMovie movieID: Movie.ID, page: Int?) async throws -> [Movie] {
        return try await remote.fetchSimilar(toMovie: movieID, page: page)
    }
    
    func fetchShowWatchProvider(forMovie movieID: Movie.ID) async throws -> ShowWatchProvider? {
        return try await remote.fetchShowWatchProvider(forMovie: movieID)
    }
    
    // New methods for favorite functionality
    func toggleFavorite(for movieId: Movie.ID) async throws {
        try await storage.toggleFavorite(for: movieId)
    }
    
    func isFavorite(movieId: Movie.ID) async throws -> Bool {
        return try await storage.isFavorite(movieId: movieId)
    }
}
