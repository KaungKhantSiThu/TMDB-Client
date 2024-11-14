import Foundation

protocol Coordinating {
    func makeHomeView() -> HomeView
    func makeMovieDetailView(movieId: Movie.ID) -> MovieDetailView
    func makeMovieCard(movie: Movie) -> MovieCard
}

class AppCoordinator: Coordinating {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func makeHomeView() -> HomeView {
        HomeView(
            viewModel: container.makeHomeViewModel(),
            coordinator: self
        )
    }
    
    func makeMovieDetailView(movieId: Movie.ID) -> MovieDetailView {
        MovieDetailView(
            viewModel: container.makeMovieDetailViewModel(movieId: movieId)
        )
    }
    
    func makeMovieCard(movie: Movie) -> MovieCard {
        MovieCard(viewModel: container.makeMovieCardViewModel(movie: movie))
    }
} 