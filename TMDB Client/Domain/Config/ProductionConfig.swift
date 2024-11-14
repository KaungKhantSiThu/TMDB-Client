import Foundation

struct ProductionConfig: RequestConfiguration {
    var baseURL: URL = URL(string: "https://api.themoviedb.org/3")!
    var apiKey: String = APIConstants.apiKey
} 
