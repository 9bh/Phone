import Foundation

enum AppSection: String, CaseIterable, Identifiable, Sendable {
    case dashboard
    case accounts
    case history
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .accounts:
            return "Accounts"
        case .history:
            return "History"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .dashboard:
            return "square.grid.2x2"
        case .accounts:
            return "key.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .settings:
            return "gearshape"
        }
    }
}
