import Foundation
import LocalAuthentication

final class BiometricAuthService: Sendable {
    private let logger: SecureLogger
    
    init(logger: SecureLogger = SecureLogger(category: "BiometricAuth")) {
        self.logger = logger
    }
    
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(reason: String = "Unlock SecureVault") async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            logger.info("Biometric evaluation policy unavailable.")
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if success {
                logger.info("Biometric authentication completed successfully.")
            } else {
                logger.info("Biometric authentication did not succeed.")
            }
            return success
        } catch {
            logger.info("Biometric authentication did not complete or was cancelled by user.")
            return false
        }
    }
}
