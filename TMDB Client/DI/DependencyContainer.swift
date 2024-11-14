class DependencyContainer {
    private let moviesFetching: MoviesFetching
    private let moviesFavorites: MoviesFavorites
    let imageLoader: ImageLoading
    
    init(
        configuration: RequestConfiguration = ProductionConfig(),
        localeProvider: LocaleProviding = LocaleProvider()
    ) {
        
        self.imageLoader = ImageLoader()

        let requestManager = RequestManager(
            configuration: configuration,
            localeProvider: localeProvider
        )
        
        let remoteMoviesFetcher = MoviesFetcherService(
            requestManager: requestManager,
            imageLoader: imageLoader
        )
        let storage = RealmMoviesStorage()
        
        let manager = OfflineFirstMoviesManager(
            remote: remoteMoviesFetcher,
            storage: storage
        )
        
        self.moviesFetching = manager
        self.moviesFavorites = manager
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            moviesFetcher: moviesFetching,
            favoriteManager: moviesFavorites
        )
    }
    
    func makeMovieDetailViewModel(movieId: Movie.ID) -> MovieDetailViewModel {
        MovieDetailViewModel(
            id: movieId,
            moviesFetcher: moviesFetching,
            favoriteManager: moviesFavorites,
            imageLoader: imageLoader
        )
    }
    
    func makeCoordinator() -> Coordinating {
        AppCoordinator(container: self)
    }
    
    func makeMovieCardViewModel(movie: Movie) -> MovieCardViewModel {
        MovieCardViewModel(
            movie: movie,
            imageLoader: imageLoader,
            favoriteManager: moviesFavorites
        )
    }
} 
