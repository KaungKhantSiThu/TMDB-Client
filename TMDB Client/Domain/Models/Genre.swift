//
//  Genre.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//


import Foundation

///
/// A model representing a genre.
///
public struct Genre: Identifiable, Codable, Equatable, Hashable, Sendable {

    ///
    /// Genre Identifier.
    ///
    public let id: Int

    ///
    /// Genre name.
    ///
    public let name: String

    ///
    /// Creates a genre object.
    ///
    /// - Parameters:
    ///    - id: Genre Identifier.
    ///    - name: Genre name.
    ///
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

}