import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let coordinator: Coordinating
    
    init(viewModel: HomeViewModel, coordinator: Coordinating) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        NavigationView {
            AsyncContentView(source: viewModel) { sections in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(sections, id: \.title) { section in
                            MovieSection(
                                title: section.title,
                                movies: section.movies,
                                makeDetailView: { movieId in
                                    coordinator.makeMovieDetailView(movieId: movieId)
                                },
                                makeMovieCard: { movie in
                                    coordinator.makeMovieCard(movie: movie)
                                }
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    viewModel.load()
                }
            }
            .navigationTitle("Movies")
        }
    }
}

//#if DEBUG
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewContainer.shared.makeHomeView()
//    }
//}
//#endif
