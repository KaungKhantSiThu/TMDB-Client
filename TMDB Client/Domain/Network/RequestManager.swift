//
//  RequestManager.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 13/11/2024.
//

import Foundation

protocol RequestManagerProtocol {
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response
}

protocol RequestConfiguration {
    var baseURL: URL { get }
    var apiKey: String { get }
}

final class RequestManager: RequestManagerProtocol {
    let apiManager: APIManagerProtocol
    let parser: DataParserProtocol
    private let configuration: RequestConfiguration
    private let localeProvider: LocaleProviding
    
    init(
        apiManager: APIManagerProtocol = APIManager(),
        parser: DataParserProtocol = DataParser(),
        configuration: RequestConfiguration,
        localeProvider: LocaleProviding
    ) {
        self.apiManager = apiManager
        self.parser = parser
        self.configuration = configuration
        self.localeProvider = localeProvider
    }
    
    func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
        let url = urlFromPath(endpoint.path)
        let headers = [
            "Authorization": "Bearer \(APIConstants.accessTokenAuth)",
            "Accept": "application/json"
        ]
        
        let request = HTTPRequest(url: url, headers: headers)
        let responseObject: Response = try await perform(request: request)
        
        return responseObject
    }
}

extension RequestManager {
    
    private func perform<Response: Decodable>(request: HTTPRequest) async throws -> Response {
        let response: HTTPResponse
        
        do {
            response = try await apiManager.perform(request: request)
        } catch let error {
            throw TMDbAPIError.network(error)
        }
        
        let decodedResponse: Response = try await decodeResponse(response: response)
        
        return decodedResponse
    }
    
    private func urlFromPath(_ path: URL) -> URL {
        guard var urlComponents = URLComponents(url: path, resolvingAgainstBaseURL: true) else {
            return path
        }
        
        urlComponents.scheme = configuration.baseURL.scheme
        urlComponents.host = configuration.baseURL.host
        urlComponents.path = "\(configuration.baseURL.path)\(urlComponents.path)"
        
        return urlComponents.url!
            .appendingAPIKey(configuration.apiKey)
            .appendingLanguage(localeProvider.languageCode)
    }
    
    private func decodeResponse<Response: Decodable>(response: HTTPResponse) async throws -> Response {
        try await validate(response: response)
        
        guard let data = response.data else {
            throw TMDbAPIError.unknown
        }
        
        let decodedResponse: Response
        do {
            decodedResponse = try await parser.decode(Response.self, from: data)
        } catch let error {
            throw TMDbAPIError.decode(error)
        }
        
        return decodedResponse
    }
    
    private func validate(response: HTTPResponse) async throws {
        let statusCode = response.statusCode
        if (200 ... 299).contains(statusCode) {
            return
        }
        
        guard let data = response.data else {
            throw TMDbAPIError(statusCode: statusCode, message: nil)
        }
        
        let statusResponse = try? await parser.decode(TMDbStatusResponse.self, from: data)
        let message = statusResponse?.statusMessage
        
        throw TMDbAPIError(statusCode: statusCode, message: message)
    }
    
}

