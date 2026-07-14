import Foundation

final class DependencyContainer: Sendable {
    let logger: SecureLogger
    
    init(logger: SecureLogger = SecureLogger(category: "Infrastructure")) {
        self.logger = logger
    }
}
