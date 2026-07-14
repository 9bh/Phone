import SwiftUI

struct ChangePasscodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPasscode: String = ""
    @State private var newPasscode: String = ""
    @State private var confirmPasscode: String = ""
    
    private let logger = SecureLogger(category: "ChangePasscodeView")
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Current Passcode")) {
                    SecureField("Enter Current 6-digit Passcode", text: $currentPasscode)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("New Passcode")) {
                    SecureField("Enter New 6-digit Passcode", text: $newPasscode)
                        .keyboardType(.numberPad)
                    SecureField("Confirm New Passcode", text: $confirmPasscode)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: changePasscode) {
                        Text("Update Passcode")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(currentPasscode.count != 6 || newPasscode.count != 6 || newPasscode != confirmPasscode)
                }
                
                Section(footer: Text("Note: Under Phase 1.5, this is UI-only and will not modify or store actual cryptographic keys.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Change Passcode")
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
    
    private func changePasscode() {
        logger.info("Change Passcode submitted (UI only, no persistence).")
        dismiss()
    }
}
