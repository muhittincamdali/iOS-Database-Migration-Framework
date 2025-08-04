# Performance API

## Overview

The Performance API provides comprehensive performance optimization and monitoring capabilities for database migration operations, enabling efficient large-scale migrations and real-time performance tracking.

## Core Components

### PerformanceManager

The main entry point for performance monitoring and optimization.

```swift
public class PerformanceManager {
    public init()
    public func startPerformanceMonitoring()
    public func stopPerformanceMonitoring()
    public func getPerformanceMetrics() -> PerformanceMetrics
}
```

### PerformanceMetrics

Represents performance metrics and statistics.

```swift
public struct PerformanceMetrics {
    public let migrationTime: TimeInterval
    public let recordsPerSecond: Double
    public let memoryUsage: Int64
    public let cpuUsage: Double
    public let diskUsage: Int64
}
```

## API Reference

### Performance Monitoring

#### Basic Performance Tracking

```swift
let performanceManager = PerformanceManager()
performanceManager.startPerformanceMonitoring()

// Perform migration
migrationManager.migrateDatabase { result in
    performanceManager.stopPerformanceMonitoring()
    
    let metrics = performanceManager.getPerformanceMetrics()
    print("Migration time: \(metrics.migrationTime)s")
    print("Records per second: \(metrics.recordsPerSecond)")
    print("Memory usage: \(metrics.memoryUsage) bytes")
}
```

### Batch Processing

```swift
public class BatchProcessingManager {
    public func processBatch(size: Int, operation: @escaping ([DataRow]) -> Void)
    public func setMemoryLimit(_ limit: Int64)
    public func setConcurrencyLimit(_ limit: Int)
}
```

## Best Practices

1. **Monitor performance metrics during migration**
2. **Use batch processing for large datasets**
3. **Set appropriate memory and CPU limits**
4. **Optimize database queries**
5. **Use background processing when possible**

## Examples

See the [Performance Examples](../Examples/PerformanceExamples/) directory for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Performance Guide](PerformanceGuide.md)
