//
//  MovieDetailViewModel.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//


import Combine
import UIKit
import OSLog

class MovieDetailViewModel: LoadableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MovieDetail")
    // MARK: - Properties
    private let id: Movie.ID
    private let moviesFetcher: MoviesFetching
    private let favoriteManager: MoviesFavorites
    
    let imageLoader: ImageLoading
    
    @Published var isFavorite: Bool = false

    @Published private(set) var state: LoadingState<Movie> = .idle
    @Published var error: Error?
    
    init(
        id: Movie.ID,
        moviesFetcher: MoviesFetching,
        favoriteManager: MoviesFavorites,
        imageLoader: ImageLoading
    ) {
        self.id = id
        self.moviesFetcher = moviesFetcher
        self.favoriteManager = favoriteManager
        self.imageLoader = imageLoader
    }
    
    func load() {
        state = .loading
        
        Task {
            do {
                let movie = try await moviesFetcher.fetchDetail(forMovie: id)
                
                await MainActor.run {
                    state = .loaded(movie)
                }
            } catch {
                await MainActor.run {
                    state = .failed(error)
                }
            }
        }
    }
    
    @MainActor
    func checkFavoriteStatus() async {
        do {
            self.isFavorite = try await favoriteManager.isFavorite(movieId: id)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func toggleFavorite() async {
        do {
            try await favoriteManager.toggleFavorite(for: id)
            self.isFavorite.toggle()
        } catch {
            self.error = error
        }
    }
}
