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
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        Future<Movie, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let movie = try await self.moviesFetcher.fetchDetail(forMovie: self.id)
                    promise(.success(movie))
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
            receiveValue: { [weak self] movie in
                self?.state = .loaded(movie)
            }
        )
        .store(in: &cancellables)
    }
    
    func checkFavoriteStatus() {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let isFavorite = try await self.favoriteManager.isFavorite(movieId: self.id)
                    promise(.success(isFavorite))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            },
            receiveValue: { [weak self] isFavorite in
                self?.isFavorite = isFavorite
            }
        )
        .store(in: &cancellables)
    }
    
    func toggleFavorite() {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    try await self.favoriteManager.toggleFavorite(for: self.id)
                    self.logger.info("Toggled favorite status for movie \(self.id)")
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isFavorite.toggle()
                case .failure(let error):
                    print("Error toggling favorite: \(error)")
                }
            },
            receiveValue: { _ in
            }
        )
        .store(in: &cancellables)
    }
}

