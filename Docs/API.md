# JKLoger API Reference

JKLoger is a lightweight and extensible logging library for iOS applications. This document provides comprehensive API documentation for all public classes and methods.

## Table of Contents

- [Core Classes](#core-classes)
  - [JKLogger](#jklogger)
  - [JKLogMessage](#jklogmessage)
  - [JKLogLevel](#jkloglevel)
- [Protocols](#protocols)
  - [JKLogDestination](#jklogdestination)
  - [JKLogFormatter](#jklogformatter)
- [Destinations](#destinations)
  - [JKConsoleDestination](#jkconsoledestination)
  - [JKFileDestination](#jkfiledestination)
  - [JKRemoteDestination](#jkremotedestination)
- [Formatters](#formatters)
  - [JKDefaultFormatter](#jkdefaultformatter)
  - [JKCustomFormatter](#jkcustomformatter)
- [Macros](#macros)
- [Constants](#constants)

---

## Core Classes

### JKLogger

The main logging manager class that handles log message processing and destination management.

#### Properties

```objc
@property (nonatomic, assign) JKLogLevel logLevel;
```
Global log level filter. Only messages with level equal to or higher priority than this value will be processed.

```objc
@property (nonatomic, assign) BOOL enabled;
```
Controls whether logging is enabled globally. Default is `YES`.

#### Class Methods

```objc
+ (instancetype)sharedLogger;
```
Returns the shared singleton instance of JKLogger.

**Returns:** The shared JKLogger instance.

#### Instance Methods

```objc
- (void)addDestination:(id<JKLogDestination>)destination;
```
Adds a log destination to receive log messages.

**Parameters:**
- `destination`: An object conforming to JKLogDestination protocol

```objc
- (void)removeDestination:(id<JKLogDestination>)destination;
```
Removes a log destination from the logger.

**Parameters:**
- `destination`: The destination object to remove

```objc
- (void)removeAllDestinations;
```
Removes all log destinations from the logger.

```objc
- (NSArray<id<JKLogDestination>> *)destinations;
```
Returns a copy of all currently registered destinations.

**Returns:** Array of destination objects

```objc
- (void)logWithLevel:(JKLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ...;
```
Core logging method. Usually called through convenience macros.

**Parameters:**
- `level`: Log level for this message
- `file`: Source file name (usually `__FILE__`)
- `function`: Function name (usually `__PRETTY_FUNCTION__`)
- `line`: Line number (usually `__LINE__`)
- `format`: Format string followed by arguments

---

### JKLogMessage

Encapsulates a single log message with all associated metadata.

#### Properties

```objc
@property (nonatomic, assign, readonly) JKLogLevel level;
```
The log level of this message.

```objc
@property (nonatomic, copy, readonly) NSString *message;
```
The formatted message content.

```objc
@property (nonatomic, copy, readonly) NSString *file;
```
The source file name where the log was generated.

```objc
@property (nonatomic, copy, readonly) NSString *function;
```
The function name where the log was generated.

```objc
@property (nonatomic, assign, readonly) NSUInteger line;
```
The line number where the log was generated.

```objc
@property (nonatomic, strong, readonly) NSDate *timestamp;
```
The timestamp when the log message was created.

```objc
@property (nonatomic, copy, readonly) NSString *threadName;
```
The name of the thread that generated the log message.

```objc
@property (nonatomic, copy, readonly, nullable) NSString *queueLabel;
```
The dispatch queue label where the log was generated.

#### Instance Methods

```objc
- (instancetype)initWithLevel:(JKLogLevel)level
                      message:(NSString *)message
                         file:(const char *)file
                     function:(const char *)function
                         line:(NSUInteger)line;
```
Designated initializer for creating log message objects.

```objc
+ (instancetype)messageWithLevel:(JKLogLevel)level
                         message:(NSString *)message
                            file:(const char *)file
                        function:(const char *)function
                            line:(NSUInteger)line;
```
Convenience class method for creating log message objects.

---

### JKLogLevel

Enumeration defining log levels in order of priority.

```objc
typedef NS_ENUM(NSUInteger, JKLogLevel) {
    JKLogLevelFatal = 0,    // Highest priority
    JKLogLevelError = 1,
    JKLogLevelWarning = 2,
    JKLogLevelInfo = 3,
    JKLogLevelDebug = 4     // Lowest priority
};
```

#### Utility Functions

```objc
NSString *JKLogLevelToString(JKLogLevel level);
```
Converts a log level to its string representation.

```objc
JKLogLevel JKLogLevelFromString(NSString *levelString);
```
Parses a log level from its string representation.

---

## Protocols

### JKLogDestination

Protocol for objects that can receive and process log messages.

#### Required Methods

```objc
- (void)logMessage:(JKLogMessage *)message;
```
Called when a log message should be processed by this destination.

#### Optional Properties

```objc
@property (nonatomic, strong, nullable) id<JKLogFormatter> formatter;
```
Formatter used to format log messages for this destination.

```objc
@property (nonatomic, assign) JKLogLevel logLevel;
```
Minimum log level for this destination. Messages below this level are ignored.

```objc
@property (nonatomic, copy, readonly) NSString *name;
```
Human-readable name for this destination.

---

### JKLogFormatter

Protocol for objects that can format log messages into strings.

#### Required Methods

```objc
- (NSString *)formatLogMessage:(JKLogMessage *)message;
```
Formats a log message into a string representation.

**Parameters:**
- `message`: The log message to format

**Returns:** Formatted string representation

#### Optional Properties

```objc
@property (nonatomic, copy, readonly) NSString *name;
```
Human-readable name for this formatter.

```objc
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
```
Date formatter used for timestamp formatting.

---

## Destinations

### JKConsoleDestination

Outputs log messages to the console using NSLog or printf.

#### Properties

```objc
@property (nonatomic, assign) BOOL useNSLog;
```
Whether to use NSLog (YES) or printf (NO) for output. Default is YES.

#### Example Usage

```objc
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.useNSLog = NO; // Use printf instead of NSLog
console.formatter = [JKCustomFormatter colorfulFormatter];
[[JKLogger sharedLogger] addDestination:console];
```

---

### JKFileDestination

Outputs log messages to files with automatic rotation and cleanup.

#### Properties

```objc
@property (nonatomic, copy) NSString *logDirectory;
```
Directory where log files are stored. Default is Documents/Logs/.

```objc
@property (nonatomic, copy) NSString *fileNamePrefix;
```
Prefix for log file names. Default is "app".

```objc
@property (nonatomic, assign) NSUInteger maxFileSize;
```
Maximum size for a single log file in bytes. Default is 10MB.

```objc
@property (nonatomic, assign) NSUInteger maxFileCount;
```
Maximum number of log files to keep. Default is 5.

```objc
@property (nonatomic, assign) BOOL immediateFlush;
```
Whether to flush file buffer immediately after each write. Default is NO.

```objc
@property (nonatomic, copy, readonly, nullable) NSString *currentLogFilePath;
```
Path to the currently active log file.

#### Instance Methods

```objc
- (instancetype)initWithDirectory:(NSString *)directory;
```
Initialize with custom log directory.

```objc
- (instancetype)initWithDirectory:(NSString *)directory fileNamePrefix:(NSString *)prefix;
```
Initialize with custom directory and file prefix.

```objc
- (void)rotateLogFile;
```
Manually trigger log file rotation.

```objc
- (void)cleanupOldLogFiles;
```
Manually trigger cleanup of old log files.

```objc
- (NSArray<NSString *> *)allLogFilePaths;
```
Get paths to all log files, sorted by modification date (newest first).

#### Example Usage

```objc
JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
fileDestination.maxFileSize = 5 * 1024 * 1024; // 5MB
fileDestination.maxFileCount = 3;
fileDestination.immediateFlush = YES;
fileDestination.formatter = [JKCustomFormatter jsonFormatter];
[[JKLogger sharedLogger] addDestination:fileDestination];
```

---

### JKRemoteDestination

Sends log messages to a remote server via HTTP POST requests.

#### Properties

```objc
@property (nonatomic, strong) NSURL *serverURL;
```
URL of the remote logging server.

```objc
@property (nonatomic, assign) NSTimeInterval requestTimeout;
```
HTTP request timeout in seconds. Default is 30.

```objc
@property (nonatomic, assign) NSUInteger maxRetryCount;
```
Maximum number of retry attempts for failed requests. Default is 3.

```objc
@property (nonatomic, assign) NSUInteger batchSize;
```
Number of log messages to batch before sending. Default is 10.

```objc
@property (nonatomic, assign) NSTimeInterval batchTimeout;
```
Maximum time to wait before sending a partial batch. Default is 5 seconds.

```objc
@property (nonatomic, assign) BOOL enableNetworkCheck;
```
Whether to check network availability before sending. Default is YES.

```objc
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *customHeaders;
```
Custom HTTP headers to include in requests.

#### Instance Methods

```objc
- (instancetype)initWithServerURL:(NSURL *)serverURL;
```
Initialize with server URL.

```objc
- (void)flush;
```
Immediately send all pending log messages.

```objc
- (void)sendLogMessage:(JKLogMessage *)message completion:(nullable JKRemoteLogCompletionBlock)completion;
```
Send a single log message with completion callback.

```objc
- (BOOL)isNetworkAvailable;
```
Check if network is currently available.

#### Example Usage

```objc
NSURL *serverURL = [NSURL URLWithString:@"https://logs.example.com/api/logs"];
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
remote.batchSize = 5;
remote.customHeaders = @{@"Authorization": @"Bearer token123"};
[[JKLogger sharedLogger] addDestination:remote];
```

---

## Formatters

### JKDefaultFormatter

Simple formatter with configurable display options.

#### Properties

```objc
@property (nonatomic, assign) BOOL showThreadInfo;
```
Whether to include thread information. Default is YES.

```objc
@property (nonatomic, assign) BOOL showFileInfo;
```
Whether to include file and line information. Default is YES.

```objc
@property (nonatomic, assign) BOOL showFunctionInfo;
```
Whether to include function information. Default is YES.

#### Example Usage

```objc
JKDefaultFormatter *formatter = [[JKDefaultFormatter alloc] init];
formatter.showThreadInfo = NO;
formatter.dateFormatter.dateFormat = @"HH:mm:ss";
```

---

### JKCustomFormatter

Advanced formatter with multiple styles and customization options.

#### Enumerations

```objc
typedef NS_ENUM(NSUInteger, JKLogFormatStyle) {
    JKLogFormatStyleDefault = 0,
    JKLogFormatStyleCompact,
    JKLogFormatStyleDetailed,
    JKLogFormatStyleJSON,
    JKLogFormatStyleXML,
    JKLogFormatStyleCustom
};
```

```objc
typedef NS_ENUM(NSUInteger, JKLogColor) {
    JKLogColorNone = 0,
    JKLogColorRed,
    JKLogColorGreen,
    JKLogColorYellow,
    JKLogColorBlue,
    JKLogColorMagenta,
    JKLogColorCyan,
    JKLogColorWhite
};
```

#### Properties

```objc
@property (nonatomic, assign) JKLogFormatStyle formatStyle;
```
The formatting style to use.

```objc
@property (nonatomic, assign) BOOL enableColors;
```
Whether to include ANSI color codes. Default is NO.

```objc
@property (nonatomic, assign) NSUInteger maxMessageLength;
```
Maximum message length before truncation. 0 means no limit.

```objc
@property (nonatomic, copy, nullable) NSString *customTemplate;
```
Custom format template for JKLogFormatStyleCustom.

#### Class Methods

```objc
+ (instancetype)compactFormatter;
+ (instancetype)detailedFormatter;
+ (instancetype)jsonFormatter;
+ (instancetype)xmlFormatter;
+ (instancetype)colorfulFormatter;
```
Convenience methods for creating pre-configured formatters.

#### Instance Methods

```objc
- (instancetype)initWithStyle:(JKLogFormatStyle)style;
```
Initialize with specific format style.

```objc
- (instancetype)initWithCustomTemplate:(NSString *)template;
```
Initialize with custom template.

```objc
- (void)setColor:(JKLogColor)color forLevel:(JKLogLevel)level;
```
Set color for specific log level.

#### Custom Template Placeholders

When using `JKLogFormatStyleCustom`, the following placeholders are available:

- `{timestamp}` - Formatted timestamp
- `{level}` - Log level string
- `{thread}` - Thread name
- `{queue}` - Queue label
- `{file}` - File name
- `{line}` - Line number
- `{function}` - Function name
- `{message}` - Log message content

#### Example Usage

```objc
// JSON formatter
JKCustomFormatter *jsonFormatter = [JKCustomFormatter jsonFormatter];

// Custom template
NSString *template = @"[{level}] {timestamp} | {file}:{line} | {message}";
JKCustomFormatter *customFormatter = [[JKCustomFormatter alloc] initWithCustomTemplate:template];

// Colorful formatter
JKCustomFormatter *colorFormatter = [JKCustomFormatter colorfulFormatter];
[colorFormatter setColor:JKLogColorRed forLevel:JKLogLevelError];
```

---

## Macros

Convenience macros for logging at different levels:

```objc
JKLogFatal(fmt, ...)    // Log fatal error
JKLogError(fmt, ...)    // Log error
JKLogWarning(fmt, ...)  // Log warning
JKLogInfo(fmt, ...)     // Log info
JKLogDebug(fmt, ...)    // Log debug
JKLogD(fmt, ...)        // Debug-only logging (disabled in Release builds)
```

### Example Usage

```objc
JKLogInfo(@"User %@ logged in", username);
JKLogError(@"Network request failed: %@", error);
JKLogDebug(@"Processing %lu items", (unsigned long)items.count);
```

---

## Constants

### Error Domains

```objc
extern NSString * const JKLogerErrorDomain;
```

### Notification Names

```objc
extern NSString * const JKLoggerDidAddDestinationNotification;
extern NSString * const JKLoggerDidRemoveDestinationNotification;
```

---

## Best Practices

### Performance Considerations

1. **Log Level Filtering**: Set appropriate log levels for production vs development
2. **Async Processing**: All logging is asynchronous by default
3. **File Rotation**: Configure appropriate file sizes and counts
4. **Batch Remote Logging**: Use batching for remote destinations

### Memory Management

1. **ARC Compatible**: JKLoger is fully ARC compatible
2. **Weak References**: Destinations don't retain the logger
3. **Thread Safety**: All operations are thread-safe

### Error Handling

1. **Silent Failures**: Logging errors don't crash the app
2. **Fallback Behavior**: Failed destinations don't affect others
3. **Network Resilience**: Remote logging handles network failures gracefully

---

## Migration Guide

### From Other Logging Libraries

#### From CocoaLumberjack

```objc
// CocoaLumberjack
DDLogInfo(@"Message");

// JKLoger
JKLogInfo(@"Message");
```

#### From NSLog

```objc
// NSLog
NSLog(@"User: %@", user);

// JKLoger
JKLogInfo(@"User: %@", user);
```

### Version Compatibility

- **iOS 13.0+**: Full feature support
- **Objective-C**: Primary language support
- **Swift**: Compatible via bridging headers

---

## Troubleshooting

### Common Issues

1. **No Log Output**: Check log level settings and destination configuration
2. **File Permission Errors**: Ensure app has write access to log directory
3. **Network Failures**: Check server URL and network connectivity
4. **Performance Issues**: Reduce log verbosity or adjust batch sizes

### Debug Tips

1. Enable console logging to see immediate output
2. Use the logger status methods to check configuration
3. Monitor file sizes and rotation behavior
4. Test network destinations with simple HTTP servers

---

For more examples and advanced usage, see the [Example App](../Example/README.md) and [Getting Started Guide](GettingStarted.md).