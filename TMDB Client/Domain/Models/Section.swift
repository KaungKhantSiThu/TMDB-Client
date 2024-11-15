//
//  Section.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 16/05/2024.
//

import Foundation

enum Category: String, CaseIterable, Hashable, CustomStringConvertible {
    case nowPlaying
    case popular
    case topRated
    case upcoming
    
    var description: String {
        switch self {
        case .nowPlaying:
            "Now Playing"
        case .popular:
            "Popular"
        case .topRated:
            "Top Rated"
        case .upcoming:
            "Upcoming"
        }
    }
    
}

struct Section: Identifiable, Hashable {
    let id: Category
    let movies: [Movie.ID]
}
