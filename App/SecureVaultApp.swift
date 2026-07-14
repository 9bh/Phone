import SwiftUI

@main
struct SecureVaultApp: App {
    private let dependencyContainer = DependencyContainer()
    @StateObject private var navigationRouter = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            AppRootView(router: navigationRouter)
        }
    }
}
