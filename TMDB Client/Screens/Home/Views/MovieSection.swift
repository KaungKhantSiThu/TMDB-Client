import SwiftUI

struct MovieSection: View {
    let title: String
    let movies: [Movie]
    let makeDetailView: (Movie.ID) -> MovieDetailView
    let makeMovieCard: (Movie) -> MovieCard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink {
                            makeDetailView(movie.id)
                        } label: {
                            makeMovieCard(movie)
                        }
                    }
                }
            }
        }
    }
}



// Preview Provider
//struct MovieSection_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieSection(
//            title: "Popular",
//            movies: [Movie.previewData, Movie.previewData]
//        )
//        .padding()
//        .previewLayout(.sizeThatFits)
//    }
//} 
