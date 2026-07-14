import Foundation

enum AutoLockDuration: Int, CaseIterable, Sendable, Identifiable {
    case immediately = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .immediately:
            return "Immediately"
        case .oneMinute:
            return "After 1 minute"
        case .fiveMinutes:
            return "After 5 minutes"
        case .fifteenMinutes:
            return "After 15 minutes"
        case .thirtyMinutes:
            return "After 30 minutes"
        }
    }
}
