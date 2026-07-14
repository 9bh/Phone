import SwiftUI

@main
struct SecureVaultApp: App {
    private let dependencyContainer = DependencyContainer()
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            AppRootView(router: navigationRouter, sessionManager: sessionManager)
                .environmentObject(sessionManager)
        }
    }
}
