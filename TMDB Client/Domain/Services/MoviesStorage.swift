import Foundation

protocol MoviesStorage {
    func saveMovies(_ movies: [Movie], category: Category) async throws
    func getMovies(category: Category) async throws -> [Movie]
    func saveMovie(_ movie: Movie) async throws
    func getMovie(byId movieId: Movie.ID) async throws -> Movie?
    func toggleFavorite(for movieId: Movie.ID) async throws
    func isFavorite(movieId: Movie.ID) async throws -> Bool
}

enum MoviesStorageError: LocalizedError {
    case movieNotFound(Movie.ID)
    case unableToSaveMovies
    case unableToSaveMovie(Movie.ID)
    case unableToToggleFavorite(Movie.ID)
    case unableToCheckFavorite(Movie.ID)
    
    var errorDescription: String? {
        switch self {
        case .movieNotFound(let iD):
            return "Can't find the movie with id: \(iD)."
        case .unableToSaveMovies:
            return "Can't save the movies."
        case .unableToSaveMovie(let iD):
            return "Can't save the movie with id: \(iD)."
        case .unableToToggleFavorite(let iD):
            return "Can't toggle favorite of the movie with id: \(iD)."
        case .unableToCheckFavorite(let iD):
            return "Can't check favorite status of the movie with id: \(iD)."
        }
    }
}
