import SwiftUI

struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        AsyncContentView(source: viewModel) { movie in
            ScrollView {
                MovieDetailContent(
                    movie: movie,
                    imageLoader: viewModel.imageLoader
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.checkFavoriteStatus()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        }
    }
}

//#if DEBUG
//struct MovieDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            PreviewContainer.shared.makeMovieDetailView(movieId: Movie.preview.id)
//        }
//    }
//}
//#endif
