import Foundation
import SwiftUI

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var selectedSection: AppSection? = .dashboard
    
    init() {}
    
    func navigate(to section: AppSection) {
        selectedSection = section
    }
}
