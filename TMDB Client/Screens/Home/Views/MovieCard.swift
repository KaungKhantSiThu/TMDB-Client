import SwiftUI

struct MovieCard: View {
    @StateObject private var viewModel: MovieCardViewModel
    
    init(viewModel: MovieCardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                if let posterPath = viewModel.posterPath {
                    CachedImageView(
                        url: posterPath,
                        imageType: .poster,
                        imageLoader: viewModel.imageLoader)
                        .frame(width: 150, height: 225)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Text(viewModel.title)
                    .font(.caption)
                    .lineLimit(2)
                    .frame(width: 150, alignment: .leading)
                
                if let rating = viewModel.rating {
                    RatingView(rating: rating)
                }
            }
            
            if viewModel.isFavorite {
                FavoriteIndicator()
            }
        }
        .frame(width: 150)
        .task {
            await viewModel.checkFavoriteStatus()
        }
    }
}

private struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(rating, format: .number.precision(.fractionLength(1)))
                .font(.caption)
        }
    }
}

private struct FavoriteIndicator: View {
    var body: some View {
        Image(systemName: "bookmark.fill")
            .padding()
    }
}
