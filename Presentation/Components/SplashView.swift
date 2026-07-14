import SwiftUI

struct SplashView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.accentColor)
                }
                
                Text("SecureVault")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Protected Mobile Infrastructure")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .opacity(opacity)
            .scaleEffect(isAnimating ? 1.0 : 0.96)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
                isAnimating = true
            }
            
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        sessionManager.completeSplash()
                    }
                }
            }
        }
    }
}
