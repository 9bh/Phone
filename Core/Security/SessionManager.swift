import Foundation
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    @Published var securityState: SecurityState = .splash
    @Published var isBiometricEnabled: Bool = true
    @Published var autoLockDuration: AutoLockDuration = .immediately
    
    var isSetupCompleted: Bool {
        guard let passcode = inMemoryPasscode else { return false }
        return !passcode.isEmpty
    }
    
    private(set) var inMemoryPasscode: String? = nil
    private(set) var recoveryEmail: String? = nil
    private var lastBackgroundTimestamp: Date? = nil
    
    let biometricAuthService: BiometricAuthService
    private let logger: SecureLogger
    
    init(
        biometricAuthService: BiometricAuthService = BiometricAuthService(),
        logger: SecureLogger = SecureLogger(category: "SessionManager")
    ) {
        self.biometricAuthService = biometricAuthService
        self.logger = logger
    }
    
    func completeSplash() {
        if isSetupCompleted {
            securityState = .locked
            Task {
                await attemptBiometricUnlockOnLaunch()
            }
        } else {
            securityState = .setupRequired
        }
    }
    
    func completeSetup(passcode: String, email: String) {
        // Keychain storage and cryptographic key generation will be implemented in a later security phase.
        // Under Phase 1.5 rules, no real passcode or secrets are stored in UserDefaults or disk.
        self.inMemoryPasscode = passcode
        self.recoveryEmail = email
        self.securityState = .unlocked
        logger.info("First setup completed in-memory for Phase 1.5 foundation.")
    }
    
    func verifyPasscode(_ input: String) -> Bool {
        guard let expected = inMemoryPasscode, !expected.isEmpty else {
            logger.info("Passcode verification rejected: No passcode created during setup.")
            return false
        }
        
        if input == expected {
            unlock()
            return true
        } else {
            logger.info("Passcode verification failed.")
            return false
        }
    }
    
    func unlock() {
        securityState = .unlocked
        lastBackgroundTimestamp = nil
        logger.info("Application unlocked successfully.")
    }
    
    func lock() {
        guard securityState != .setupRequired && securityState != .splash else { return }
        securityState = .locked
        logger.info("Application transitioned to locked state.")
    }
    
    func unlockWithBiometric() async -> Bool {
        guard isBiometricEnabled && isSetupCompleted else { return false }
        let success = await biometricAuthService.authenticate()
        if success {
            unlock()
        }
        return success
    }
    
    private func attemptBiometricUnlockOnLaunch() async {
        guard isBiometricEnabled && securityState == .locked else { return }
        _ = await unlockWithBiometric()
    }
    
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            if securityState == .unlocked {
                lastBackgroundTimestamp = Date()
                if autoLockDuration == .immediately {
                    lock()
                } else {
                    // Lock immediately upon background entry when duration is immediate,
                    // otherwise ensure locked state if duration expires or if immediate privacy lock is required.
                    lock()
                }
            }
        case .inactive:
            break
        case .active:
            if securityState == .unlocked, let timestamp = lastBackgroundTimestamp {
                let elapsed = Date().timeIntervalSince(timestamp)
                if autoLockDuration == .immediately || elapsed >= Double(autoLockDuration.rawValue) {
                    lock()
                }
                lastBackgroundTimestamp = nil
            }
            if securityState == .locked && isSetupCompleted {
                Task {
                    await attemptBiometricUnlockOnLaunch()
                }
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Debug / Testing Helpers (#if DEBUG or Unit Testing)
    func simulateLock() {
        lock()
    }
    
    func resetToFirstSetup() {
        inMemoryPasscode = nil
        recoveryEmail = nil
        securityState = .setupRequired
        logger.info("Session reset to first setup for testing/debug.")
    }
}
