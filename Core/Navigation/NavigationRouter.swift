import Foundation
import SwiftUI

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var selectedSection: AppSection? = .dashboard
    @Published var path: [AppSection] = []
    
    init() {}
    
    func navigate(to section: AppSection) {
        selectedSection = section
        if section == .dashboard {
            path.removeAll()
        } else {
            if !path.contains(section) {
                path.append(section)
            }
        }
    }
}
