//
//  TMDbImageLoader.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 16/04/2024.
//

import UIKit
import Foundation

enum ImageType {
    case backdrop, profile, poster, still,logo
}
// Extract protocol for testing
protocol ImageLoading {
    func downloadImage(from url: URL?, as: ImageType, force: Bool) async -> UIImage?
    func prefetchImages(urls: [URL?], type: ImageType, force: Bool)
    func clearCache()
}

// Make ImageLoader conform to protocol
class ImageLoader: ImageLoading {

    private let imagesConfiguration: ImagesConfiguration
    private let memoryCache = NSCache<NSString, UIImage>()
        private let fileManager = FileManager.default
        private let diskCacheDirectory: URL
        private let queue = DispatchQueue(label: "com.tmdb.imageloader", qos: .utility)
    
    init() {
        imagesConfiguration = ImagesConfiguration(
            baseURL: URL(string: "http://image.tmdb.org/t/p/")!,
            secureBaseURL: URL(string: "https://image.tmdb.org/t/p/")!,
            backdropSizes: ["w300", "w780", "w1280", "original"],
            logoSizes: ["w45", "w92", "w154", "w185", "w300", "w500", "original"],
            posterSizes: ["w92", "w154", "w185", "w342", "w500", "w780", "original"],
            profileSizes: ["w45", "w185", "h632", "original"],
            stillSizes: ["w92", "w185", "w300", "original"]
        )
        
        // Setup disk cache
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheDirectory = cacheDirectory.appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
    
    private func backdropURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.backdropURL(for: path, idealWidth: width)
    }
    
    private func profileURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.profileURL(for: path, idealWidth: width)
    }
    
    private func posterURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.posterURL(for: path, idealWidth: width)
    }
    
    private func stillURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.stillURL(for: path, idealWidth: width)
    }
    
    private func logoURL(for path: URL?, idealWidth width: Int = Int.max) -> URL? {
        return imagesConfiguration.logoURL(for: path, idealWidth: width)
    }
    
    func generateFullURL(from url: URL?, as type: ImageType, idealWidth width: Int = Int.max) -> URL {
        let fullURL: URL?
        
        switch type {
        case .backdrop:
            fullURL = backdropURL(for: url, idealWidth: width)
        case .profile:
            fullURL = profileURL(for: url, idealWidth: width)
        case .poster:
            fullURL = posterURL(for: url, idealWidth: width)
        case .still:
            fullURL = stillURL(for: url, idealWidth: width)
        case .logo:
            fullURL = logoURL(for: url, idealWidth: width)
        }
        
        return fullURL ?? URL(string: "https://cloud.githubusercontent.com/assets/1567433/9781817/ecb16e82-57a0-11e5-9b43-6b4f52659997.jpg")!
    }
    
    /// Prefetches and caches multiple images in batch
    /// - Parameters:
    ///   - urls: Array of image URLs to prefetch
    ///   - type: Type of TMDb image
    ///   - force: Whether to force download even if cached
    func prefetchImages(urls: [URL?], type: ImageType, force: Bool = false) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let group = DispatchGroup()
            
            for url in urls {
                group.enter()
                self.downloadImage(from: url, as: type, force: force) { _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // All images have been cached
            }
        }
    }
    
    /// Returns cached image if available, otherwise downloads it
    /// - Parameters:
    ///   - url: Image URL
    ///   - type: Type of TMDb image
    ///   - force: Whether to force download even if cached
    /// - Returns: Optional UIImage
    func downloadImage(from url: URL?, as type: ImageType, force: Bool = false) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            downloadImage(from: url, as: type, force: force) { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    private func downloadImage(from url: URL?, as type: ImageType, force: Bool = false, completed: @escaping (UIImage?) -> Void) {
        let fullURL = generateFullURL(from: url, as: type)
        let cacheKey = NSString(string: fullURL.absoluteString)
        
        // Check memory cache first
        if !force, let cachedImage = memoryCache.object(forKey: cacheKey) {
            completed(cachedImage)
            return
        }
        
        // Check disk cache
        let diskCacheURL = diskCacheDirectory.appendingPathComponent(cacheKey.hash.description)
        if !force, let diskCachedImage = loadImageFromDisk(at: diskCacheURL) {
            memoryCache.setObject(diskCachedImage, forKey: cacheKey)
            completed(diskCachedImage)
            return
        }
        
        // Download if not cached
        let task = URLSession.shared.dataTask(with: fullURL) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completed(nil)
                }
                return
            }
            
            // Cache in memory
            self.memoryCache.setObject(image, forKey: cacheKey)
            
            // Cache to disk
            self.queue.async {
                try? data.write(to: diskCacheURL)
            }
            
            DispatchQueue.main.async {
                completed(image)
            }
        }
        
        task.resume()
    }
    
    private func loadImageFromDisk(at url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    /// Clears all cached images from memory and disk
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
}
