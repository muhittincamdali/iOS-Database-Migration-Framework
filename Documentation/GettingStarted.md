# Getting Started Guide

## Overview

This guide will help you quickly set up and use the iOS Database Migration Framework in your iOS projects.

## Prerequisites

- iOS 15.0+ with iOS 15.0+ SDK
- Swift 5.9+
- Xcode 15.0+
- Swift Package Manager or CocoaPods

## Installation

### Swift Package Manager

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Database-Migration-Framework.git", from: "1.0.0")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'iOS-Database-Migration-Framework', :git => 'https://github.com/muhittincamdali/iOS-Database-Migration-Framework.git'
```

## Basic Usage

```swift
import DatabaseMigrationFramework

let migrationManager = DatabaseMigrationManager()
let config = MigrationConfiguration()
config.enableAutomaticMigration = true
config.enableBackupBeforeMigration = true

migrationManager.start(with: config)
migrationManager.migrateDatabase { result in
    switch result {
    case .success:
        print("Migration completed successfully")
    case .failure(let error):
        print("Migration failed: \(error)")
    }
}
```

## Next Steps

- Explore the [API Documentation](MigrationManagerAPI.md)
- See [Examples](../Examples/) for practical implementations
- Review [Best Practices](../Documentation/PerformanceGuide.md)
