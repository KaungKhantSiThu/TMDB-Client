//
//  Status.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//


import Foundation

///
/// A model representing a show's status.
///
public enum Status: String, Codable, Equatable, Hashable, Sendable {

    ///
    /// Rumoured.
    ///
    case rumoured = "Rumored"

    ///
    /// Planned.
    ///
    case planned = "Planned"

    ///
    /// In production.
    ///
    case inProduction = "In Production"

    ///
    /// Post production.
    ///
    case postProduction = "Post Production"

    ///
    /// Released.
    ///
    case released = "Released"

    ///
    /// Cancelled.
    ///
    case cancelled = "Canceled"

}