import Foundation

#if DEBUG
struct PreviewContainer {
    static let shared = DependencyContainer(
        configuration: PreviewConfig(),
        localeProvider: PreviewLocaleProvider()
    )
}

struct PreviewConfig: RequestConfiguration {
    var baseURL: URL = URL(string: "https://api.themoviedb.org/3")!
    var apiKey: String = "preview-key"
}

struct PreviewLocaleProvider: LocaleProviding {
    var languageCode: String? = "en"
    var regionCode: String? = "US"
}

extension Movie {
    static let preview = Movie(
        id: 1,
        title: "Preview Movie",
        overview: "This is a preview movie",
        releaseDate: Date(),
        posterPath: nil,
        backdropPath: nil,
        voteAverage: 8.5,
        voteCount: 100, isFavorite: false
    )
}
#endif 
