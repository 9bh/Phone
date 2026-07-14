import SwiftUI

struct PrivacyCoverView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            Color.black.opacity(0.85)
                .ignoresSafeArea()
        }
        .accessibilityLabel("Privacy Cover")
    }
}
