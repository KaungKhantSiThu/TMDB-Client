import SwiftUI

struct AsyncContentView<Source: LoadableObject, LoadingView: View, Content: View>: View {
    @ObservedObject var source: Source
    var loadingView: LoadingView
    var content: (Source.Output) -> Content
    
    init(source: Source,
         loadingView: LoadingView,
         @ViewBuilder content: @escaping (Source.Output) -> Content) {
        self.source = source
        self.loadingView = loadingView
        self.content = content
    }
    
    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            loadingView
        case .failed(let error):
            ErrorView(error: error, retryHandler: source.load)
        case .loaded(let output):
            content(output)
        }
    }
}

// Convenience initializer for default loading view
extension AsyncContentView where LoadingView == ProgressView<EmptyView, EmptyView> {
    init(source: Source,
         @ViewBuilder content: @escaping (Source.Output) -> Content) {
        self.init(
            source: source,
            loadingView: ProgressView(),
            content: content
        )
    }
} 
