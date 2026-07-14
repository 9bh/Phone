import SwiftUI

struct AccountsView: View {
    init() {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "key.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("No Saved Accounts")
                        .font(.headline)
                    
                    Text("Stored accounts will appear here once added.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Accounts")
    }
}
