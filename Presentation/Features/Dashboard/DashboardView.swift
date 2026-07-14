import SwiftUI

struct DashboardView: View {
    init() {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("Your Vault Is Empty")
                        .font(.headline)
                    
                    Text("Saved items will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Dashboard")
    }
}
