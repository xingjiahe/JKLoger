# Getting Started with JKLoger

This guide will help you quickly integrate JKLoger into your iOS project and start logging effectively.

## Installation

### CocoaPods

Add JKLoger to your `Podfile`:

```ruby
pod 'JKLoger', '~> 1.0'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode, go to **File > Add Package Dependencies** and enter:

```
https://github.com/Jaker/JKLoger.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Jaker/JKLoger.git", from: "1.0.0")
]
```

### Manual Installation

1. Download the source code
2. Drag the `JKLoger` folder into your Xcode project
3. Make sure to add it to your target

## Basic Setup

### 1. Import the Library

```objc
#import <JKLoger/JKLoger.h>
```

### 2. Configure in AppDelegate

Add this to your `application:didFinishLaunchingWithOptions:` method:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure JKLoger
    [self setupLogging];
    
    // Your other app setup code...
    
    return YES;
}

- (void)setupLogging {
    JKLogger *logger = [JKLogger sharedLogger];
    
    // Set global log level
    #ifdef DEBUG
        logger.logLevel = JKLogLevelDebug;
    #else
        logger.logLevel = JKLogLevelInfo;
    #endif
    
    // Add console destination
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    [logger addDestination:console];
    
    // Add file destination for persistent logging
    JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
    [logger addDestination:fileDestination];
    
    JKLogInfo(@"🚀 Logging configured successfully");
}
```

### 3. Start Logging

Now you can use the convenient macros anywhere in your code:

```objc
JKLogInfo(@"Application started");
JKLogDebug(@"User ID: %@", userID);
JKLogWarning(@"Low memory warning");
JKLogError(@"Network error: %@", error);
JKLogFatal(@"Critical system failure");
```

## Common Use Cases

### 1. Network Logging

```objc
- (void)performNetworkRequest {
    JKLogInfo(@"🌐 Starting network request to %@", self.apiURL);
    
    [self.networkManager GET:@"/api/data" 
                  parameters:nil 
                     success:^(NSURLSessionDataTask *task, id responseObject) {
        JKLogInfo(@"✅ Network request successful: %lu bytes", 
                 (unsigned long)[responseObject length]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        JKLogError(@"❌ Network request failed: %@", error.localizedDescription);
    }];
}
```

### 2. User Action Tracking

```objc
- (IBAction)loginButtonTapped:(UIButton *)sender {
    JKLogInfo(@"👤 User initiated login process");
    
    NSString *username = self.usernameField.text;
    JKLogDebug(@"🔐 Login attempt for user: %@", username);
    
    [self performLoginWithUsername:username completion:^(BOOL success, NSError *error) {
        if (success) {
            JKLogInfo(@"✅ Login successful for user: %@", username);
        } else {
            JKLogError(@"❌ Login failed for user %@: %@", username, error.localizedDescription);
        }
    }];
}
```

### 3. Performance Monitoring

```objc
- (void)processLargeDataSet:(NSArray *)data {
    NSDate *startTime = [NSDate date];
    JKLogDebug(@"⏱️ Starting data processing for %lu items", (unsigned long)data.count);
    
    // Process data...
    
    NSTimeInterval processingTime = [[NSDate date] timeIntervalSinceDate:startTime];
    JKLogInfo(@"📊 Data processing completed in %.3f seconds", processingTime);
    
    if (processingTime > 5.0) {
        JKLogWarning(@"⚠️ Data processing took longer than expected: %.3f seconds", processingTime);
    }
}
```

## Advanced Configuration

### Custom Formatters

```objc
// JSON formatter for structured logging
JKCustomFormatter *jsonFormatter = [JKCustomFormatter jsonFormatter];
fileDestination.formatter = jsonFormatter;

// Custom template formatter
NSString *template = @"[{level}] {timestamp} | {message}";
JKCustomFormatter *customFormatter = [[JKCustomFormatter alloc] initWithCustomTemplate:template];
console.formatter = customFormatter;

// Colorful console output
JKCustomFormatter *colorFormatter = [JKCustomFormatter colorfulFormatter];
console.formatter = colorFormatter;
```

### File Logging Configuration

```objc
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];

// Configure file rotation
fileDestination.maxFileSize = 10 * 1024 * 1024; // 10MB per file
fileDestination.maxFileCount = 5; // Keep 5 files maximum

// Custom log directory
NSString *customLogDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject 
                         stringByAppendingPathComponent:@"MyAppLogs"];
fileDestination.logDirectory = customLogDir;

// Custom file prefix
fileDestination.fileNamePrefix = @"myapp";

// Immediate flush for critical logging
fileDestination.immediateFlush = YES;
```

### Remote Logging

```objc
// Configure remote logging server
NSURL *serverURL = [NSURL URLWithString:@"https://logs.myapp.com/api/logs"];
JKRemoteDestination *remoteDestination = [[JKRemoteDestination alloc] initWithServerURL:serverURL];

// Configure batching
remoteDestination.batchSize = 20; // Send 20 logs at once
remoteDestination.batchTimeout = 10.0; // Or send after 10 seconds

// Add authentication headers
remoteDestination.customHeaders = @{
    @"Authorization": @"Bearer your-api-token",
    @"X-App-Version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
};

// Only log errors and above to remote server
remoteDestination.logLevel = JKLogLevelError;

[logger addDestination:remoteDestination];
```

