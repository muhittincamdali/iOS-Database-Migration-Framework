import Foundation
import Combine

/// Comprehensive audit logging system for database migrations
@available(iOS 15.0, *)
public final class AuditLogger: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var auditEvents: [AuditEvent] = []
    @Published public var isLoggingEnabled: Bool = true
    @Published public var logLevel: AuditLogLevel = .info
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let auditStorage: AuditStorageProtocol
    private let auditQueue = DispatchQueue(label: "com.migration.audit", qos: .utility)
    private let dateFormatter: DateFormatter
    
    // MARK: - Initialization
    public init(storage: AuditStorageProtocol = UserDefaultsAuditStorage()) {
        self.auditStorage = storage
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        setupAuditLogging()
        loadAuditEvents()
    }
    
    // MARK: - Public Methods
    
    /// Log an audit event with detailed information
    /// - Parameters:
    ///   - event: The audit event to log
    ///   - level: Log level for the event
    ///   - metadata: Additional metadata for the event
    public func logEvent(_ event: String, level: AuditLogLevel = .info, metadata: [String: Any]? = nil) {
        guard isLoggingEnabled else { return }
        
        let auditEvent = AuditEvent(
            id: UUID(),
            timestamp: Date(),
            event: event,
            level: level,
            metadata: metadata,
            sessionId: getCurrentSessionId()
        )
        
        auditQueue.async { [weak self] in
            self?.processAuditEvent(auditEvent)
        }
    }
    
    /// Log migration start event
    /// - Parameters:
    ///   - fromVersion: Source version
    ///   - toVersion: Target version
    ///   - configuration: Migration configuration
    public func logMigrationStart(fromVersion: String, toVersion: String, configuration: MigrationConfiguration) {
        let metadata: [String: Any] = [
            "fromVersion": fromVersion,
            "toVersion": toVersion,
            "enableRollback": configuration.enableRollback,
            "enableAnalytics": configuration.enableAnalytics,
            "batchSize": configuration.batchSize
        ]
        
        logEvent("Migration started", level: .info, metadata: metadata)
    }
    
    /// Log migration completion event
    /// - Parameters:
    ///   - success: Whether migration was successful
    ///   - duration: Migration duration
    ///   - entitiesProcessed: Number of entities processed
    public func logMigrationCompletion(success: Bool, duration: TimeInterval, entitiesProcessed: Int) {
        let metadata: [String: Any] = [
            "success": success,
            "duration": duration,
            "entitiesProcessed": entitiesProcessed,
            "durationFormatted": formatDuration(duration)
        ]
        
        let level: AuditLogLevel = success ? .info : .error
        logEvent("Migration completed", level: level, metadata: metadata)
    }
    
    /// Log data validation event
    /// - Parameters:
    ///   - entityName: Name of the entity being validated
    ///   - validationResult: Result of the validation
    ///   - issues: Any validation issues found
    public func logDataValidation(entityName: String, validationResult: Bool, issues: [String]? = nil) {
        let metadata: [String: Any] = [
            "entityName": entityName,
            "validationResult": validationResult,
            "issues": issues ?? []
        ]
        
        let level: AuditLogLevel = validationResult ? .info : .warning
        logEvent("Data validation", level: level, metadata: metadata)
    }
    
    /// Log security event
    /// - Parameters:
    ///   - event: Security event description
    ///   - severity: Security severity level
    ///   - details: Additional security details
    public func logSecurityEvent(_ event: String, severity: SecuritySeverity, details: [String: Any]? = nil) {
        let metadata: [String: Any] = [
            "securitySeverity": severity.rawValue,
            "details": details ?? [:]
        ]
        
        let level: AuditLogLevel = severity == .critical ? .error : .warning
        logEvent("Security: \(event)", level: level, metadata: metadata)
    }
    
    /// Log performance event
    /// - Parameters:
    ///   - operation: Operation being measured
    ///   - duration: Duration of the operation
    ///   - memoryUsage: Memory usage during operation
    public func logPerformanceEvent(operation: String, duration: TimeInterval, memoryUsage: Int64? = nil) {
        let metadata: [String: Any] = [
            "operation": operation,
            "duration": duration,
            "durationFormatted": formatDuration(duration),
            "memoryUsage": memoryUsage ?? 0
        ]
        
        let level: AuditLogLevel = duration > 5.0 ? .warning : .info
        logEvent("Performance: \(operation)", level: level, metadata: metadata)
    }
    
    /// Export audit log to JSON
    /// - Parameter dateRange: Optional date range to filter events
    /// - Returns: JSON string containing audit log
    public func exportAuditLog(dateRange: DateInterval? = nil) -> String? {
        let eventsToExport = dateRange != nil ? 
            auditEvents.filter { dateRange!.contains($0.timestamp) } : 
            auditEvents
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let auditLog = AuditLog(
                events: eventsToExport,
                exportDate: Date(),
                totalEvents: auditEvents.count
            )
            let data = try encoder.encode(auditLog)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export audit log: \(error)")
            return nil
        }
    }
    
    /// Import audit log from JSON
    /// - Parameter jsonString: JSON string containing audit log
    /// - Returns: Success status of import operation
    public func importAuditLog(from jsonString: String) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return false
            }
            
            let auditLog = try decoder.decode(AuditLog.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.auditEvents.append(contentsOf: auditLog.events)
            }
            return true
        } catch {
            print("Failed to import audit log: \(error)")
            return false
        }
    }
    
    /// Clear audit events
    public func clearAuditEvents() {
        DispatchQueue.main.async { [weak self] in
            self?.auditEvents.removeAll()
        }
        auditStorage.clearAuditEvents()
    }
    
    /// Get audit statistics
    /// - Returns: Audit statistics
    public func getAuditStatistics() -> AuditStatistics {
        let eventsByLevel = Dictionary(grouping: auditEvents, by: { $0.level })
            .mapValues { $0.count }
        
        let eventsBySession = Dictionary(grouping: auditEvents, by: { $0.sessionId })
            .mapValues { $0.count }
        
        let averageEventsPerSession = eventsBySession.values.isEmpty ? 0 : 
            Double(auditEvents.count) / Double(eventsBySession.count)
        
        return AuditStatistics(
            totalEvents: auditEvents.count,
            eventsByLevel: eventsByLevel,
            eventsBySession: eventsBySession,
            averageEventsPerSession: averageEventsPerSession,
            dateRange: getDateRange()
        )
    }
    
    /// Filter audit events by criteria
    /// - Parameters:
    ///   - level: Minimum log level
    ///   - dateRange: Date range filter
    ///   - sessionId: Session ID filter
    /// - Returns: Filtered audit events
    public func filterAuditEvents(level: AuditLogLevel? = nil, dateRange: DateInterval? = nil, sessionId: String? = nil) -> [AuditEvent] {
        return auditEvents.filter { event in
            let levelMatch = level == nil || event.level.rawValue >= level!.rawValue
            let dateMatch = dateRange == nil || dateRange!.contains(event.timestamp)
            let sessionMatch = sessionId == nil || event.sessionId == sessionId
            
            return levelMatch && dateMatch && sessionMatch
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAuditLogging() {
        $auditEvents
            .sink { [weak self] events in
                self?.saveAuditEvents()
            }
            .store(in: &cancellables)
    }
    
    private func processAuditEvent(_ event: AuditEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.auditEvents.append(event)
        }
        
        // Save to persistent storage
        auditStorage.saveAuditEvent(event)
        
        // Print to console if debug mode
        if logLevel.rawValue <= event.level.rawValue {
            print("[\(dateFormatter.string(from: event.timestamp))] [\(event.level.rawValue.uppercased())] \(event.event)")
        }
    }
    
    private func loadAuditEvents() {
        let events = auditStorage.loadAuditEvents()
        DispatchQueue.main.async { [weak self] in
            self?.auditEvents = events
        }
    }
    
    private func saveAuditEvents() {
        auditStorage.saveAuditEvents(auditEvents)
    }
    
    private func getCurrentSessionId() -> String {
        return UserDefaults.standard.string(forKey: "MigrationSessionId") ?? UUID().uuidString
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "\(duration)s"
    }
    
    private func getDateRange() -> DateInterval? {
        guard let firstEvent = auditEvents.first,
              let lastEvent = auditEvents.last else {
            return nil
        }
        
        return DateInterval(start: firstEvent.timestamp, end: lastEvent.timestamp)
    }
}

