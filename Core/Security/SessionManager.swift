import Foundation
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    @Published var securityState: SecurityState = .splash
    @Published var isBiometricEnabled: Bool = true
    @Published var autoLockDuration: AutoLockDuration = .immediately
    
    var isSetupCompleted: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedFirstSetup")
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
        // Keychain storage and cryptographic key generation will be implemented in Phase 2.
        // Under Phase 1.5 rules, no real passcode or secrets are stored in UserDefaults or disk.
        self.inMemoryPasscode = passcode
        self.recoveryEmail = email
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstSetup")
        self.securityState = .unlocked
        logger.info("First setup completed. Status flag saved to UserDefaults; secrets kept in-memory (Phase 1.5).")
    }
    
    func verifyPasscode(_ input: String) -> Bool {
        guard isSetupCompleted else {
            logger.info("Passcode verification rejected: First setup not completed.")
            return false
        }
        
        guard let expected = inMemoryPasscode, !expected.isEmpty else {
            // Under strict Phase 1.5 security rules, we do NOT allow any random 6-digit passcode after restart.
            // If inMemoryPasscode is cleared after app restart (Keychain storage is Phase 2), passcode unlock is not permitted.
            // The user must authenticate via Face ID or reset setup if required.
            logger.info("Passcode verification rejected: In-memory passcode cleared after restart. Face ID unlock or re-setup required.")
            return false
        }
        
        if input == expected {
            unlock()
            return true
        } else {
            logger.info("Passcode verification failed: Incorrect passcode entered.")
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
        UserDefaults.standard.set(false, forKey: "hasCompletedFirstSetup")
        securityState = .setupRequired
        logger.info("Session reset to first setup for testing/debug.")
    }
}
