import SwiftUI

struct MovieDetailContent: View {
    let movie: Movie
    let imageLoader: ImageLoading
    
    var body: some View {
        VStack(spacing: 16) {
            if let backdropPath = movie.backdropPath {
                CachedImageView(
                    url: backdropPath,
                    imageType: .backdrop,
                    imageLoader: imageLoader
                )
                .frame(height: 200)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let tagline = movie.tagline {
                    Text(tagline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let overview = movie.overview {
                    Text("Overview")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(overview)
                        .font(.body)
                }
                
            }
            .padding()
        }
    }
}
