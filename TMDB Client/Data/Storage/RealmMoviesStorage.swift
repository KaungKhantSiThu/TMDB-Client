import RealmSwift
import Foundation


class RealmMoviesStorage: MoviesStorage {
    private let configuration: Realm.Configuration
    private let logger = AppLogger.shared
    init() {
        self.configuration = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true // Be careful with this in production
        )
        logger.info("Initialized Realm storage", category: .storage)
    }
    
    @MainActor
    func saveMovies(_ movies: [Movie], category: Category) async throws {
        logger.info("Saving \(movies.count) movies for category \(category)", category: .storage)
        do {
            let realmMovies = movies.map { movie -> RealmMovie in 
                let realmMovie = RealmMovie(from: movie)
                realmMovie.category = category.rawValue  // Add category
                return realmMovie
            }
            
            let realm = try await Realm()
            try realm.write {
                // First remove existing movies for this category
                let existingMovies = realm.objects(RealmMovie.self)
                    .where { $0.category == category.rawValue }
                realm.delete(existingMovies)
                
                // Then add the new ones
                realm.add(realmMovies, update: .modified)
            }
            
            logger.debug("Successfully saved movies to storage for category \(category)", category: .storage)
        } catch {
            logger.error("Failed to save movies", category: .storage, error: error)
            throw error
        }
    }
    
    @MainActor
    func getMovies(category: Category) async throws -> [Movie] {
        logger.info("Fetching movies for category \(category)", category: .storage)

        let realm = try await Realm()
        // Filter by category
        let movies = realm.objects(RealmMovie.self)
            .where { $0.category == category.rawValue }
            .freeze()
            .map { $0.toMovie() }
        
        logger.debug("Retrieved \(movies.count) \(category) movies from storage", category: .storage)
        return Array(movies)
    }
    
    @MainActor
    func saveMovie(_ movie: Movie) async throws {
        logger.info("Saving movie with ID: \(movie.id)", category: .storage)
        do {
            let realm = try await Realm()
            let realmMovie = RealmMovie(from: movie)
            
            try realm.write {
                realm.add(realmMovie, update: .modified)
            }
            
            logger.debug("Successfully saved movie", category: .storage)
        } catch {
            logger.error("Failed to save movie", category: .storage, error: error)
            throw error
        }
    }
    
    @MainActor
    func getMovie(byId movieId: Movie.ID) async throws -> Movie? {
        logger.info("Fetching movie with ID: \(movieId)", category: .storage)

        let realm = try await Realm()

            // Create a frozen copy to safely pass across threads
            let movie = realm.object(ofType: RealmMovie.self, forPrimaryKey: movieId)?
            //                .freeze()
                .toMovie()
            
            logger.debug("Retrieved movie: \(movie != nil)", category: .storage)
            
        guard let movie else {
            logger.error("Failed to fetch movie", category: .storage, error: MoviesStorageError.movieNotFound(movieId))
            throw MoviesStorageError.movieNotFound(movieId)
        }
            return movie
    }
    
    @MainActor
    func toggleFavorite(for movieId: Movie.ID) async throws {
        logger.info("Toggling favorite for movie ID: \(movieId)", category: .storage)
        do {
            let realm = try await Realm()

            try realm.write {
                guard let movie = realm.object(ofType: RealmMovie.self, forPrimaryKey: movieId) else {
                    logger.error("Movie not found in storage", category: .storage)
                    return
                }
                movie.isFavorite.toggle()
                logger.debug("Successfully toggled favorite status to: \(movie.isFavorite)", category: .storage)
            }
        } catch {
            logger.error("Failed to toggle favorite", category: .storage, error: error)
            throw MoviesStorageError.unableToToggleFavorite(movieId)
        }
    }
    
    @MainActor
    func isFavorite(movieId: Movie.ID) async throws -> Bool {
        logger.info("Checking favorite status for movie ID: \(movieId)", category: .storage)
        do {
            let realm = try await Realm()
            let isFavorite = realm.object(ofType: RealmMovie.self, forPrimaryKey: movieId)?
            //                .freeze()
                .isFavorite ?? false
            
            logger.debug("Favorite status: \(isFavorite)", category: .storage)
            return isFavorite
        } catch {
            logger.error("Failed to check favorite status", category: .storage, error: error)
            throw MoviesStorageError.unableToCheckFavorite(movieId)
        }
    }
}
