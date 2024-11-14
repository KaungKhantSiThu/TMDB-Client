import OSLog

enum LogCategory: String {
    case network = "Network"
    case storage = "Storage"
    case ui = "UI"
    case general = "General"
}

final class AppLogger {
    static let shared = AppLogger()
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.tmdb.client"
    
    private lazy var networkLogger = Logger(subsystem: subsystem, category: LogCategory.network.rawValue)
    private lazy var storageLogger = Logger(subsystem: subsystem, category: LogCategory.storage.rawValue)
    private lazy var uiLogger = Logger(subsystem: subsystem, category: LogCategory.ui.rawValue)
    private lazy var generalLogger = Logger(subsystem: subsystem, category: LogCategory.general.rawValue)
    
    private init() {}
    
    func debug(_ message: String, category: LogCategory = .general, error: Error? = nil) {
        let logger = getLogger(for: category)
        if let error {
            logger.debug("\(message): \(error.localizedDescription, privacy: .public)")
        } else {
            logger.debug("\(message, privacy: .public)")
        }
    }
    
    func info(_ message: String, category: LogCategory = .general) {
        let logger = getLogger(for: category)
        logger.info("\(message, privacy: .public)")
    }
    
    func error(_ message: String, category: LogCategory = .general, error: Error? = nil) {
        let logger = getLogger(for: category)
        if let error {
            logger.error("\(message): \(error.localizedDescription, privacy: .public)")
        } else {
            logger.error("\(message, privacy: .public)")
        }
    }
    
    private func getLogger(for category: LogCategory) -> Logger {
        switch category {
        case .network:
            return networkLogger
        case .storage:
            return storageLogger
        case .ui:
            return uiLogger
        case .general:
            return generalLogger
        }
    }
} 