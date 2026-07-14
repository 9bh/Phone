import XCTest
@testable import SecureVault

final class SecurityStateTests: XCTestCase {
    
    @MainActor
    func testInitialSplashToSetupTransition() {
        let sessionManager = SessionManager()
        XCTAssertEqual(sessionManager.securityState, .splash, "App must start in .splash state.")
        
        sessionManager.completeSplash()
        XCTAssertEqual(sessionManager.securityState, .setupRequired, "If setup is not completed (no passcode created), splash completion must transition directly to .setupRequired.")
    }
    
    @MainActor
    func testVerifyPasscodeFailsWithoutSetup() {
        let sessionManager = SessionManager()
        let result = sessionManager.verifyPasscode("999999")
        XCTAssertFalse(result, "Passcode verification must fail when no setup has been completed.")
        XCTAssertFalse(sessionManager.isSetupCompleted, "Setup must not be marked completed before completeSetup is called.")
    }
    
    @MainActor
    func testFirstSetupCompletionTransitionsToUnlocked() {
        let sessionManager = SessionManager()
        sessionManager.completeSetup(passcode: "889900", email: "recovery@securevault.io")
        
        XCTAssertTrue(sessionManager.isSetupCompleted, "Setup must be marked completed.")
        XCTAssertEqual(sessionManager.inMemoryPasscode, "889900", "In-memory passcode must match input.")
        XCTAssertEqual(sessionManager.recoveryEmail, "recovery@securevault.io", "Recovery email must match input.")
        XCTAssertEqual(sessionManager.securityState, .unlocked, "Completing setup must immediately transition to .unlocked state.")
    }
    
    @MainActor
    func testLockStateTransitionAndPasscodeVerification() {
        let sessionManager = SessionManager()
        sessionManager.completeSetup(passcode: "554433", email: "test@domain.com")
        XCTAssertEqual(sessionManager.securityState, .unlocked)
        
        sessionManager.lock()
        XCTAssertEqual(sessionManager.securityState, .locked, "Calling lock() must transition state to .locked.")
        
        let invalidResult = sessionManager.verifyPasscode("000000")
        XCTAssertFalse(invalidResult, "Invalid passcode must return false.")
        XCTAssertEqual(sessionManager.securityState, .locked, "State must remain .locked after invalid passcode.")
        
        let validResult = sessionManager.verifyPasscode("554433")
        XCTAssertTrue(validResult, "Valid passcode must return true.")
        XCTAssertEqual(sessionManager.securityState, .unlocked, "Valid passcode verification must transition state to .unlocked.")
    }
    
    @MainActor
    func testAutoLockImmediatelyOnBackgroundPhase() {
        let sessionManager = SessionManager()
        sessionManager.completeSetup(passcode: "654321", email: "auto@lock.com")
        sessionManager.autoLockDuration = .immediately
        
        XCTAssertEqual(sessionManager.securityState, .unlocked)
        
        sessionManager.handleScenePhaseChange(.background)
        XCTAssertEqual(sessionManager.securityState, .locked, "Entering .background phase must transition state to .locked immediately.")
    }
}
