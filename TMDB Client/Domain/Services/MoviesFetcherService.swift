//
//  MoviesFetcherService.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//


import Foundation
import OSLog

actor MoviesFetcherService {
    private let requestManager: RequestManagerProtocol
    private let imageLoader: ImageLoading
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoviesFetcher")
    
    init(requestManager: RequestManagerProtocol, imageLoader: ImageLoading) {
        self.requestManager = requestManager
        self.imageLoader = imageLoader
    }
}

// MARK: - AnimalFetcher
extension MoviesFetcherService: MoviesFetching {
    func fetchMovies(page: Int, category: Category) async throws -> [Movie] {
        logger.info("Fetching \(category) movies for page \(page)")
        
        do {
            let moviesContainer: MoviePageableList
            switch category {
            case .nowPlaying:
                moviesContainer = try await
                requestManager.get(endpoint: MoviesEndpoint.nowPlaying(page: page))
            case .popular:
                moviesContainer = try await
                requestManager.get(endpoint: MoviesEndpoint.popular(page: page))
            case .topRated:
                moviesContainer = try await
                requestManager.get(endpoint: MoviesEndpoint.topRated(page: page))
            case .upcoming:
                moviesContainer = try await
                requestManager.get(endpoint: MoviesEndpoint.upcoming(page: page))
            }
            
            // Prefetch images for all movies
            let posterURLs = moviesContainer.results.compactMap { $0.posterPath }
            let backdropURLs = moviesContainer.results.compactMap { $0.backdropPath }
            
            Task {
                imageLoader.prefetchImages(urls: posterURLs, type: .poster, force: false)
                imageLoader.prefetchImages(urls: backdropURLs, type: .backdrop, force: false)
            }
            
            logger.debug("Successfully fetched \(moviesContainer.results.count) movies")
            return moviesContainer.results
        } catch {
            logger.error("Failed to fetch movies: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchDetail(forMovie movieID: Movie.ID) async throws -> Movie {
        logger.info("Fetching details for movie \(movieID)")
        do {
            let movie: Movie = try await requestManager.get(endpoint: MoviesEndpoint.details(movieID: movieID))
            logger.debug("Successfully fetched details for movie \(movieID)")
            return movie
        } catch {
            logger.error("Failed to fetch movie details: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchCastAndCrew(forMovie movieID: Movie.ID) async throws -> ShowCredits {
        return try await requestManager.get(endpoint: MoviesEndpoint.credits(movieID: movieID))
    }
    
    func fetchSimilar(toMovie movieID: Movie.ID, page: Int? = nil) async throws -> [Movie] {
        let moviePageableList: MoviePageableList = try await requestManager.get(endpoint: MoviesEndpoint.similar(movieID: movieID, page: page))
        return moviePageableList.results
    }
    
    func fetchShowWatchProvider(forMovie movieID: Movie.ID) async throws -> ShowWatchProvider? {
        let result: ShowWatchProviderResult = try await requestManager.get(endpoint: MoviesEndpoint.watch(movieID: movieID))
        return result.results[Locale.current.region?.identifier ?? "us"]
    }
}
