import Foundation

enum SecurityState: String, Sendable, Equatable {
    case splash
    case setupRequired
    case locked
    case unlocked
}
