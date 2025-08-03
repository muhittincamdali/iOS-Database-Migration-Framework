import XCTest
@testable import DatabaseMigration

final class MigrationManagerTests: XCTestCase {
    
    var migrationManager: MigrationManager!
    var configuration: MigrationConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        migrationManager = MigrationManager(configuration: configuration)
    }
    
    override func tearDown() {
        migrationManager = nil
        configuration = nil
        super.tearDown()
    }
    
    func testMigrationManagerInitialization() {
        XCTAssertNotNil(migrationManager)
        XCTAssertEqual(migrationManager.getCurrentState(), .idle)
    }
    
    func testMigrationConfiguration() {
        XCTAssertEqual(configuration.currentVersion, "1.0.0")
        XCTAssertEqual(configuration.targetVersion, "2.0.0")
        XCTAssertTrue(configuration.enableRollback)
        XCTAssertTrue(configuration.enableAnalytics)
    }
    
    func testMigrationHistory() {
        let history = migrationManager.getMigrationHistory()
        XCTAssertTrue(history.isEmpty)
    }
    
    func testAnalyticsData() {
        let analytics = migrationManager.getAnalytics()
        XCTAssertNotNil(analytics)
    }
}

final class SchemaValidatorTests: XCTestCase {
    
    var validator: SchemaValidator!
    var configuration: MigrationConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0"
        )
        validator = SchemaValidator(configuration: configuration)
    }
    
    override func tearDown() {
        validator = nil
        configuration = nil
        super.tearDown()
    }
    
    func testSchemaValidatorInitialization() {
        XCTAssertNotNil(validator)
    }
    
    func testValidationResult() async throws {
        let result = try await validator.validate()
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
        XCTAssertTrue(result.warnings.isEmpty)
    }
}

final class MigrationAnalyticsTests: XCTestCase {
    
    var analytics: MigrationAnalytics!
    var configuration: MigrationAnalyticsConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = MigrationAnalyticsConfiguration(
            enablePerformanceMetrics: true,
            enableDataIntegrityChecks: true,
            enableAuditLogging: true
        )
        analytics = MigrationAnalytics(configuration: configuration)
    }
    
    override func tearDown() {
        analytics = nil
        configuration = nil
        super.tearDown()
    }
    
    func testAnalyticsInitialization() {
        XCTAssertNotNil(analytics)
    }
    
    func testAnalyticsData() {
        let data = analytics.getAnalyticsData()
        XCTAssertNotNil(data)
        XCTAssertEqual(data.successfulMigrations, 0)
        XCTAssertEqual(data.failedMigrations, 0)
        XCTAssertEqual(data.successRate, 0)
    }
    
    func testMigrationSuccessRecording() {
        let result = MigrationResult(
            success: true,
            fromVersion: "1.0.0",
            toVersion: "2.0.0",
            duration: 1.5,
            recordsCount: 100,
            errors: []
        )
        
        analytics.recordMigrationSuccess(result)
        
        let data = analytics.getAnalyticsData()
        XCTAssertEqual(data.successfulMigrations, 1)
        XCTAssertEqual(data.failedMigrations, 0)
        XCTAssertEqual(data.successRate, 1.0)
    }
    
    func testMigrationFailureRecording() {
        let error = MigrationError.invalidCurrentVersion
        analytics.recordMigrationFailure(error)
        
        let data = analytics.getAnalyticsData()
        XCTAssertEqual(data.successfulMigrations, 0)
        XCTAssertEqual(data.failedMigrations, 1)
        XCTAssertEqual(data.successRate, 0.0)
        XCTAssertNotNil(data.lastError)
    }
}

final class CoreDataMigrationManagerTests: XCTestCase {
    
    var manager: CoreDataMigrationManager!
    var configuration: CoreDataMigrationConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = CoreDataMigrationConfiguration(
            modelVersions: ["1.0.0", "2.0.0"],
            enableValidation: true,
            enableAnalytics: true
        )
        manager = CoreDataMigrationManager(configuration: configuration)
    }
    
    override func tearDown() {
        manager = nil
        configuration = nil
        super.tearDown()
    }
    
    func testCoreDataMigrationManagerInitialization() {
        XCTAssertNotNil(manager)
    }
    
    func testConfiguration() {
        XCTAssertEqual(configuration.modelVersions.count, 2)
        XCTAssertTrue(configuration.enableValidation)
        XCTAssertTrue(configuration.enableAnalytics)
    }
}

final class SwiftDataMigrationManagerTests: XCTestCase {
    
    var manager: SwiftDataMigrationManager!
    var configuration: SwiftDataMigrationConfiguration!
    var schemaEvolution: SchemaEvolution!
    
    override func setUp() {
        super.setUp()
        schemaEvolution = SchemaEvolution()
            .addEntity("User", properties: [
                "id": .uuid,
                "name": .string,
                "email": .string
            ])
        
        configuration = SwiftDataMigrationConfiguration(
            schemaEvolution: schemaEvolution,
            enableDataTransformation: true,
            enableConflictResolution: true
        )
        manager = SwiftDataMigrationManager(configuration: configuration)
    }
    
