import SwiftUI

struct FirstSetupView: View {
    @ObservedObject var sessionManager: SessionManager
    
    @State private var setupStep: SetupStep = .createPasscode
    @State private var createdPasscode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var recoveryEmail: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                headerView
                
                switch setupStep {
                case .createPasscode:
                    passcodeEntryView(input: $createdPasscode) {
                        if createdPasscode.count == 6 {
                            withAnimation {
                                setupStep = .confirmPasscode
                            }
                        }
                    }
                case .confirmPasscode:
                    passcodeEntryView(input: $confirmPasscode) {
                        if confirmPasscode.count == 6 {
                            if confirmPasscode == createdPasscode {
                                withAnimation {
                                    setupStep = .recoveryEmail
                                    errorMessage = nil
                                }
                            } else {
                                errorMessage = "Passcodes do not match. Try again."
                                confirmPasscode = ""
                                createdPasscode = ""
                                withAnimation {
                                    setupStep = .createPasscode
                                }
                            }
                        }
                    }
                case .recoveryEmail:
                    recoveryEmailView
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.righthalf.filled")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text(stepTitle)
                .font(.title2.bold())
            
            Text(stepSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let error = errorMessage {
                Text(error)
                    .font(.footnote.bold())
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }
    
    private var stepTitle: String {
        switch setupStep {
        case .createPasscode: return "Create Passcode"
        case .confirmPasscode: return "Confirm Passcode"
        case .recoveryEmail: return "Recovery Email"
        }
    }
    
    private var stepSubtitle: String {
        switch setupStep {
        case .createPasscode:
            return "Enter a 6-digit passcode to secure your mobile vault."
        case .confirmPasscode:
            return "Re-enter your 6-digit passcode to confirm."
        case .recoveryEmail:
            return "Provide a recovery email. No secrets will be stored on disk during Phase 1.5."
        }
    }
    
    private func passcodeEntryView(input: Binding<String>, onComplete: @escaping () -> Void) -> some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < input.wrappedValue.count ? Color.primary : Color.clear)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                        )
                }
            }
            .padding(.vertical, 8)
            
            keypadGrid(input: input, onComplete: onComplete)
        }
    }
    
    private func keypadGrid(input: Binding<String>, onComplete: @escaping () -> Void) -> some View {
        let buttons: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["",  "0", "delete"]
        ]
        
        return VStack(spacing: 16) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(buttons[row], id: \.self) { item in
                        if item == "" {
                            Color.clear
                                .frame(width: 76, height: 76)
                        } else if item == "delete" {
                            Button(action: {
                                if !input.wrappedValue.isEmpty {
                                    input.wrappedValue.removeLast()
                                }
                            }) {
                                Image(systemName: "delete.left.fill")
                                    .font(.title2)
                                    .frame(width: 76, height: 76)
                                    .background(Color.clear)
                                    .clipShape(Circle())
                            }
                            .foregroundColor(input.wrappedValue.isEmpty ? .secondary.opacity(0.3) : .primary)
                            .disabled(input.wrappedValue.isEmpty)
                        } else {
                            Button(action: {
                                if input.wrappedValue.count < 6 {
                                    input.wrappedValue.append(item)
                                    onComplete()
                                }
                            }) {
                                Text(item)
                                    .font(.title.bold())
                                    .frame(width: 76, height: 76)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
    
    private var recoveryEmailView: some View {
        VStack(spacing: 20) {
            TextField("email@example.com", text: $recoveryEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(12)
            
            Button(action: {
                // Keychain integration and cryptographic binding will be implemented in a later security phase.
                sessionManager.completeSetup(passcode: createdPasscode, email: recoveryEmail)
            }) {
                Text("Complete Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(recoveryEmail.isEmpty ? Color.secondary : Color.accentColor)
                    .cornerRadius(12)
            }
            .disabled(recoveryEmail.isEmpty)
        }
        .padding(.horizontal, 16)
    }
}

private enum SetupStep {
    case createPasscode
    case confirmPasscode
    case recoveryEmail
}