// MARK: - Supporting Types

/// Audit log levels
public enum AuditLogLevel: String, Codable, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}

/// Security severity levels
public enum SecuritySeverity: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
}

/// Audit event structure
public struct AuditEvent: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let event: String
    public let level: AuditLogLevel
    public let metadata: [String: Any]?
    public let sessionId: String
    
    public init(id: UUID, timestamp: Date, event: String, level: AuditLogLevel, metadata: [String: Any]?, sessionId: String) {
        self.id = id
        self.timestamp = timestamp
        self.event = event
        self.level = level
        self.metadata = metadata
        self.sessionId = sessionId
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id, timestamp, event, level, metadata, sessionId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        event = try container.decode(String.self, forKey: .event)
        level = try container.decode(AuditLogLevel.self, forKey: .level)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        
        // Handle metadata decoding
        if let metadataData = try container.decodeIfPresent(Data.self, forKey: .metadata) {
            metadata = try JSONSerialization.jsonObject(with: metadataData) as? [String: Any]
        } else {
            metadata = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(event, forKey: .event)
        try container.encode(level, forKey: .level)
        try container.encode(sessionId, forKey: .sessionId)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let metadataData = try JSONSerialization.data(withJSONObject: metadata)
            try container.encode(metadataData, forKey: .metadata)
        }
    }
}

/// Audit log structure
public struct AuditLog: Codable {
    public let events: [AuditEvent]
    public let exportDate: Date
    public let totalEvents: Int
}

/// Audit statistics
public struct AuditStatistics {
    public let totalEvents: Int
    public let eventsByLevel: [AuditLogLevel: Int]
    public let eventsBySession: [String: Int]
    public let averageEventsPerSession: Double
    public let dateRange: DateInterval?
}

/// Audit storage protocol
public protocol AuditStorageProtocol {
    func saveAuditEvent(_ event: AuditEvent)
    func saveAuditEvents(_ events: [AuditEvent])
    func loadAuditEvents() -> [AuditEvent]
    func clearAuditEvents()
}

/// UserDefaults-based audit storage
public class UserDefaultsAuditStorage: AuditStorageProtocol {
    private let key = "MigrationAuditEvents"
    
    public func saveAuditEvent(_ event: AuditEvent) {
        var events = loadAuditEvents()
        events.append(event)
        saveAuditEvents(events)
    }
    
    public func saveAuditEvents(_ events: [AuditEvent]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    public func loadAuditEvents() -> [AuditEvent] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([AuditEvent].self, from: data)) ?? []
    }
    
    public func clearAuditEvents() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
