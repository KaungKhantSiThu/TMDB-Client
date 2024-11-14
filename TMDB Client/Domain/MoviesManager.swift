//
//  MoviesManager.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//

import Foundation

protocol MoviesFetching {
    func fetchMovies(page: Int, category: Category) async throws -> [Movie]
    func fetchDetail(forMovie movieID: Movie.ID) async throws -> Movie
    func fetchCastAndCrew(forMovie movieID: Movie.ID) async throws -> ShowCredits
    func fetchSimilar(toMovie movieID: Movie.ID, page: Int?) async throws -> [Movie]
    func fetchShowWatchProvider(forMovie movieID: Movie.ID) async throws -> ShowWatchProvider?
}

protocol MoviesFavorites {
    func toggleFavorite(for movieId: Movie.ID) async throws
    func isFavorite(movieId: Movie.ID) async throws -> Bool
}

typealias MoviesManager = MoviesFetching & MoviesFavorites


