import Foundation

enum AppError: Error, LocalizedError, Sendable {
    case initializationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return "The application failed to initialize properly. Please restart."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
