import RealmSwift
import Foundation

class RealmMovie: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var overview: String?
    @Persisted var posterPath: String?
    @Persisted var backdropPath: String?
    @Persisted var voteAverage: Double?
    @Persisted var voteCount: Int?
    @Persisted var releaseDate: Date?
    @Persisted var isFavorite: Bool = false
    @Persisted var category: String
    
    convenience init(from movie: Movie) {
        self.init()
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath?.absoluteString
        self.backdropPath = movie.backdropPath?.absoluteString
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.releaseDate = movie.releaseDate
        self.isFavorite = movie.isFavorite
        self.category = ""
    }
    
    func toMovie() -> Movie {
        var posterPathURL: URL? = nil
        var backdropPathURL: URL? = nil
        
        if let posterPathString = posterPath {
            posterPathURL = URL(string: posterPathString)
        }
        
        if let backdropPathString = backdropPath {
            backdropPathURL = URL(string: backdropPathString)
        }
        
        return Movie(
            id: id,
            title: title,
            overview: overview,
            releaseDate: releaseDate,
            posterPath: posterPathURL,
            backdropPath: backdropPathURL,
            voteAverage: voteAverage,
            voteCount: voteCount,
            isFavorite: isFavorite
        )
    }
} 
