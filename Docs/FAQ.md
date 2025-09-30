# JKLoger Frequently Asked Questions

## General Questions

### Q: What is JKLoger?

**A:** JKLoger is a lightweight and extensible logging library for iOS applications written in Objective-C. It provides multiple log levels, various output destinations (console, file, remote), customizable formatters, and thread-safe logging capabilities.

### Q: How does JKLoger compare to other logging libraries?

**A:** JKLoger is designed to be:
- **Lightweight**: Minimal performance overhead and memory footprint
- **Easy to use**: Simple setup with sensible defaults
- **Extensible**: Easy to add custom destinations and formatters
- **Thread-safe**: Built-in synchronization for multi-threaded environments
- **Modern**: Supports iOS 13+ with contemporary iOS development practices

Compared to CocoaLumberjack, JKLoger is simpler to configure and has a smaller footprint, while still providing powerful features.

### Q: Is JKLoger compatible with Swift?

**A:** Yes! JKLoger is written in Objective-C but is fully compatible with Swift projects. You can use it in Swift with bridging headers or import it as a framework.

```swift
// Swift usage example
import JKLoger

let logger = JKLogger.shared()
logger.logLevel = .debug

// Note: Swift doesn't support variadic macros, so use the direct method
logger.log(with: .info, file: #file, function: #function, line: #line, format: "Hello from Swift!")
```

---

## Installation and Setup

### Q: How do I install JKLoger?

**A:** JKLoger supports multiple installation methods:

**CocoaPods:**
```ruby
pod 'JKLoger', '~> 1.0'
```

**Swift Package Manager:**
```
https://github.com/Jaker/JKLoger.git
```

**Manual Installation:**
1. Download the source code
2. Add all files in the `JKLoger/` directory to your project
3. Import the main header: `#import "JKLoger.h"`

### Q: What's the minimum iOS version supported?

**A:** JKLoger requires iOS 13.0 or later. This ensures compatibility with modern iOS features and development practices.

### Q: Do I need to configure anything to start logging?

**A:** No! JKLoger works out of the box with default settings. However, you'll want to add at least one destination:

```objc
// Minimal setup
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
[[JKLogger sharedLogger] addDestination:console];

// Now you can log
JKLogInfo(@"Hello, JKLoger!");
```

---

## Usage Questions

### Q: What are the different log levels?

**A:** JKLoger supports 5 log levels in order of severity:

1. **Fatal** (`JKLogLevelFatal`) - System is unusable
2. **Error** (`JKLogLevelError`) - Error conditions
3. **Warning** (`JKLogLevelWarning`) - Warning conditions
4. **Info** (`JKLogLevelInfo`) - Informational messages
5. **Debug** (`JKLogLevelDebug`) - Debug-level messages

Use the corresponding macros: `JKLogFatal()`, `JKLogError()`, `JKLogWarning()`, `JKLogInfo()`, `JKLogDebug()`

### Q: How do I filter logs by level?

**A:** Set the `logLevel` property on the logger or individual destinations:

```objc
// Global filtering
[JKLogger sharedLogger].logLevel = JKLogLevelWarning; // Only warnings and above

// Per-destination filtering
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.logLevel = JKLogLevelError; // Only errors and fatal to console
```

### Q: Can I disable logging completely?

**A:** Yes, set the `enabled` property to `NO`:

```objc
[JKLogger sharedLogger].enabled = NO; // Disable all logging
[JKLogger sharedLogger].enabled = YES; // Re-enable logging
```

### Q: How do I log to files?

**A:** Use `JKFileDestination`:

```objc
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
[[JKLogger sharedLogger] addDestination:fileDestination];

// Files are automatically created in Documents/Logs/
// Check the path:
NSLog(@"Log files in: %@", fileDestination.logDirectory);
```

### Q: How does file rotation work?

**A:** JKLoger automatically rotates log files when they reach the size limit:

```objc
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
fileDestination.maxFileSize = 5 * 1024 * 1024; // 5MB per file
fileDestination.maxFileCount = 10; // Keep 10 files maximum

// Old files are automatically deleted when the count exceeds maxFileCount
```

---

## Performance Questions

### Q: Is JKLoger thread-safe?

**A:** Yes! JKLoger is fully thread-safe. All logging operations are performed on a dedicated serial queue, so you can safely call logging methods from any thread.

### Q: What's the performance impact of logging?

