import SwiftUI

struct AppRootView: View {
    @ObservedObject private var router: NavigationRouter
    
    init(router: NavigationRouter) {
        self.router = router
    }
    
    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $router.selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.iconName)
                }
            }
            .navigationTitle("SecureVault")
        } detail: {
            if let selectedSection = router.selectedSection {
                destinationView(for: selectedSection)
            } else {
                DashboardView()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView()
        case .accounts:
            AccountsView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        }
    }
}
