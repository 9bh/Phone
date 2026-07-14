import SwiftUI

struct AccountsView: View {
    @State private var isShowingAddAccount: Bool = false
    
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
                
                Button(action: { isShowingAddAccount = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add Account")
                    }
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Accounts")
        .sheet(isPresented: $isShowingAddAccount) {
            AddAccountView()
        }
    }
}