**A:** JKLoger is designed for minimal performance impact:
- Logging is asynchronous by default
- Log level filtering happens early to avoid unnecessary work
- String formatting only occurs when messages will actually be output
- File I/O is batched and buffered

In typical usage, the performance impact is negligible.

### Q: Should I remove logging calls in production?

**A:** No need! Instead, adjust the log level:

```objc
#ifdef DEBUG
    [JKLogger sharedLogger].logLevel = JKLogLevelDebug;
#else
    [JKLogger sharedLogger].logLevel = JKLogLevelWarning;
#endif
```

You can also use the conditional debug macro:
```objc
JKLogD(@"This only appears in DEBUG builds");
```

---

## Customization Questions

### Q: How do I customize log message format?

**A:** Use formatters! JKLoger provides several built-in formatters:

```objc
// Different formatter styles
JKCustomFormatter *compact = [JKCustomFormatter compactFormatter];
JKCustomFormatter *detailed = [JKCustomFormatter detailedFormatter];
JKCustomFormatter *json = [JKCustomFormatter jsonFormatter];
JKCustomFormatter *colorful = [JKCustomFormatter colorfulFormatter];

// Apply to destinations
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.formatter = colorful;
```

### Q: Can I create custom log formats?

**A:** Yes! Use custom templates:

```objc
NSString *template = @"[{level}] {timestamp} | {file}:{line} | {message}";
JKCustomFormatter *custom = [[JKCustomFormatter alloc] initWithCustomTemplate:template];

// Available placeholders:
// {timestamp}, {level}, {thread}, {queue}, {file}, {line}, {function}, {message}
```

### Q: How do I add colors to console output?

**A:** Use the colorful formatter:

```objc
JKCustomFormatter *colorFormatter = [JKCustomFormatter colorfulFormatter];

// Customize colors for different levels
[colorFormatter setColor:JKLogColorRed forLevel:JKLogLevelError];
[colorFormatter setColor:JKLogColorYellow forLevel:JKLogLevelWarning];

JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.formatter = colorFormatter;
```

### Q: Can I send logs to a remote server?

**A:** Yes! Use `JKRemoteDestination`:

```objc
NSURL *serverURL = [NSURL URLWithString:@"https://api.yourservice.com/logs"];
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];

// Configure authentication
remote.customHeaders = @{@"Authorization": @"Bearer your-token"};

// Configure batching
remote.batchSize = 10; // Send 10 messages at once
remote.batchTimeout = 5.0; // Or send after 5 seconds

[[JKLogger sharedLogger] addDestination:remote];
```

---

## Troubleshooting

### Q: My logs aren't appearing. What should I check?

**A:** Check these common issues:

1. **No destinations added:**
   ```objc
   NSLog(@"Destinations: %lu", (unsigned long)[JKLogger sharedLogger].destinations.count);
   ```

2. **Log level too restrictive:**
   ```objc
   NSLog(@"Log level: %@", JKLogLevelToString([JKLogger sharedLogger].logLevel));
   ```

3. **Logging disabled:**
   ```objc
   NSLog(@"Logging enabled: %@", [JKLogger sharedLogger].enabled ? @"YES" : @"NO");
   ```

### Q: File logging isn't working. What's wrong?

**A:** Check file destination configuration:

```objc
JKFileDestination *fileDestination = /* your file destination */;
NSLog(@"Log directory: %@", fileDestination.logDirectory);
NSLog(@"Current file: %@", fileDestination.currentLogFilePath);

// Check if files exist
NSArray *logFiles = [fileDestination allLogFilePaths];
NSLog(@"Log files: %@", logFiles);
```

### Q: Remote logging isn't working. How do I debug it?

**A:** Check network and server configuration:

```objc
JKRemoteDestination *remote = /* your remote destination */;

// Check network availability
BOOL networkAvailable = [remote isNetworkAvailable];
NSLog(@"Network available: %@", networkAvailable ? @"YES" : @"NO");

// Test with a single message
JKLogMessage *testMessage = [JKLogMessage messageWithLevel:JKLogLevelInfo
                                                   message:@"Test message"
                                                      file:__FILE__
                                                  function:__PRETTY_FUNCTION__
                                                      line:__LINE__];

[remote sendLogMessage:testMessage completion:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"Remote test successful");
    } else {
        NSLog(@"Remote test failed: %@", error);
    }
}];
```

### Q: How do I debug JKLoger itself?

**A:** Enable detailed logging temporarily:

