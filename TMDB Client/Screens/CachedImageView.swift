//
//  CachedImageView.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 14/11/2024.
//


import SwiftUI

struct CachedImageView: View {
    let url: URL?
    let imageType: ImageType
    let imageLoader: ImageLoading
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.gray)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        image = await imageLoader.downloadImage(from: url, as: imageType, force: false)
        isLoading = false
    }
}
