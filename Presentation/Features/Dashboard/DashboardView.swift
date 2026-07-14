import SwiftUI

struct DashboardView: View {
    @ObservedObject var router: NavigationRouter
    
    init(router: NavigationRouter = NavigationRouter()) {
        self.router = router
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "shield.righthalf.filled")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                        .padding(.top, 24)
                    
                    Text("SecureVault Dashboard")
                        .font(.title2.bold())
                    
                    Text("Select a vault section below to view or manage your items.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(spacing: 16) {
                    quickAccessCard(
                        title: "Accounts",
                        subtitle: "Manage saved website and app credentials",
                        icon: "key.fill",
                        section: .accounts
                    )
                    
                    quickAccessCard(
                        title: "History",
                        subtitle: "View recent vault activity and access logs",
                        icon: "clock.arrow.circlepath",
                        section: .history
                    )
                    
                    quickAccessCard(
                        title: "Settings",
                        subtitle: "Configure Face ID, Auto-Lock, and Passcode",
                        icon: "gearshape.fill",
                        section: .settings
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func quickAccessCard(title: String, subtitle: String, icon: String, section: AppSection) -> some View {
        Button(action: {
            router.navigate(to: section)
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}