```objc
// Save current settings
JKLogLevel originalLevel = [JKLogger sharedLogger].logLevel;

// Enable debug logging
[JKLogger sharedLogger].logLevel = JKLogLevelDebug;

// Add detailed console output
JKConsoleDestination *debugConsole = [[JKConsoleDestination alloc] init];
debugConsole.formatter = [JKCustomFormatter detailedFormatter];
[[JKLogger sharedLogger] addDestination:debugConsole];

// Test your logging
JKLogDebug(@"Debug mode enabled");

// Restore settings when done
// [JKLogger sharedLogger].logLevel = originalLevel;
```

---

## Advanced Usage

### Q: Can I create custom destinations?

**A:** Yes! Implement the `JKLogDestination` protocol:

```objc
@interface MyCustomDestination : NSObject <JKLogDestination>
@end

@implementation MyCustomDestination

- (void)logMessage:(JKLogMessage *)message {
    // Your custom logging logic here
    NSLog(@"Custom destination received: %@", message.message);
}

@end

// Usage
MyCustomDestination *custom = [[MyCustomDestination alloc] init];
[[JKLogger sharedLogger] addDestination:custom];
```

### Q: Can I create custom formatters?

**A:** Yes! Implement the `JKLogFormatter` protocol:

```objc
@interface MyCustomFormatter : NSObject <JKLogFormatter>
@end

@implementation MyCustomFormatter

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    return [NSString stringWithFormat:@"CUSTOM: %@ - %@", 
            JKLogLevelToString(message.level), message.message];
}

@end
```

### Q: How do I integrate with crash reporting services?

**A:** Create a custom destination that forwards to your crash reporting service:

```objc
@interface CrashReportingDestination : NSObject <JKLogDestination>
@end

@implementation CrashReportingDestination

- (void)logMessage:(JKLogMessage *)message {
    // Forward to crash reporting service
    if (message.level <= JKLogLevelError) {
        // Example: Crashlytics
        // [[Crashlytics sharedInstance] recordError:...];
        
        // Example: Bugsnag
        // [Bugsnag leaveBreadcrumbWithMessage:message.message];
    }
}

@end
```

### Q: How do I implement log sampling for high-volume applications?

**A:** Create a sampling destination wrapper:

```objc
@interface SamplingDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) id<JKLogDestination> wrappedDestination;
@property (nonatomic, assign) NSUInteger sampleRate; // 1 in N messages
@end

@implementation SamplingDestination

- (void)logMessage:(JKLogMessage *)message {
    // Only forward 1 in sampleRate messages
    if (arc4random_uniform((uint32_t)self.sampleRate) == 0) {
        [self.wrappedDestination logMessage:message];
    }
}

@end
```

---

## Migration Questions

### Q: How do I migrate from NSLog?

**A:** Replace NSLog calls with JKLoger macros:

```objc
// Before
NSLog(@"User %@ logged in", username);

// After
JKLogInfo(@"User %@ logged in", username);
```

### Q: How do I migrate from CocoaLumberjack?

**A:** The concepts are similar, but the setup is simpler:

```objc
// CocoaLumberjack setup
[DDLog addLogger:[DDOSLogger sharedInstance]];
[DDLog addLogger:[DDFileLogger new]];
DDLogInfo(@"Message");

// JKLoger equivalent
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
JKFileDestination *file = [[JKFileDestination alloc] init];
[[JKLogger sharedLogger] addDestination:console];
[[JKLogger sharedLogger] addDestination:file];
JKLogInfo(@"Message");
```

### Q: Can I use JKLoger alongside other logging libraries?

**A:** Yes! JKLoger doesn't interfere with other logging libraries. You can use them simultaneously or migrate gradually.

---

## Best Practices

### Q: What are the recommended log levels for different environments?

**A:**
- **Development**: `JKLogLevelDebug` - Show all messages for debugging
- **Staging**: `JKLogLevelInfo` - Show informational messages and above
- **Production**: `JKLogLevelWarning` - Only show warnings, errors, and fatal messages

### Q: How should I structure log messages?

**A:** Use consistent, structured formats:

```objc
// Good: Structured with context
JKLogInfo(@"User login | user_id=%@ | method=%@ | duration=%.2fs", userID, method, duration);

// Better: Use key-value pairs for parsing
JKLogInfo(@"event=user_login user_id=%@ auth_method=%@ response_time=%.3f", userID, method, responseTime);

// Best: Include all relevant context
JKLogInfo(@"user_action=login user_id=%@ session_id=%@ ip=%@ user_agent=%@ result=success", 
         userID, sessionID, ipAddress, userAgent);
```