### Multiple Destinations with Different Levels

```objc
JKLogger *logger = [JKLogger sharedLogger];

// Console: Show everything in debug, only warnings+ in release
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
#ifdef DEBUG
    console.logLevel = JKLogLevelDebug;
#else
    console.logLevel = JKLogLevelWarning;
#endif
[logger addDestination:console];

// File: Always log info and above
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
fileDestination.logLevel = JKLogLevelInfo;
[logger addDestination:fileDestination];

// Remote: Only errors and fatal
JKRemoteDestination *remoteDestination = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
remoteDestination.logLevel = JKLogLevelError;
[logger addDestination:remoteDestination];
```

## Best Practices

### 1. Use Appropriate Log Levels

```objc
// ✅ Good
JKLogDebug(@"Cache hit for key: %@", cacheKey);
JKLogInfo(@"User logged in: %@", username);
JKLogWarning(@"API rate limit approaching: %d/%d", currentRequests, maxRequests);
JKLogError(@"Failed to save user data: %@", error);
JKLogFatal(@"Database connection lost");

// ❌ Avoid
JKLogError(@"User clicked button"); // This is not an error
JKLogDebug(@"Critical system failure"); // This should be Fatal
```

### 2. Include Relevant Context

```objc
// ✅ Good - includes context
JKLogError(@"Failed to load user profile for ID %@: %@", userID, error.localizedDescription);

// ❌ Poor - lacks context
JKLogError(@"Load failed");
```

### 3. Use Emojis for Visual Scanning

```objc
JKLogInfo(@"🚀 App launched successfully");
JKLogWarning(@"⚠️ Low disk space: %@ remaining", freeSpace);
JKLogError(@"❌ Network timeout after %.1f seconds", timeout);
JKLogDebug(@"🔍 Searching for items matching: %@", searchTerm);
```

### 4. Conditional Debug Logging

```objc
// Use JKLogD for debug-only logs that are automatically disabled in release
JKLogD(@"🐛 Internal state: %@", internalState);
JKLogD(@"🔧 Cache statistics: hits=%d, misses=%d", hits, misses);
```

### 5. Performance Considerations

```objc
// ✅ Good - log level check is handled internally
JKLogDebug(@"Processing item %@ with data: %@", item.id, item.complexData);

// ❌ Unnecessary - JKLoger already does this check
if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) {
    JKLogDebug(@"Processing item %@", item.id);
}
```

## Debugging Tips

### 1. Check Logger Configuration

```objc
JKLogger *logger = [JKLogger sharedLogger];
NSLog(@"Logger enabled: %@", logger.enabled ? @"YES" : @"NO");
NSLog(@"Log level: %@", JKLogLevelToString(logger.logLevel));
NSLog(@"Destinations: %lu", (unsigned long)logger.destinations.count);

for (id<JKLogDestination> destination in logger.destinations) {
    NSLog(@"Destination: %@", destination);
}
```

### 2. Test Different Log Levels

```objc
- (void)testLogging {
    JKLogFatal(@"Fatal test message");
    JKLogError(@"Error test message");
    JKLogWarning(@"Warning test message");
    JKLogInfo(@"Info test message");
    JKLogDebug(@"Debug test message");
}
```

### 3. Monitor File Logging

```objc
JKFileDestination *fileDestination = /* your file destination */;
NSArray *logFiles = [fileDestination allLogFilePaths];
NSLog(@"Log files: %@", logFiles);

// Check current log file
NSLog(@"Current log file: %@", fileDestination.currentLogFilePath);
```

## Common Issues

### Issue: No logs appearing

**Solution:** Check log level configuration

```objc
// Make sure global log level allows your messages
[JKLogger sharedLogger].logLevel = JKLogLevelDebug;

// Check destination log levels
console.logLevel = JKLogLevelDebug;
```

### Issue: File logging not working

**Solution:** Check directory permissions and paths

```objc
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
NSLog(@"Log directory: %@", fileDestination.logDirectory);

// Test if directory is writable
NSString *testFile = [fileDestination.logDirectory stringByAppendingPathComponent:@"test.txt"];
BOOL success = [@"test" writeToFile:testFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
NSLog(@"Directory writable: %@", success ? @"YES" : @"NO");
```

### Issue: Remote logging not working

**Solution:** Check network connectivity and server configuration

```objc
JKRemoteDestination *remote = /* your remote destination */;
NSLog(@"Network available: %@", [remote isNetworkAvailable] ? @"YES" : @"NO");
NSLog(@"Server URL: %@", remote.serverURL);

// Test with a simple HTTP client
NSURLRequest *request = [NSURLRequest requestWithURL:remote.serverURL];
// ... test the request manually
```

## Next Steps

- Explore the [API Reference](API.md) for detailed documentation
- Check out the [Example App](../Example/README.md) for comprehensive usage examples
- Learn about [Advanced Features](AdvancedFeatures.md) like custom destinations and formatters
- Read the [Performance Guide](Performance.md) for optimization tips

## Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/Jaker/JKLoger/issues)
- **Documentation**: [Full API reference](API.md)
- **Examples**: [Sample code and tutorials](../Example/)

Happy logging! 🎉