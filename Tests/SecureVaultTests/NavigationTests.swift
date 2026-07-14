import XCTest
@testable import SecureVault

final class NavigationTests: XCTestCase {
    
    @MainActor
    func testNavigationRouterInitialState() {
        let router = NavigationRouter()
        XCTAssertEqual(router.selectedSection, .dashboard, "Initial section should default to dashboard.")
    }
    
    @MainActor
    func testNavigationRouterSectionChange() {
        let router = NavigationRouter()
        
        router.navigate(to: .accounts)
        XCTAssertEqual(router.selectedSection, .accounts)
        
        router.navigate(to: .history)
        XCTAssertEqual(router.selectedSection, .history)
        
        router.navigate(to: .settings)
        XCTAssertEqual(router.selectedSection, .settings)
    }
    
    func testAppSectionsProperties() {
        XCTAssertEqual(AppSection.allCases.count, 4, "There must be exactly four primary sections.")
        XCTAssertEqual(AppSection.dashboard.title, "Dashboard")
        XCTAssertEqual(AppSection.accounts.title, "Accounts")
        XCTAssertEqual(AppSection.history.title, "History")
        XCTAssertEqual(AppSection.settings.title, "Settings")
    }
}
