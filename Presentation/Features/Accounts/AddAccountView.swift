import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var website: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    private let logger = SecureLogger(category: "AddAccountView")
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Website or App Name", text: $website)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Username or Email", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button(action: saveAccount) {
                        Text("Save Account")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(website.isEmpty || username.isEmpty || password.isEmpty)
                }
                
                Section(footer: Text("Note: Under Phase 1.5, saving is UI-only and will not persist sensitive credentials to disk or Keychain.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveAccount() {
        // UI-only validation and logging without actual credential persistence per Phase 1.5 rule.
        logger.info("Add Account form submitted (UI only, no persistence).")
        dismiss()
    }
}
