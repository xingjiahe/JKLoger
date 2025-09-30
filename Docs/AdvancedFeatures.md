# Advanced Features Guide

This guide covers advanced features and customization options in JKLoger for power users and complex use cases.

## Table of Contents

- [Custom Destinations](#custom-destinations)
- [Custom Formatters](#custom-formatters)
- [Performance Optimization](#performance-optimization)
- [Thread Safety](#thread-safety)
- [Error Handling](#error-handling)
- [Integration Patterns](#integration-patterns)
- [Debugging and Monitoring](#debugging-and-monitoring)

---

## Custom Destinations

### Creating a Custom Destination

You can create custom destinations by implementing the `JKLogDestination` protocol:

```objc
@interface MyCustomDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) id<JKLogFormatter> formatter;
@property (nonatomic, assign) JKLogLevel logLevel;
@property (nonatomic, copy, readonly) NSString *name;
@end

@implementation MyCustomDestination

- (instancetype)init {
    self = [super init];
    if (self) {
        _logLevel = JKLogLevelDebug;
        _name = @"Custom";
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    // Check log level
    if (message.level > self.logLevel) {
        return;
    }
    
    // Format message
    NSString *formattedMessage;
    if (self.formatter) {
        formattedMessage = [self.formatter formatLogMessage:message];
    } else {
        formattedMessage = message.message;
    }
    
    // Process the message (send to database, external service, etc.)
    [self processMessage:formattedMessage withLevel:message.level];
}

- (void)processMessage:(NSString *)message withLevel:(JKLogLevel)level {
    // Your custom processing logic here
    // Examples: send to database, external API, system log, etc.
}

@end
```

### Database Destination Example

```objc
@interface JKDatabaseDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation JKDatabaseDestination

- (void)logMessage:(JKLogMessage *)message {
    if (message.level > self.logLevel) return;
    
    // Create Core Data entity
    NSManagedObject *logEntry = [NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" 
                                                              inManagedObjectContext:self.managedObjectContext];
    
    [logEntry setValue:@(message.level) forKey:@"level"];
    [logEntry setValue:message.message forKey:@"message"];
    [logEntry setValue:message.timestamp forKey:@"timestamp"];
    [logEntry setValue:message.file forKey:@"file"];
    [logEntry setValue:@(message.line) forKey:@"line"];
    
    // Save context
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to save log entry: %@", error);
    }
}

@end
```

### System Log Destination Example

```objc
@interface JKSystemLogDestination : NSObject <JKLogDestination>
@end

@implementation JKSystemLogDestination

- (void)logMessage:(JKLogMessage *)message {
    if (message.level > self.logLevel) return;
    
    // Map JKLoger levels to system log levels
    int priority;
    switch (message.level) {
        case JKLogLevelFatal:
        case JKLogLevelError:
            priority = LOG_ERR;
            break;
        case JKLogLevelWarning:
            priority = LOG_WARNING;
            break;
        case JKLogLevelInfo:
            priority = LOG_INFO;
            break;
        case JKLogLevelDebug:
        default:
            priority = LOG_DEBUG;
            break;
    }
    
    NSString *formattedMessage = self.formatter ? 
        [self.formatter formatLogMessage:message] : message.message;
    
    syslog(priority, "%s", [formattedMessage UTF8String]);
}

@end
```

---

## Custom Formatters

### Creating a Custom Formatter

Implement the `JKLogFormatter` protocol for custom message formatting:

```objc
@interface MyCustomFormatter : NSObject <JKLogFormatter>
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL includeEmojis;
@end

@implementation MyCustomFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"MyCustomFormatter";
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _includeEmojis = YES;
    }
    return self;
}

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    NSMutableString *result = [NSMutableString string];
    
    // Timestamp
    [result appendFormat:@"%@ ", [self.dateFormatter stringFromDate:message.timestamp]];
    
    // Level with emoji
    NSString *levelString = JKLogLevelToString(message.level);
    if (self.includeEmojis) {
        NSString *emoji = [self emojiForLevel:message.level];
        [result appendFormat:@"%@ %@ ", emoji, levelString];
    } else {
        [result appendFormat:@"[%@] ", levelString];
    }
    
    // Location info
    [result appendFormat:@"%@:%lu ", message.file, (unsigned long)message.line];
    
    // Message
    [result appendString:message.message];
    
    return [result copy];
}

- (NSString *)emojiForLevel:(JKLogLevel)level {
    switch (level) {
        case JKLogLevelFatal: return @"💀";
        case JKLogLevelError: return @"❌";
        case JKLogLevelWarning: return @"⚠️";
        case JKLogLevelInfo: return @"ℹ️";
        case JKLogLevelDebug: return @"🐛";
        default: return @"📝";
    }
}

@end
```

### Markdown Formatter Example

```objc
@interface JKMarkdownFormatter : NSObject <JKLogFormatter>
@end

@implementation JKMarkdownFormatter

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    NSString *levelString = JKLogLevelToString(message.level);
    NSString *timestamp = [self.dateFormatter stringFromDate:message.timestamp];
    
    // Create markdown format
    return [NSString stringWithFormat:@"## %@ - %@\n\n**File:** `%@:%lu`  \n**Function:** `%@`  \n**Thread:** `%@`  \n\n%@\n\n---\n",
            levelString, timestamp, message.file, (unsigned long)message.line, 
            message.function, message.threadName, message.message];
}

@end
```

### CSV Formatter Example

```objc
@interface JKCSVFormatter : NSObject <JKLogFormatter>
@end

@implementation JKCSVFormatter

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    // Escape CSV special characters
    NSString *escapedMessage = [self escapeCSVString:message.message];
    NSString *escapedFile = [self escapeCSVString:message.file];
    NSString *escapedFunction = [self escapeCSVString:message.function];
    
    return [NSString stringWithFormat:@"%.0f,%@,%@,%@,%lu,%@,%@",
            [message.timestamp timeIntervalSince1970] * 1000,
            JKLogLevelToString(message.level),
            message.threadName,
            escapedFile,
            (unsigned long)message.line,
            escapedFunction,
            escapedMessage];
}

- (NSString *)escapeCSVString:(NSString *)string {
    if ([string containsString:@","] || [string containsString:@"\""] || [string containsString:@"\n"]) {
        NSString *escaped = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        return [NSString stringWithFormat:@"\"%@\"", escaped];
    }
    return string;
}

@end
```

---

## Performance Optimization

### Lazy Message Formatting

For expensive message formatting, use blocks to defer computation:

```objc
// Instead of this (always computed):
JKLogDebug(@"Expensive computation result: %@", [self performExpensiveComputation]);

// Use this pattern for conditional logging:
if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) {
    JKLogDebug(@"Expensive computation result: %@", [self performExpensiveComputation]);
}

// Or create a custom macro:
#define JKLogDebugLazy(fmt, block) \
    if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) { \
        JKLogDebug(fmt, block()); \
    }

// Usage:
JKLogDebugLazy(@"Result: %@", ^{ return [self performExpensiveComputation]; });
```

### Batch Processing for Remote Destinations

```objc
@interface JKOptimizedRemoteDestination : JKRemoteDestination
@property (nonatomic, strong) NSMutableArray *pendingMessages;
@property (nonatomic, strong) NSTimer *flushTimer;
@end

@implementation JKOptimizedRemoteDestination

- (void)logMessage:(JKLogMessage *)message {
    // Add to batch
    [self.pendingMessages addObject:message];
    
    // Send immediately if batch is full or message is critical
    if (self.pendingMessages.count >= self.batchSize || message.level <= JKLogLevelError) {
        [self flushPendingMessages];
    } else {
        [self scheduleFlushTimer];
    }
}

- (void)flushPendingMessages {
    if (self.pendingMessages.count == 0) return;
    
    NSArray *messagesToSend = [self.pendingMessages copy];
    [self.pendingMessages removeAllObjects];
    
    [self sendLogMessages:messagesToSend completion:^(BOOL success, NSError *error) {
        if (!success) {
            // Re-queue failed messages (with limit to prevent infinite growth)
            if (self.pendingMessages.count < 1000) {
                [self.pendingMessages addObjectsFromArray:messagesToSend];
            }
        }
    }];
}

@end
```

### Memory-Efficient File Destination

```objc
@interface JKMemoryEfficientFileDestination : JKFileDestination
@property (nonatomic, strong) NSOperationQueue *fileOperationQueue;
@end

@implementation JKMemoryEfficientFileDestination

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileOperationQueue = [[NSOperationQueue alloc] init];
        _fileOperationQueue.maxConcurrentOperationCount = 1; // Serial queue
        _fileOperationQueue.name = @"JKFileDestination.FileOperations";
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    // Process on background queue to avoid blocking
    [self.fileOperationQueue addOperationWithBlock:^{
        [super logMessage:message];
    }];
}

@end
```

---

## Thread Safety

### Understanding JKLoger's Thread Safety

JKLoger is designed to be thread-safe:

1. **Logger Instance**: The shared logger can be accessed from any thread
2. **Destination Management**: Adding/removing destinations is thread-safe
3. **Message Processing**: All message processing is done on a serial queue
4. **Destination Callbacks**: Your destination's `logMessage:` method may be called from the logging queue

### Thread-Safe Custom Destinations

```objc
@interface JKThreadSafeDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong) NSMutableArray *messageBuffer;
@end

@implementation JKThreadSafeDestination

- (instancetype)init {
    self = [super init];
    if (self) {
        _processingQueue = dispatch_queue_create("com.myapp.logging", DISPATCH_QUEUE_SERIAL);
        _messageBuffer = [NSMutableArray array];
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    // Always process on our own queue for consistency
    dispatch_async(self.processingQueue, ^{
        [self processMessageSafely:message];
    });
}

- (void)processMessageSafely:(JKLogMessage *)message {
    // This method is always called on the same serial queue
    [self.messageBuffer addObject:message];
    
    // Process buffer when it reaches a certain size
    if (self.messageBuffer.count >= 10) {
        [self flushBuffer];
    }
}

@end
```

### Synchronous Logging for Critical Messages

```objc
@interface JKLogger (Synchronous)
- (void)logSynchronouslyWithLevel:(JKLogLevel)level
                             file:(const char *)file
                         function:(const char *)function
                             line:(NSUInteger)line
                           format:(NSString *)format, ...;
@end

@implementation JKLogger (Synchronous)

- (void)logSynchronouslyWithLevel:(JKLogLevel)level
                             file:(const char *)file
                         function:(const char *)function
                             line:(NSUInteger)line
                           format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    JKLogMessage *logMessage = [[JKLogMessage alloc] initWithLevel:level
                                                           message:message
                                                              file:file
                                                          function:function
                                                              line:line];
    
    // Process synchronously on the logging queue
    dispatch_sync(self.loggingQueue, ^{
        [self processLogMessage:logMessage];
    });
    
    va_end(args);
}

@end

// Usage for critical messages:
#define JKLogFatalSync(fmt, ...) \
    [[JKLogger sharedLogger] logSynchronouslyWithLevel:JKLogLevelFatal \
                                                  file:__FILE__ \
                                              function:__PRETTY_FUNCTION__ \
                                                  line:__LINE__ \
                                                format:(fmt), ##__VA_ARGS__]
```

---

## Error Handling

### Robust Destination Implementation

```objc
@interface JKRobustDestination : NSObject <JKLogDestination>
@property (nonatomic, assign) NSUInteger failureCount;
@property (nonatomic, strong) NSDate *lastFailureTime;
@property (nonatomic, assign) NSTimeInterval backoffInterval;
@end

@implementation JKRobustDestination

- (void)logMessage:(JKLogMessage *)message {
    // Implement exponential backoff for failed destinations
    if (self.lastFailureTime && 
        [[NSDate date] timeIntervalSinceDate:self.lastFailureTime] < self.backoffInterval) {
        return; // Skip logging during backoff period
    }
    
    @try {
        [self attemptToProcessMessage:message];
        
        // Reset failure count on success
        self.failureCount = 0;
        self.lastFailureTime = nil;
        self.backoffInterval = 0;
        
    } @catch (NSException *exception) {
        [self handleFailure:exception];
    }
}

- (void)handleFailure:(NSException *)exception {
    self.failureCount++;
    self.lastFailureTime = [NSDate date];
    
    // Exponential backoff: 1s, 2s, 4s, 8s, max 60s
    self.backoffInterval = MIN(pow(2, self.failureCount - 1), 60);
    
    // Log to system log as fallback
    NSLog(@"JKLoger destination failed: %@", exception.reason);
    
    // Disable destination after too many failures
    if (self.failureCount >= 10) {
        NSLog(@"JKLoger destination disabled after %lu failures", (unsigned long)self.failureCount);
        // Could remove self from logger here
    }
}

@end
```

### Graceful Degradation

```objc
@interface JKFallbackDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) id<JKLogDestination> primaryDestination;
@property (nonatomic, strong) id<JKLogDestination> fallbackDestination;
@end

@implementation JKFallbackDestination

- (void)logMessage:(JKLogMessage *)message {
    @try {
        [self.primaryDestination logMessage:message];
    } @catch (NSException *exception) {
        // Fall back to secondary destination
        @try {
            [self.fallbackDestination logMessage:message];
        } @catch (NSException *fallbackException) {
            // Last resort: system log
            NSLog(@"JKLoger: All destinations failed. Message: %@", message.message);
        }
    }
}

@end
```

---

## Integration Patterns

### Dependency Injection

```objc
@protocol LoggingService <NSObject>
- (void)logInfo:(NSString *)message;
- (void)logError:(NSString *)message;
- (void)logDebug:(NSString *)message;
@end

@interface JKLogerService : NSObject <LoggingService>
@property (nonatomic, strong) JKLogger *logger;
@end

@implementation JKLogerService

- (instancetype)initWithLogger:(JKLogger *)logger {
    self = [super init];
    if (self) {
        _logger = logger;
    }
    return self;
}

- (void)logInfo:(NSString *)message {
    [self.logger logWithLevel:JKLogLevelInfo 
                         file:__FILE__ 
                     function:__PRETTY_FUNCTION__ 
                         line:__LINE__ 
                       format:@"%@", message];
}

// Implement other methods...

@end

// Usage in your app:
@interface MyViewController : UIViewController
@property (nonatomic, strong) id<LoggingService> loggingService;
@end
```

### Category-Based Logging

```objc
@interface JKLogger (Categories)
- (void)logNetworkEvent:(NSString *)event withDetails:(NSDictionary *)details;
- (void)logUserAction:(NSString *)action withContext:(NSDictionary *)context;
- (void)logPerformanceMetric:(NSString *)metric value:(NSNumber *)value;
@end

@implementation JKLogger (Categories)

- (void)logNetworkEvent:(NSString *)event withDetails:(NSDictionary *)details {
    NSString *message = [NSString stringWithFormat:@"🌐 %@: %@", event, details];
    JKLogInfo(@"%@", message);
}

- (void)logUserAction:(NSString *)action withContext:(NSDictionary *)context {
    NSString *message = [NSString stringWithFormat:@"👤 %@: %@", action, context];
    JKLogInfo(@"%@", message);
}

- (void)logPerformanceMetric:(NSString *)metric value:(NSNumber *)value {
    NSString *message = [NSString stringWithFormat:@"📊 %@: %@", metric, value];
    JKLogDebug(@"%@", message);
}

@end
```

### Structured Logging

```objc
@interface JKStructuredLogger : NSObject
+ (void)logEvent:(NSString *)eventName 
      attributes:(NSDictionary *)attributes 
           level:(JKLogLevel)level;
@end

@implementation JKStructuredLogger

+ (void)logEvent:(NSString *)eventName 
      attributes:(NSDictionary *)attributes 
           level:(JKLogLevel)level {
    
    NSMutableDictionary *logData = [NSMutableDictionary dictionary];
    logData[@"event"] = eventName;
    logData[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    logData[@"attributes"] = attributes ?: @{};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logData 
                                                       options:0 
                                                         error:&error];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData 
                                                     encoding:NSUTF8StringEncoding];
        [[JKLogger sharedLogger] logWithLevel:level 
                                         file:__FILE__ 
                                     function:__PRETTY_FUNCTION__ 
                                         line:__LINE__ 
                                       format:@"%@", jsonString];
    }
}

@end

// Usage:
[JKStructuredLogger logEvent:@"user_login" 
                  attributes:@{@"user_id": @"12345", @"method": @"oauth"} 
                       level:JKLogLevelInfo];
```

---

## Debugging and Monitoring

### Logger Health Monitoring

```objc
@interface JKLoggerMonitor : NSObject
@property (nonatomic, assign) NSUInteger messageCount;
@property (nonatomic, assign) NSUInteger errorCount;
@property (nonatomic, strong) NSDate *lastMessageTime;
@end

@implementation JKLoggerMonitor

- (instancetype)init {
    self = [super init];
    if (self) {
        // Monitor logger activity
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageLogged:)
                                                     name:@"JKLoggerDidLogMessage"
                                                   object:nil];
        
        // Periodic health check
        [NSTimer scheduledTimerWithTimeInterval:60.0
                                         target:self
                                       selector:@selector(performHealthCheck)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)messageLogged:(NSNotification *)notification {
    self.messageCount++;
    self.lastMessageTime = [NSDate date];
    
    JKLogMessage *message = notification.userInfo[@"message"];
    if (message.level <= JKLogLevelError) {
        self.errorCount++;
    }
}

- (void)performHealthCheck {
    NSTimeInterval timeSinceLastMessage = [[NSDate date] timeIntervalSinceDate:self.lastMessageTime];
    
    if (timeSinceLastMessage > 300) { // 5 minutes
        NSLog(@"JKLogger: No messages logged in %.0f seconds", timeSinceLastMessage);
    }
    
    if (self.errorCount > 100) {
        NSLog(@"JKLogger: High error count: %lu", (unsigned long)self.errorCount);
    }
    
    // Reset counters
    self.messageCount = 0;
    self.errorCount = 0;
}

@end
```

### Performance Profiling

```objc
@interface JKPerformanceProfiler : NSObject <JKLogDestination>
@property (nonatomic, assign) NSTimeInterval totalProcessingTime;
@property (nonatomic, assign) NSUInteger messageCount;
@end

@implementation JKPerformanceProfiler

- (void)logMessage:(JKLogMessage *)message {
    NSDate *startTime = [NSDate date];
    
    // Simulate processing
    [NSThread sleepForTimeInterval:0.001]; // 1ms
    
    NSTimeInterval processingTime = [[NSDate date] timeIntervalSinceDate:startTime];
    self.totalProcessingTime += processingTime;
    self.messageCount++;
    
    // Log performance metrics periodically
    if (self.messageCount % 1000 == 0) {
        NSTimeInterval averageTime = self.totalProcessingTime / self.messageCount;
        NSLog(@"JKLogger Performance: Avg processing time: %.6f seconds per message", averageTime);
    }
}

@end
```

### Memory Usage Tracking

```objc
@interface JKMemoryTracker : NSObject <JKLogDestination>
@end

@implementation JKMemoryTracker

- (void)logMessage:(JKLogMessage *)message {
    static NSUInteger messageCount = 0;
    messageCount++;
    
    // Check memory usage every 100 messages
    if (messageCount % 100 == 0) {
        struct mach_task_basic_info info;
        mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
        kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
        
        if (kerr == KERN_SUCCESS) {
            NSUInteger memoryUsage = info.resident_size;
            NSLog(@"JKLogger Memory Usage: %lu bytes (%.2f MB)", 
                  (unsigned long)memoryUsage, memoryUsage / 1024.0 / 1024.0);
        }
    }
}

@end
```

---

## Best Practices Summary

1. **Custom Destinations**: Always implement proper error handling and thread safety
2. **Custom Formatters**: Keep formatting logic simple and fast
3. **Performance**: Use lazy evaluation for expensive operations
4. **Thread Safety**: Understand JKLoger's threading model and design accordingly
5. **Error Handling**: Implement graceful degradation and fallback mechanisms
6. **Monitoring**: Add health checks and performance monitoring for production use
7. **Memory Management**: Be mindful of memory usage, especially with high-volume logging

For more information, see the [API Reference](API.md) and [Getting Started Guide](GettingStarted.md).