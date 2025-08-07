import Foundation
import CoreData

/// Validates data integrity during database migrations
public class DataValidator {
    
    // MARK: - Properties
    
    private var validationRules: [String: ValidationRule] = [:]
    private var validationResults: [ValidationResult] = []
    
    // MARK: - Initialization
    
    public init() {
        setupDefaultValidationRules()
    }
    
    // MARK: - Public Methods
    
    /// Register a custom validation rule
    public func registerValidationRule(_ rule: ValidationRule, forType type: String) {
        validationRules[type] = rule
    }
    
    /// Validate data against registered rules
    public func validateData(_ data: Any, type: String) -> ValidationResult {
        guard let rule = validationRules[type] else {
            return ValidationResult(
                isValid: false,
                errors: ["No validation rule found for type: \(type)"],
                warnings: [],
                dataType: type
            )
        }
        
        do {
            let result = try rule.validate(data)
            validationResults.append(result)
            return result
        } catch {
            let errorResult = ValidationResult(
                isValid: false,
                errors: [error.localizedDescription],
                warnings: [],
                dataType: type
            )
            validationResults.append(errorResult)
            return errorResult
        }
    }
    
    /// Get validation statistics
    public func getValidationStatistics() -> ValidationStatistics {
        let totalValidations = validationResults.count
        let successfulValidations = validationResults.filter { $0.isValid }.count
        let failedValidations = totalValidations - successfulValidations
        
        return ValidationStatistics(
            totalValidations: totalValidations,
            successfulValidations: successfulValidations,
            failedValidations: failedValidations,
            successRate: totalValidations > 0 ? Double(successfulValidations) / Double(totalValidations) : 0,
            errorTypes: [:],
            warningTypes: [:]
        )
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultValidationRules() {
        registerValidationRule(StringValidationRule(), forType: "string")
        registerValidationRule(NumberValidationRule(), forType: "number")
        registerValidationRule(DateValidationRule(), forType: "date")
    }
}

// MARK: - Supporting Types

public struct ValidationResult {
    public let isValid: Bool
    public let errors: [String]
    public let warnings: [String]
    public let dataType: String
}

public struct ValidationStatistics {
    public let totalValidations: Int
    public let successfulValidations: Int
    public let failedValidations: Int
    public let successRate: Double
    public let errorTypes: [String: Int]
    public let warningTypes: [String: Int]
}

// MARK: - Validation Rules

public protocol ValidationRule {
    func validate(_ data: Any) throws -> ValidationResult
}

public class StringValidationRule: ValidationRule {
    public func validate(_ data: Any) throws -> ValidationResult {
        guard let string = data as? String else {
            return ValidationResult(
                isValid: false,
                errors: ["Data is not a string"],
                warnings: [],
                dataType: "string"
            )
        }
        
        return ValidationResult(
            isValid: true,
            errors: [],
            warnings: [],
            dataType: "string"
        )
    }
}

public class NumberValidationRule: ValidationRule {
    public func validate(_ data: Any) throws -> ValidationResult {
        guard data is NSNumber || data is Int || data is Double || data is Float else {
            return ValidationResult(
                isValid: false,
                errors: ["Data is not a number"],
                warnings: [],
                dataType: "number"
            )
        }
        
        return ValidationResult(
            isValid: true,
            errors: [],
            warnings: [],
            dataType: "number"
        )
    }
}

public class DateValidationRule: ValidationRule {
    public func validate(_ data: Any) throws -> ValidationResult {
        guard data is Date || data is NSDate else {
            return ValidationResult(
                isValid: false,
                errors: ["Data is not a date"],
                warnings: [],
                dataType: "date"
            )
        }
        
        return ValidationResult(
            isValid: true,
            errors: [],
            warnings: [],
            dataType: "date"
        )
    }
}
