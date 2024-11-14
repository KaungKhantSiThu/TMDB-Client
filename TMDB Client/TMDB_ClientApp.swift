//
//  TMDB_ClientApp.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//

import SwiftUI

@main
struct TMDBApp: App {
    private let container = DependencyContainer()
    private let coordinator: Coordinating
    
    init() {
        self.coordinator = container.makeCoordinator()
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.makeHomeView()
        }
    }
}