### Q: Should I log personal information?

**A:** **Never log sensitive personal information!** This includes:
- Passwords, tokens, or API keys
- Credit card numbers or payment information
- Personal addresses or phone numbers
- Social security numbers or government IDs

Instead, log sanitized or hashed versions:
```objc
// Bad
JKLogInfo(@"User password: %@", password);

// Good
JKLogInfo(@"User authentication successful for user_id=%@", userID);

// For debugging, use partial information
NSString *tokenPrefix = [token substringToIndex:MIN(8, token.length)];
JKLogDebug(@"API token prefix: %@...", tokenPrefix);
```

---

## Support and Community

### Q: Where can I get help?

**A:** 
- **GitHub Issues**: Report bugs and request features at [GitHub Issues](https://github.com/Jaker/JKLoger/issues)
- **Documentation**: Check the [API Reference](API.md) and [Usage Guide](Usage.md)
- **Examples**: Look at the [Example project](../Example/README.md) for working code

### Q: How do I report a bug?

**A:** Please include:
1. JKLoger version
2. iOS version and device
3. Minimal code to reproduce the issue
4. Expected vs actual behavior
5. Console output or crash logs

### Q: How do I request a feature?

**A:** Open a GitHub issue with:
1. Clear description of the feature
2. Use case and benefits
3. Proposed API (if applicable)
4. Willingness to contribute

### Q: Can I contribute to JKLoger?

**A:** Absolutely! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines. We welcome:
- Bug fixes
- New features
- Documentation improvements
- Example code
- Performance optimizations

---

## Troubleshooting Checklist

If you're having issues with JKLoger, work through this checklist:

### ✅ Basic Setup
- [ ] JKLoger is properly installed and imported
- [ ] At least one destination is added to the logger
- [ ] Logger is enabled (`logger.enabled = YES`)
- [ ] Log level allows your messages (`logger.logLevel`)

### ✅ Console Logging
- [ ] Console destination is added
- [ ] Console destination log level is appropriate
- [ ] Using correct logging macros (`JKLogInfo`, etc.)
- [ ] Check Xcode console output

### ✅ File Logging
- [ ] File destination is configured
- [ ] Log directory exists and is writable
- [ ] Check `currentLogFilePath` property
- [ ] Verify files are created with `allLogFilePaths`

### ✅ Remote Logging
- [ ] Server URL is correct and reachable
- [ ] Network connectivity is available
- [ ] Authentication headers are correct
- [ ] Server accepts the log format being sent

### ✅ Performance Issues
- [ ] Not logging in tight loops without level checks
- [ ] Using appropriate log levels
- [ ] File destinations have reasonable size limits
- [ ] Remote destinations use batching

---

## Version History

### Q: What's new in version 1.0?

**A:** Initial release featuring:
- Core logging functionality with 5 log levels
- Console, file, and remote destinations
- Multiple formatter options
- Thread-safe operation
- Automatic file rotation
- Batched remote logging
- Comprehensive documentation and examples

### Q: Is JKLoger stable for production use?

**A:** Yes! Version 1.0 is production-ready with:
- Comprehensive test coverage
- Memory leak testing
- Performance benchmarking
- Real-world usage validation
- Stable API that follows semantic versioning

---

## Related Projects

### Q: Are there any extensions or plugins available?

**A:** While JKLoger is designed to be extensible, the core library includes all essential functionality. You can easily create custom destinations and formatters for specific needs.

### Q: Does JKLoger integrate with analytics services?

**A:** You can create custom destinations that forward logs to analytics services:

```objc
// Example: Analytics destination
@interface AnalyticsDestination : NSObject <JKLogDestination>
@end

@implementation AnalyticsDestination
- (void)logMessage:(JKLogMessage *)message {
    // Forward to your analytics service
    if (message.level <= JKLogLevelError) {
        [AnalyticsService trackError:message.message withMetadata:@{
            @"level": JKLogLevelToString(message.level),
            @"file": message.file,
            @"line": @(message.line)
        }];
    }
}
@end
```

---

Still have questions? Check our [GitHub Discussions](https://github.com/Jaker/JKLoger/discussions) or open an [issue](https://github.com/Jaker/JKLoger/issues)!