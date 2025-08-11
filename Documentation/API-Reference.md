# API Reference

## Core Classes

### Main Framework

The main entry point for the iOS-Database-Migration-Framework framework.

```swift
public class iOS-Database-Migration-Framework {
    public init()
    public func configure()
    public func reset()
}
```

## Configuration

### Options

```swift
public struct Configuration {
    public var debugMode: Bool
    public var logLevel: LogLevel
    public var cacheEnabled: Bool
}
```

## Error Handling

```swift
public enum iOS-Database-Migration-FrameworkError: Error {
    case configurationFailed
    case initializationError
    case runtimeError(String)
}
