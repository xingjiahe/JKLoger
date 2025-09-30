# JKLoger Usage Guide

This guide provides practical examples and best practices for using JKLoger in your iOS applications.

## Table of Contents

- [Quick Start](#quick-start)
- [Basic Configuration](#basic-configuration)
- [Advanced Configuration](#advanced-configuration)
- [Destinations](#destinations)
- [Formatters](#formatters)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Installation

#### CocoaPods

Add to your `Podfile`:

```ruby
pod 'JKLoger', '~> 1.0'
```

Then run:

```bash
pod install
```

#### Swift Package Manager

In Xcode, go to `File` > `Add Package Dependencies` and enter:

```
https://github.com/Jaker/JKLoger.git
```

### 2. Basic Setup

In your `AppDelegate.m`:

```objc
#import <JKLoger/JKLoger.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Setup JKLoger
    JKLogger *logger = [JKLogger sharedLogger];
    
    // Add console destination
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    [logger addDestination:console];
    
    // Set log level
    logger.logLevel = JKLogLevelDebug;
    
    // Start logging
    JKLogInfo(@"Application started");
    
    return YES;
}
```

### 3. Basic Logging

```objc
#import <JKLoger/JKLoger.h>

// In your view controllers or other classes
JKLogDebug(@"View controller loaded");
JKLogInfo(@"User action: button tapped");
JKLogWarning(@"Low memory warning received");
JKLogError(@"Network request failed: %@", error);
JKLogFatal(@"Critical system error occurred");
```

---

## Basic Configuration

### Log Levels

Set the global log level to filter messages:

```objc
JKLogger *logger = [JKLogger sharedLogger];

// Only show warnings and errors in production
#ifdef DEBUG
    logger.logLevel = JKLogLevelDebug;
#else
    logger.logLevel = JKLogLevelWarning;
#endif
```

### Enable/Disable Logging

```objc
JKLogger *logger = [JKLogger sharedLogger];

// Disable logging entirely
logger.enabled = NO;

// Re-enable logging
logger.enabled = YES;
```

### Multiple Destinations

```objc
JKLogger *logger = [JKLogger sharedLogger];

// Console for development
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
[logger addDestination:console];

// File for persistent logging
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
[logger addDestination:fileDestination];

// Remote for production monitoring
NSURL *serverURL = [NSURL URLWithString:@"https://logs.yourapp.com/api/logs"];
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
[logger addDestination:remote];
```

---

## Advanced Configuration

### Environment-Based Setup

```objc
- (void)configureLoggingForEnvironment {
    JKLogger *logger = [JKLogger sharedLogger];
    
    NSString *environment = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Environment"];
    
    if ([environment isEqualToString:@"Development"]) {
        [self setupDevelopmentLogging:logger];
    } else if ([environment isEqualToString:@"Staging"]) {
        [self setupStagingLogging:logger];
    } else {
        [self setupProductionLogging:logger];
    }
}

- (void)setupDevelopmentLogging:(JKLogger *)logger {
    logger.logLevel = JKLogLevelDebug;
    
    // Colorful console output
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.formatter = [JKCustomFormatter colorfulFormatter];
    [logger addDestination:console];
    
    // Detailed file logging
    JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
    fileDestination.formatter = [JKCustomFormatter detailedFormatter];
    [logger addDestination:fileDestination];
}

- (void)setupProductionLogging:(JKLogger *)logger {
    logger.logLevel = JKLogLevelWarning;
    
    // Compact console output
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.formatter = [JKCustomFormatter compactFormatter];
    [logger addDestination:console];
    
    // JSON file logging for analysis
    JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
    fileDestination.formatter = [JKCustomFormatter jsonFormatter];
    fileDestination.maxFileSize = 5 * 1024 * 1024; // 5MB
    fileDestination.maxFileCount = 10;
    [logger addDestination:fileDestination];
    
    // Remote logging for monitoring
    NSURL *serverURL = [NSURL URLWithString:@"https://api.yourapp.com/logs"];
    JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
    remote.logLevel = JKLogLevelError; // Only send errors remotely
    remote.customHeaders = @{@"Authorization": @"Bearer your-token"};
    [logger addDestination:remote];
}
```

### Dynamic Configuration

```objc
// Change log level at runtime
- (IBAction)debugModeToggled:(UISwitch *)sender {
    JKLogger *logger = [JKLogger sharedLogger];
    logger.logLevel = sender.isOn ? JKLogLevelDebug : JKLogLevelInfo;
    JKLogInfo(@"Debug mode %@", sender.isOn ? @"enabled" : @"disabled");
}

// Add/remove destinations dynamically
- (void)enableRemoteLogging {
    NSURL *serverURL = [NSURL URLWithString:@"https://api.yourapp.com/logs"];
    JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
    [[JKLogger sharedLogger] addDestination:remote];
    JKLogInfo(@"Remote logging enabled");
}
```

---

## Destinations

### Console Destination

```objc
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];

// Use printf instead of NSLog for better performance
console.useNSLog = NO;

// Set minimum log level for this destination
console.logLevel = JKLogLevelInfo;

// Use custom formatter
console.formatter = [JKCustomFormatter compactFormatter];

[[JKLogger sharedLogger] addDestination:console];
```

### File Destination

```objc
// Custom directory and prefix
NSString *logsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"MyAppLogs"];
JKFileDestination *fileDestination = [[JKFileDestination alloc] initWithDirectory:logsDir fileNamePrefix:@"myapp"];

// Configure rotation
fileDestination.maxFileSize = 2 * 1024 * 1024; // 2MB per file
fileDestination.maxFileCount = 5; // Keep 5 files
fileDestination.immediateFlush = YES; // Flush immediately for debugging

// Use JSON formatter for structured logging
fileDestination.formatter = [JKCustomFormatter jsonFormatter];

[[JKLogger sharedLogger] addDestination:fileDestination];

// Access log files
NSArray<NSString *> *logFiles = [fileDestination allLogFilePaths];
NSLog(@"Log files: %@", logFiles);
```

### Remote Destination

```objc
NSURL *serverURL = [NSURL URLWithString:@"https://api.yourservice.com/logs"];
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];

// Configure batching
remote.batchSize = 20; // Send 20 messages at once
remote.batchTimeout = 10.0; // Or send after 10 seconds

// Configure retry behavior
remote.maxRetryCount = 5;
remote.requestTimeout = 15.0;

// Add authentication
remote.customHeaders = @{
    @"Authorization": @"Bearer your-api-token",
    @"X-App-Version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
};

// Only send errors and fatal messages remotely
remote.logLevel = JKLogLevelError;

[[JKLogger sharedLogger] addDestination:remote];

// Manual flush when needed
[remote flush];
```

---

## Formatters

### Default Formatter

```objc
JKDefaultFormatter *formatter = [[JKDefaultFormatter alloc] init];

// Customize what information to show
formatter.showThreadInfo = NO;
formatter.showFunctionInfo = NO;
formatter.showFileInfo = YES;

// Custom date format
formatter.dateFormatter.dateFormat = @"HH:mm:ss.SSS";
```

### Custom Formatter Styles

```objc
// Compact format for console
JKCustomFormatter *compactFormatter = [JKCustomFormatter compactFormatter];

// Detailed format for debugging
JKCustomFormatter *detailedFormatter = [JKCustomFormatter detailedFormatter];

// JSON format for structured logging
JKCustomFormatter *jsonFormatter = [JKCustomFormatter jsonFormatter];

// XML format for specific integrations
JKCustomFormatter *xmlFormatter = [JKCustomFormatter xmlFormatter];

// Colorful format for development
JKCustomFormatter *colorFormatter = [JKCustomFormatter colorfulFormatter];
```

### Custom Template Formatter

```objc
// Define custom template
NSString *template = @"[{level}] {timestamp} | {file}:{line} | {message}";
JKCustomFormatter *customFormatter = [[JKCustomFormatter alloc] initWithCustomTemplate:template];

// Available placeholders:
// {timestamp} - Formatted timestamp
// {level} - Log level (FATAL, ERROR, etc.)
// {thread} - Thread name
// {queue} - Dispatch queue label
// {file} - Source file name
// {line} - Line number
// {function} - Function name
// {message} - Log message content
```

### Advanced Formatter Configuration

```objc
JKCustomFormatter *formatter = [[JKCustomFormatter alloc] init];

// Enable colors for console output
formatter.enableColors = YES;

// Truncate long messages
formatter.maxMessageLength = 200;

// Custom colors for different levels
[formatter setColor:JKLogColorRed forLevel:JKLogLevelFatal];
[formatter setColor:JKLogColorRed forLevel:JKLogLevelError];
[formatter setColor:JKLogColorYellow forLevel:JKLogLevelWarning];
[formatter setColor:JKLogColorGreen forLevel:JKLogLevelInfo];
[formatter setColor:JKLogColorCyan forLevel:JKLogLevelDebug];
```

---

## Best Practices

### 1. Structured Logging

Use consistent message formats for easier parsing:

```objc
// Good: Structured format
JKLogInfo(@"User action: %@ | user_id: %@ | duration: %.2fs", action, userID, duration);

// Better: Use key-value pairs
JKLogInfo(@"user_action=%@ user_id=%@ duration=%.2f", action, userID, duration);

// Best: Use JSON formatter with structured data
NSDictionary *eventData = @{
    @"action": action,
    @"user_id": userID,
    @"duration": @(duration),
    @"timestamp": [NSDate date]
};
JKLogInfo(@"User event: %@", eventData);
```

### 2. Log Levels Usage

```objc
// FATAL: System is unusable
JKLogFatal(@"Database connection failed permanently");

// ERROR: Error conditions that need attention
JKLogError(@"API request failed: %@", error);

// WARNING: Warning conditions that might cause problems
JKLogWarning(@"Memory usage is high: %.1f%%", memoryUsage);

// INFO: General information about system operation
JKLogInfo(@"User %@ logged in successfully", username);

// DEBUG: Detailed information for debugging
JKLogDebug(@"Processing item %lu of %lu", currentIndex, totalCount);
```

### 3. Performance Considerations

```objc
// Avoid expensive operations in log messages
// Bad:
JKLogDebug(@"User data: %@", [self expensiveUserDataCalculation]);

// Good: Check log level first
if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) {
    NSDictionary *userData = [self expensiveUserDataCalculation];
    JKLogDebug(@"User data: %@", userData);
}

// Better: Use lazy evaluation
JKLogDebug(@"User data will be calculated when needed");
```

### 4. Security Considerations

```objc
// Never log sensitive information
// Bad:
JKLogInfo(@"User logged in with password: %@", password);

// Good:
JKLogInfo(@"User %@ logged in successfully", username);

// For debugging, use sanitized data
NSString *sanitizedToken = [token substringToIndex:MIN(8, token.length)];
JKLogDebug(@"API token starts with: %@...", sanitizedToken);
```

### 5. Error Handling

```objc
// Log errors with context
- (void)performNetworkRequest {
    NSError *error;
    NSData *data = [self makeRequestWithError:&error];
    
    if (error) {
        JKLogError(@"Network request failed | url=%@ | error=%@ | code=%ld", 
                  self.requestURL, error.localizedDescription, (long)error.code);
        return;
    }
    
    JKLogInfo(@"Network request succeeded | url=%@ | bytes=%lu", 
             self.requestURL, (unsigned long)data.length);
}
```

---

## Common Patterns

### 1. Category-Based Logging

```objc
// Create categories for different parts of your app
#define JKLogNetwork(fmt, ...) JKLogInfo(@"[NETWORK] " fmt, ##__VA_ARGS__)
#define JKLogUI(fmt, ...) JKLogDebug(@"[UI] " fmt, ##__VA_ARGS__)
#define JKLogData(fmt, ...) JKLogDebug(@"[DATA] " fmt, ##__VA_ARGS__)

// Usage
JKLogNetwork(@"API request started: %@", endpoint);
JKLogUI(@"View controller presented: %@", NSStringFromClass([self class]));
JKLogData(@"Core Data save completed");
```

### 2. Method Entry/Exit Logging

```objc
#define JKLogMethodEntry() JKLogDebug(@"→ %@", NSStringFromSelector(_cmd))
#define JKLogMethodExit() JKLogDebug(@"← %@", NSStringFromSelector(_cmd))

- (void)someComplexMethod {
    JKLogMethodEntry();
    
    // Method implementation
    
    JKLogMethodExit();
}
```

### 3. Conditional Logging

```objc
// Only log in debug builds
#ifdef DEBUG
    #define JKLogDebugOnly(fmt, ...) JKLogDebug(fmt, ##__VA_ARGS__)
#else
    #define JKLogDebugOnly(fmt, ...)
#endif

// Usage
JKLogDebugOnly(@"This only appears in debug builds");
```

### 4. Performance Monitoring

```objc
- (void)performExpensiveOperation {
    NSDate *startTime = [NSDate date];
    JKLogInfo(@"Starting expensive operation");
    
    // Perform operation
    [self doExpensiveWork];
    
    NSTimeInterval duration = -[startTime timeIntervalSinceNow];
    JKLogInfo(@"Expensive operation completed in %.3fs", duration);
    
    if (duration > 1.0) {
        JKLogWarning(@"Operation took longer than expected: %.3fs", duration);
    }
}
```

### 5. User Journey Tracking

```objc
- (void)trackUserJourney:(NSString *)event withData:(NSDictionary *)data {
    NSMutableDictionary *journeyData = [data mutableCopy] ?: [NSMutableDictionary dictionary];
    journeyData[@"event"] = event;
    journeyData[@"timestamp"] = [NSDate date];
    journeyData[@"user_id"] = [self currentUserID];
    journeyData[@"session_id"] = [self currentSessionID];
    
    JKLogInfo(@"User journey: %@", journeyData);
}

// Usage
[self trackUserJourney:@"screen_view" withData:@{@"screen": @"profile"}];
[self trackUserJourney:@"button_tap" withData:@{@"button": @"save_profile"}];
```

---

## Troubleshooting

### Common Issues

#### 1. Logs Not Appearing

```objc
// Check if logging is enabled
JKLogger *logger = [JKLogger sharedLogger];
NSLog(@"Logger enabled: %@", logger.enabled ? @"YES" : @"NO");
NSLog(@"Logger level: %@", JKLogLevelToString(logger.logLevel));
NSLog(@"Destinations count: %lu", (unsigned long)logger.destinations.count);

// Ensure you have destinations
if (logger.destinations.count == 0) {
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    [logger addDestination:console];
}
```

#### 2. File Logging Not Working

```objc
// Check file destination configuration
JKFileDestination *fileDestination = /* your file destination */;
NSLog(@"Log directory: %@", fileDestination.logDirectory);
NSLog(@"Current log file: %@", fileDestination.currentLogFilePath);

// Check if directory exists and is writable
NSFileManager *fileManager = [NSFileManager defaultManager];
BOOL isDirectory;
BOOL exists = [fileManager fileExistsAtPath:fileDestination.logDirectory isDirectory:&isDirectory];
NSLog(@"Directory exists: %@, is directory: %@", exists ? @"YES" : @"NO", isDirectory ? @"YES" : @"NO");

// List all log files
NSArray<NSString *> *logFiles = [fileDestination allLogFilePaths];
NSLog(@"Log files: %@", logFiles);
```

#### 3. Remote Logging Issues

```objc
// Check network connectivity
JKRemoteDestination *remote = /* your remote destination */;
BOOL networkAvailable = [remote isNetworkAvailable];
NSLog(@"Network available: %@", networkAvailable ? @"YES" : @"NO");

// Test with a simple message
[remote sendLogMessage:testMessage completion:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"Remote logging test successful");
    } else {
        NSLog(@"Remote logging test failed: %@", error);
    }
}];
```

### Debug Mode

Enable verbose logging to troubleshoot issues:

```objc
// Temporarily set to debug level
JKLogger *logger = [JKLogger sharedLogger];
JKLogLevel originalLevel = logger.logLevel;
logger.logLevel = JKLogLevelDebug;

// Add console destination if not present
JKConsoleDestination *debugConsole = [[JKConsoleDestination alloc] init];
debugConsole.formatter = [JKCustomFormatter detailedFormatter];
[logger addDestination:debugConsole];

// Test logging
JKLogDebug(@"Debug mode enabled for troubleshooting");

// Restore original level when done
// logger.logLevel = originalLevel;
```

### Performance Profiling

```objc
// Measure logging performance
- (void)profileLoggingPerformance {
    NSDate *startTime = [NSDate date];
    
    for (int i = 0; i < 1000; i++) {
        JKLogInfo(@"Performance test message %d", i);
    }
    
    NSTimeInterval duration = -[startTime timeIntervalSinceNow];
    NSLog(@"1000 log messages took %.3fs (%.3fms per message)", duration, duration * 1000 / 1000);
}
```

---

For more examples, see the [Example project](../Example/README.md) and [API Reference](API.md).