    override func tearDown() {
        manager = nil
        configuration = nil
        schemaEvolution = nil
        super.tearDown()
    }
    
    func testSwiftDataMigrationManagerInitialization() {
        XCTAssertNotNil(manager)
    }
    
    func testSchemaEvolution() {
        XCTAssertEqual(schemaEvolution.entities.count, 1)
        XCTAssertNotNil(schemaEvolution.entities["User"])
        XCTAssertEqual(schemaEvolution.entities["User"]?.count, 3)
    }
    
    func testConfiguration() {
        XCTAssertTrue(configuration.enableDataTransformation)
        XCTAssertTrue(configuration.enableConflictResolution)
        XCTAssertTrue(configuration.enableAnalytics)
    }
}

final class PerformanceTests: XCTestCase {
    
    var manager: MigrationManager!
    
    override func setUp() {
        super.setUp()
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        manager = MigrationManager(configuration: config)
    }
    
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testMigrationPerformance() {
        measure {
            // Measure migration performance
            let expectation = XCTestExpectation(description: "Migration performance")
            
            Task {
                do {
                    let result = try await manager.migrate()
                    XCTAssertTrue(result.success)
                    expectation.fulfill()
                } catch {
                    XCTFail("Migration failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testValidationPerformance() {
        measure {
            // Measure validation performance
            let expectation = XCTestExpectation(description: "Validation performance")
            
            Task {
                do {
                    let result = try await manager.validateSchema()
                    XCTAssertTrue(result.isValid)
                    expectation.fulfill()
                } catch {
                    XCTFail("Validation failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
}

final class ErrorHandlingTests: XCTestCase {
    
    var manager: MigrationManager!
    
    override func setUp() {
        super.setUp()
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        manager = MigrationManager(configuration: config)
    }
    
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testInvalidVersionError() {
        let invalidConfig = MigrationConfiguration(
            currentVersion: "",
            targetVersion: "2.0.0"
        )
        
        let invalidManager = MigrationManager(configuration: invalidConfig)
        
        let expectation = XCTestExpectation(description: "Invalid version error")
        
        Task {
            do {
                let result = try await invalidManager.migrate()
                XCTFail("Should have thrown an error")
            } catch MigrationError.invalidCurrentVersion {
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSameVersionError() {
        let sameVersionConfig = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "1.0.0"
        )
        
        let sameVersionManager = MigrationManager(configuration: sameVersionConfig)
        
        let expectation = XCTestExpectation(description: "Same version error")
        
        Task {
            do {
                let result = try await sameVersionManager.migrate()
                XCTFail("Should have thrown an error")
            } catch MigrationError.sameVersionMigration {
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

final class IntegrationTests: XCTestCase {
    
    var manager: MigrationManager!
    var analytics: MigrationAnalytics!
    
    override func setUp() {
        super.setUp()
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        manager = MigrationManager(configuration: config)
        
        let analyticsConfig = MigrationAnalyticsConfiguration(
            enablePerformanceMetrics: true,
            enableDataIntegrityChecks: true,
            enableAuditLogging: true
        )
        analytics = MigrationAnalytics(configuration: analyticsConfig)
    }
    
    override func tearDown() {
        manager = nil
        analytics = nil
        super.tearDown()
    }
    
    func testFullMigrationWorkflow() async throws {
        // Test complete migration workflow
        let progressHandler: ProgressHandler = { progress in
            XCTAssertGreaterThanOrEqual(progress.percentage, 0)
            XCTAssertLessThanOrEqual(progress.percentage, 100)
        }
        
        // Step 1: Validate schema
        let validationResult = try await manager.validateSchema()
        XCTAssertTrue(validationResult.isValid)
        
        // Step 2: Perform migration
        let migrationResult = try await manager.migrate(progressHandler: progressHandler)
        XCTAssertTrue(migrationResult.success)
        
        // Step 3: Record analytics
        analytics.recordMigrationSuccess(migrationResult)
        
        // Step 4: Verify analytics
        let analyticsData = analytics.getAnalyticsData()
        XCTAssertEqual(analyticsData.successfulMigrations, 1)
        XCTAssertEqual(analyticsData.successRate, 1.0)
        
        // Step 5: Verify migration history
        let history = manager.getMigrationHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.fromVersion, "1.0.0")
        XCTAssertEqual(history.first?.toVersion, "2.0.0")
    }
    
    func testRollbackWorkflow() async throws {
        // Test rollback workflow
        let progressHandler: ProgressHandler = { progress in
            XCTAssertGreaterThanOrEqual(progress.percentage, 0)
            XCTAssertLessThanOrEqual(progress.percentage, 100)
        }
        
        // Step 1: Perform migration
        let migrationResult = try await manager.migrate(progressHandler: progressHandler)
        XCTAssertTrue(migrationResult.success)
        
        // Step 2: Perform rollback
        let rollbackResult = try await manager.rollback()
        XCTAssertTrue(rollbackResult.success)
        XCTAssertEqual(rollbackResult.targetVersion, "1.0.0")
        
        // Step 3: Verify history is updated
        let history = manager.getMigrationHistory()
        XCTAssertTrue(history.isEmpty)
    }
}
