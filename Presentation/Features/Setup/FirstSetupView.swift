import SwiftUI

struct FirstSetupView: View {
    @ObservedObject var sessionManager: SessionManager
    
    @State private var setupStep: SetupStep = .createPasscode
    @State private var createdPasscode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var recoveryEmail: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let isSmallDevice = height < 680
            let buttonSize = min(max((width - 100) / 3, 58), 76)
            let rowSpacing = isSmallDevice ? 12.0 : 16.0
            
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: isSmallDevice ? 16 : 24) {
                        Spacer(minLength: setupStep == .recoveryEmail ? 12 : (isSmallDevice ? 8 : 16))
                        
                        headerView(isSmallDevice: isSmallDevice)
                        
                        switch setupStep {
                        case .createPasscode:
                            passcodeEntryView(
                                input: $createdPasscode,
                                buttonSize: buttonSize,
                                rowSpacing: rowSpacing,
                                isSmallDevice: isSmallDevice
                            ) {
                                if createdPasscode.count == 6 {
                                    withAnimation {
                                        setupStep = .confirmPasscode
                                    }
                                }
                            }
                        case .confirmPasscode:
                            passcodeEntryView(
                                input: $confirmPasscode,
                                buttonSize: buttonSize,
                                rowSpacing: rowSpacing,
                                isSmallDevice: isSmallDevice
                            ) {
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
                                .padding(.top, isSmallDevice ? 4 : 12)
                        }
                        
                        Spacer(minLength: setupStep == .recoveryEmail ? 40 : (geometry.safeAreaInsets.bottom > 0 ? 16 : 28))
                    }
                    .frame(minHeight: setupStep == .recoveryEmail ? 0 : geometry.size.height)
                    .padding(.horizontal, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
    
    @ViewBuilder
    private func headerView(isSmallDevice: Bool) -> some View {
        VStack(spacing: isSmallDevice ? 8 : 12) {
            Image(systemName: "shield.righthalf.filled")
                .font(.system(size: isSmallDevice ? 40 : 48))
                .foregroundColor(.accentColor)
            
            Text(stepTitle)
                .font(isSmallDevice ? .title3.bold() : .title2.bold())
            
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
            return "Provide a recovery email. No secrets are saved to disk during Phase 1.5."
        }
    }
    
    private func passcodeEntryView(
        input: Binding<String>,
        buttonSize: CGFloat,
        rowSpacing: CGFloat,
        isSmallDevice: Bool,
        onComplete: @escaping () -> Void
    ) -> some View {
        VStack(spacing: isSmallDevice ? 16 : 24) {
            HStack(spacing: isSmallDevice ? 12 : 16) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < input.wrappedValue.count ? Color.primary : Color.clear)
                        .frame(width: isSmallDevice ? 12 : 14, height: isSmallDevice ? 12 : 14)
                        .overlay(
                            Circle()
                                .stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                        )
                }
            }
            .padding(.vertical, isSmallDevice ? 4 : 8)
            
            keypadGrid(input: input, buttonSize: buttonSize, rowSpacing: rowSpacing, onComplete: onComplete)
        }
    }
    
    private func keypadGrid(
        input: Binding<String>,
        buttonSize: CGFloat,
        rowSpacing: CGFloat,
        onComplete: @escaping () -> Void
    ) -> some View {
        let buttons: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["",  "0", "delete"]
        ]
        
        return VStack(spacing: rowSpacing) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(buttons[row], id: \.self) { item in
                        if item == "" {
                            Color.clear
                                .frame(width: buttonSize, height: buttonSize)
                        } else if item == "delete" {
                            Button(action: {
                                if !input.wrappedValue.isEmpty {
                                    input.wrappedValue.removeLast()
                                }
                            }) {
                                Image(systemName: "delete.left.fill")
                                    .font(.title2)
                                    .frame(width: buttonSize, height: buttonSize)
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
                                    .frame(width: buttonSize, height: buttonSize)
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
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
                
                TextField("name@example.com", text: $recoveryEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
            }
            
            Button(action: {
                sessionManager.completeSetup(passcode: createdPasscode, email: recoveryEmail)
            }) {
                Text("Complete Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(recoveryEmail.isEmpty ? Color.secondary : Color.accentColor)
                    .cornerRadius(12)
            }
            .disabled(recoveryEmail.isEmpty)
            .padding(.top, 8)
        }
        .padding(.horizontal, 8)
    }
}

private enum SetupStep {
    case createPasscode
    case confirmPasscode
    case recoveryEmail
}
