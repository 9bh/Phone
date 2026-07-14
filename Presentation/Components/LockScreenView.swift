import SwiftUI

struct LockScreenView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var pinInput: String = ""
    @State private var hasError: Bool = false
    @State private var isEvaluatingBiometrics: Bool = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Header & Logo
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.accentColor)
                    
                    Text("Welcome Back")
                        .font(.title2.bold())
                    
                    Text("Enter Passcode")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 6 Indicator Circles
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index < pinInput.count ? Color.primary : Color.clear)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                            )
                    }
                }
                .modifier(ShakeEffect(animatableData: hasError ? 1 : 0))
                .padding(.vertical, 8)
                
                Spacer()
                
                // Custom Numeric Keypad
                keypadGrid
                    .padding(.horizontal, 36)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            if sessionManager.isBiometricEnabled && !isEvaluatingBiometrics {
                isEvaluatingBiometrics = true
                Task {
                    _ = await sessionManager.unlockWithBiometric()
                    isEvaluatingBiometrics = false
                }
            }
        }
    }
    
    private var keypadGrid: some View {
        let buttons: [[KeypadButton]] = [
            [.digit("1"), .digit("2"), .digit("3")],
            [.digit("4"), .digit("5"), .digit("6")],
            [.digit("7"), .digit("8"), .digit("9")],
            [.biometric,  .digit("0"), .delete]
        ]
        
        return VStack(spacing: 16) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(buttons[row], id: \.self) { button in
                        keypadButtonView(for: button)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func keypadButtonView(for button: KeypadButton) -> some View {
        switch button {
        case .digit(let number):
            Button(action: { handleDigit(number) }) {
                Text(number)
                    .font(.title.bold())
                    .frame(width: 76, height: 76)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Circle())
            }
            .foregroundColor(.primary)
            
        case .delete:
            Button(action: { handleDelete() }) {
                Image(systemName: "delete.left.fill")
                    .font(.title2)
                    .frame(width: 76, height: 76)
                    .background(Color.clear)
                    .clipShape(Circle())
            }
            .foregroundColor(pinInput.isEmpty ? .secondary.opacity(0.3) : .primary)
            .disabled(pinInput.isEmpty)
            
        case .biometric:
            if sessionManager.isBiometricEnabled {
                Button(action: {
                    Task {
                        _ = await sessionManager.unlockWithBiometric()
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "faceid")
                            .font(.title2)
                        Text("Face ID")
                            .font(.caption2.bold())
                    }
                    .frame(width: 76, height: 76)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Circle())
                }
                .foregroundColor(.accentColor)
            } else {
                Color.clear
                    .frame(width: 76, height: 76)
            }
        }
    }
    
    private func handleDigit(_ digit: String) {
        guard pinInput.count < 6 else { return }
        pinInput.append(digit)
        
        if pinInput.count == 6 {
            let isValid = sessionManager.verifyPasscode(pinInput)
            if !isValid {
                withAnimation(.default) {
                    hasError = true
                }
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    await MainActor.run {
                        pinInput = ""
                        hasError = false
                    }
                }
            }
        }
    }
    
    private func handleDelete() {
        guard !pinInput.isEmpty else { return }
        pinInput.removeLast()
    }
}

private enum KeypadButton: Hashable {
    case digit(String)
    case delete
    case biometric
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 4), y: 0))
    }
}
