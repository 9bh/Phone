import Foundation
import os

struct SecureLogger: Sendable {
    private let logger: os.Logger
    
    init(subsystem: String = "com.smartsphere.SecureVault", category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    func info(_ message: StaticString) {
        logger.info("\(message, privacy: .public)")
    }
    
    func error(_ message: StaticString) {
        logger.error("\(message, privacy: .public)")
    }
    
    func fault(_ message: StaticString) {
        logger.fault("\(message, privacy: .public)")
    }
}
