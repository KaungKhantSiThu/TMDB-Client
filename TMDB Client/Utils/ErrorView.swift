import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryHandler: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryHandler) {
                Text("Try Again")
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    ErrorView(
        error: NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error message"]),
        retryHandler: {}
    )
} 