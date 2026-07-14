import SwiftUI

struct AppRootView: View {
    @ObservedObject private var router: NavigationRouter
    @ObservedObject private var sessionManager: SessionManager
    @Environment(\.scenePhase) private var scenePhase
    
    init(router: NavigationRouter, sessionManager: SessionManager) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    var body: some View {
        ZStack {
            switch sessionManager.securityState {
            case .splash:
                SplashView(sessionManager: sessionManager)
            case .setupRequired:
                FirstSetupView(sessionManager: sessionManager)
            case .locked:
                LockScreenView(sessionManager: sessionManager)
            case .unlocked:
                mainNavigationView
            }
            
            if scenePhase == .background || scenePhase == .inactive {
                PrivacyCoverView()
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            sessionManager.handleScenePhaseChange(newPhase)
        }
    }
    
    private var mainNavigationView: some View {
        NavigationStack(path: $router.path) {
            DashboardView(router: router)
                .navigationDestination(for: AppSection.self) { section in
                    destinationView(for: section)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(router: router)
        case .accounts:
            AccountsView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView(sessionManager: sessionManager)
        }
    }
}
