import SwiftUI

struct SettingsView: View {
    init() {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "gearshape")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("No Settings Available")
                        .font(.headline)
                    
                    Text("Configuration options and application preferences will appear here when available.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Settings")
    }
}
