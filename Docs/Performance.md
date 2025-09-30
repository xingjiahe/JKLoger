# Performance Guide

This guide provides best practices and optimization techniques for using JKLoger efficiently in production applications.

## Table of Contents

- [Performance Overview](#performance-overview)
- [Optimization Strategies](#optimization-strategies)
- [Benchmarking](#benchmarking)
- [Memory Management](#memory-management)
- [Production Recommendations](#production-recommendations)
- [Troubleshooting Performance Issues](#troubleshooting-performance-issues)

---

## Performance Overview

JKLoger is designed for high performance with minimal impact on your application:

- **Asynchronous Processing**: All logging operations are performed on a dedicated serial queue
- **Lazy Evaluation**: Message formatting is deferred until actually needed
- **Efficient Filtering**: Log level checks happen before expensive operations
- **Minimal Allocations**: Optimized object creation and memory usage

### Performance Characteristics

| Operation | Typical Time | Notes |
|-----------|--------------|-------|
| Log Level Check | < 1μs | Immediate return if filtered |
| Message Creation | 5-10μs | Includes string formatting |
| Queue Dispatch | 1-2μs | Async dispatch to logging queue |
| Console Output | 50-100μs | NSLog overhead |
| File Write | 10-50μs | Depends on storage speed |
| Remote Send | Variable | Network dependent |

---

## Optimization Strategies

### 1. Appropriate Log Levels

Use appropriate log levels to minimize processing overhead:

```objc
// ✅ Good - Production configuration
#ifdef DEBUG
    [JKLogger sharedLogger].logLevel = JKLogLevelDebug;
#else
    [JKLogger sharedLogger].logLevel = JKLogLevelWarning;
#endif

// ✅ Good - Per-destination filtering
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.logLevel = JKLogLevelInfo; // Less verbose for console

JKFileDestination *file = [[JKFileDestination alloc] init];
file.logLevel = JKLogLevelDebug; // More detailed for files

JKRemoteDestination *remote = [[JKRemoteDestination alloc] init];
remote.logLevel = JKLogLevelError; // Only errors to remote server
```

### 2. Lazy Message Formatting

Avoid expensive operations in log messages when possible:

```objc
// ❌ Poor - Always computes expensive operation
JKLogDebug(@"Data: %@", [self computeExpensiveDebugInfo]);

// ✅ Better - Check log level first
if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) {
    JKLogDebug(@"Data: %@", [self computeExpensiveDebugInfo]);
}

// ✅ Best - Use a helper macro
#define JKLogDebugLazy(fmt, block) \
    do { \
        if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) { \
            JKLogDebug(fmt, block()); \
        } \
    } while(0)

// Usage:
JKLogDebugLazy(@"Data: %@", ^{ return [self computeExpensiveDebugInfo]; });
```

### 3. Efficient String Formatting

Use efficient string formatting techniques:

```objc
// ✅ Good - Simple formatting
JKLogInfo(@"User %@ logged in", username);

// ✅ Good - Avoid complex string operations in logs
NSString *userInfo = [NSString stringWithFormat:@"%@:%@", username, userID];
JKLogInfo(@"User info: %@", userInfo);

// ❌ Avoid - Complex formatting in log statement
JKLogInfo(@"User %@ (ID: %@) from %@ logged in at %@", 
          username, userID, location, [formatter stringFromDate:[NSDate date]]);
```

### 4. Batch Remote Logging

Configure remote destinations for optimal batching:

```objc
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];

// Optimize batch settings
remote.batchSize = 50;           // Larger batches for efficiency
remote.batchTimeout = 30.0;      // Longer timeout for better batching
remote.maxRetryCount = 2;        // Fewer retries to avoid blocking

// Only send important messages remotely
remote.logLevel = JKLogLevelWarning;
```

### 5. File Destination Optimization

Configure file destinations for optimal I/O performance:

```objc
JKFileDestination *file = [[JKFileDestination alloc] init];

// Optimize file settings
file.maxFileSize = 50 * 1024 * 1024;  // 50MB - larger files reduce rotation overhead
file.maxFileCount = 3;                // Fewer files to manage
file.immediateFlush = NO;             // Buffer writes for better performance

// Use efficient formatter
file.formatter = [JKCustomFormatter compactFormatter]; // Less verbose formatting
```

### 6. Memory-Efficient Formatters

Choose formatters based on performance needs:

```objc
// ✅ Most efficient - Minimal formatting
JKCustomFormatter *compact = [JKCustomFormatter compactFormatter];

// ✅ Balanced - Good detail with reasonable performance
JKDefaultFormatter *standard = [[JKDefaultFormatter alloc] init];
standard.showThreadInfo = NO;  // Reduce string operations
standard.showFunctionInfo = NO;

// ⚠️ Use carefully - More expensive but detailed
JKCustomFormatter *detailed = [JKCustomFormatter detailedFormatter];

// ⚠️ Use sparingly - Most expensive
JKCustomFormatter *json = [JKCustomFormatter jsonFormatter];
```

---

## Benchmarking

### Performance Testing Setup

```objc
@interface JKPerformanceTester : NSObject
@end

@implementation JKPerformanceTester

+ (void)runPerformanceTests {
    [self testBasicLogging];
    [self testHighVolumeLogging];
    [self testFormatterPerformance];
    [self testDestinationPerformance];
}

+ (void)testBasicLogging {
    NSDate *startTime = [NSDate date];
    NSUInteger iterations = 10000;
    
    for (NSUInteger i = 0; i < iterations; i++) {
        JKLogInfo(@"Test message %lu", (unsigned long)i);
    }
    
    NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:startTime];
    NSTimeInterval avgTime = totalTime / iterations * 1000000; // microseconds
    
    NSLog(@"Basic logging: %.2f μs per message (%lu messages in %.3f seconds)", 
          avgTime, (unsigned long)iterations, totalTime);
}

+ (void)testHighVolumeLogging {
    NSDate *startTime = [NSDate date];
    NSUInteger iterations = 100000;
    
    // Test with different log levels
    for (NSUInteger i = 0; i < iterations; i++) {
        switch (i % 5) {
            case 0: JKLogDebug(@"Debug %lu", (unsigned long)i); break;
            case 1: JKLogInfo(@"Info %lu", (unsigned long)i); break;
            case 2: JKLogWarning(@"Warning %lu", (unsigned long)i); break;
            case 3: JKLogError(@"Error %lu", (unsigned long)i); break;
            case 4: JKLogFatal(@"Fatal %lu", (unsigned long)i); break;
        }
    }
    
    NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:startTime];
    NSTimeInterval avgTime = totalTime / iterations * 1000000;
    
    NSLog(@"High volume logging: %.2f μs per message (%lu messages in %.3f seconds)", 
          avgTime, (unsigned long)iterations, totalTime);
}

+ (void)testFormatterPerformance {
    JKLogMessage *testMessage = [[JKLogMessage alloc] initWithLevel:JKLogLevelInfo
                                                            message:@"Test message for performance testing"
                                                               file:__FILE__
                                                           function:__PRETTY_FUNCTION__
                                                               line:__LINE__];
    
    NSArray *formatters = @[
        [[JKDefaultFormatter alloc] init],
        [JKCustomFormatter compactFormatter],
        [JKCustomFormatter detailedFormatter],
        [JKCustomFormatter jsonFormatter]
    ];
    
    for (id<JKLogFormatter> formatter in formatters) {
        NSDate *startTime = [NSDate date];
        NSUInteger iterations = 10000;
        
        for (NSUInteger i = 0; i < iterations; i++) {
            [formatter formatLogMessage:testMessage];
        }
        
        NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:startTime];
        NSTimeInterval avgTime = totalTime / iterations * 1000000;
        
        NSLog(@"Formatter %@: %.2f μs per format", 
              formatter.name, avgTime);
    }
}

@end
```

### Memory Usage Testing

```objc
+ (void)testMemoryUsage {
    // Get initial memory usage
    NSUInteger initialMemory = [self getCurrentMemoryUsage];
    
    // Generate lots of log messages
    for (NSUInteger i = 0; i < 50000; i++) {
        JKLogInfo(@"Memory test message %lu with some additional data: %@", 
                 (unsigned long)i, @{@"key": @"value", @"number": @(i)});
    }
    
    // Wait for processing to complete
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
    
    NSUInteger finalMemory = [self getCurrentMemoryUsage];
    NSUInteger memoryIncrease = finalMemory - initialMemory;
    
    NSLog(@"Memory usage: Initial: %lu KB, Final: %lu KB, Increase: %lu KB", 
          (unsigned long)(initialMemory / 1024), 
          (unsigned long)(finalMemory / 1024),
          (unsigned long)(memoryIncrease / 1024));
}

+ (NSUInteger)getCurrentMemoryUsage {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0;
}
```

---

## Memory Management

### Understanding Memory Usage

JKLoger's memory footprint consists of:

1. **Logger Instance**: ~1KB (singleton)
2. **Destinations**: ~0.5KB each
3. **Formatters**: ~0.2KB each
4. **Message Objects**: ~0.5KB each (temporary)
5. **Queue Overhead**: ~2KB (dispatch queue)

### Memory Optimization Techniques

#### 1. Limit Message Retention

```objc
// Avoid keeping references to log messages
@interface MyCustomDestination : NSObject <JKLogDestination>
// ❌ Don't do this - retains all messages
@property (nonatomic, strong) NSMutableArray *allMessages;
@end

// ✅ Better - process and release immediately
- (void)logMessage:(JKLogMessage *)message {
    [self processMessage:message];
    // Message is automatically released after this method
}
```

#### 2. Efficient String Handling

```objc
// ✅ Good - Use string literals when possible
JKLogInfo(@"Static message");

// ✅ Good - Reuse formatters
static NSDateFormatter *sharedFormatter = nil;
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    sharedFormatter = [[NSDateFormatter alloc] init];
    sharedFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
});

// ❌ Avoid - Creating formatters repeatedly
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
JKLogInfo(@"Time: %@", [formatter stringFromDate:[NSDate date]]);
```

#### 3. File Buffer Management

```objc
@interface JKOptimizedFileDestination : JKFileDestination
@property (nonatomic, strong) NSMutableData *writeBuffer;
@property (nonatomic, assign) NSUInteger bufferSize;
@end

@implementation JKOptimizedFileDestination

- (instancetype)init {
    self = [super init];
    if (self) {
        _writeBuffer = [NSMutableData dataWithCapacity:8192]; // 8KB buffer
        _bufferSize = 8192;
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    NSString *formattedMessage = [self.formatter formatLogMessage:message];
    NSData *messageData = [formattedMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.writeBuffer appendData:messageData];
    
    // Flush buffer when full
    if (self.writeBuffer.length >= self.bufferSize) {
        [self flushBuffer];
    }
}

- (void)flushBuffer {
    if (self.writeBuffer.length > 0) {
        [self.currentFileHandle writeData:self.writeBuffer];
        [self.writeBuffer setLength:0]; // Clear buffer without deallocating
    }
}

@end
```

---

## Production Recommendations

### Configuration for Different Environments

#### Development Configuration

```objc
- (void)setupDevelopmentLogging {
    JKLogger *logger = [JKLogger sharedLogger];
    logger.logLevel = JKLogLevelDebug;
    
    // Verbose console output
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.formatter = [JKCustomFormatter colorfulFormatter];
    [logger addDestination:console];
    
    // Detailed file logging
    JKFileDestination *file = [[JKFileDestination alloc] init];
    file.formatter = [JKCustomFormatter detailedFormatter];
    file.immediateFlush = YES; // For debugging
    [logger addDestination:file];
}
```

#### Production Configuration

```objc
- (void)setupProductionLogging {
    JKLogger *logger = [JKLogger sharedLogger];
    logger.logLevel = JKLogLevelInfo;
    
    // Minimal console output
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.logLevel = JKLogLevelWarning; // Only warnings and errors
    console.formatter = [JKCustomFormatter compactFormatter];
    [logger addDestination:console];
    
    // Efficient file logging
    JKFileDestination *file = [[JKFileDestination alloc] init];
    file.maxFileSize = 20 * 1024 * 1024; // 20MB
    file.maxFileCount = 3;
    file.immediateFlush = NO; // Better performance
    file.formatter = [JKCustomFormatter jsonFormatter]; // Structured for analysis
    [logger addDestination:file];
    
    // Remote error reporting
    JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:errorReportingURL];
    remote.logLevel = JKLogLevelError; // Only errors and fatal
    remote.batchSize = 10;
    remote.batchTimeout = 60.0; // Batch for efficiency
    [logger addDestination:remote];
}
```

### Performance Monitoring

```objc
@interface JKProductionMonitor : NSObject
@property (nonatomic, assign) NSUInteger messageCount;
@property (nonatomic, assign) NSTimeInterval totalProcessingTime;
@end

@implementation JKProductionMonitor

- (instancetype)init {
    self = [super init];
    if (self) {
        // Monitor performance every 5 minutes
        [NSTimer scheduledTimerWithTimeInterval:300.0
                                         target:self
                                       selector:@selector(reportPerformanceMetrics)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)reportPerformanceMetrics {
    if (self.messageCount > 0) {
        NSTimeInterval avgTime = self.totalProcessingTime / self.messageCount;
        
        // Log performance metrics
        JKLogInfo(@"📊 Logging performance: %.2f ms avg, %lu messages in 5min", 
                 avgTime * 1000, (unsigned long)self.messageCount);
        
        // Alert if performance degrades
        if (avgTime > 0.001) { // 1ms threshold
            JKLogWarning(@"⚠️ Logging performance degraded: %.2f ms avg", avgTime * 1000);
        }
        
        // Reset counters
        self.messageCount = 0;
        self.totalProcessingTime = 0;
    }
}

@end
```

---

## Troubleshooting Performance Issues

### Common Performance Problems

#### 1. High CPU Usage

**Symptoms:**
- App becomes sluggish
- High CPU usage in profiler
- Logging queue shows high activity

**Solutions:**
```objc
// Reduce log verbosity
[JKLogger sharedLogger].logLevel = JKLogLevelWarning;

// Use more efficient formatters
console.formatter = [JKCustomFormatter compactFormatter];

// Reduce file I/O frequency
fileDestination.immediateFlush = NO;
```

#### 2. Memory Growth

**Symptoms:**
- Increasing memory usage over time
- Memory warnings
- App termination due to memory pressure

**Solutions:**
```objc
// Check for retained log messages
// Ensure destinations don't retain messages unnecessarily

// Reduce file buffer sizes
fileDestination.maxFileSize = 5 * 1024 * 1024; // Smaller files

// Limit remote batching
remoteDestination.batchSize = 10; // Smaller batches
```

#### 3. Slow App Launch

**Symptoms:**
- Increased app launch time
- Delayed UI responsiveness

**Solutions:**
```objc
// Defer logging setup to background queue
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [self setupLogging];
});

// Use lazy initialization
@property (nonatomic, strong) JKLogger *logger;
- (JKLogger *)logger {
    if (!_logger) {
        _logger = [JKLogger sharedLogger];
        // Configure logger...
    }
    return _logger;
}
```

### Performance Profiling Tools

#### 1. Instruments Integration

```objc
// Add signposts for Instruments profiling
#import <os/signpost.h>

@interface JKInstrumentsDestination : NSObject <JKLogDestination>
@property (nonatomic, assign) os_log_t osLog;
@end

@implementation JKInstrumentsDestination

- (instancetype)init {
    self = [super init];
    if (self) {
        _osLog = os_log_create("com.myapp.logging", "performance");
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    os_signpost_interval_begin(self.osLog, OS_SIGNPOST_ID_EXCLUSIVE, "LogProcessing");
    
    // Process message...
    
    os_signpost_interval_end(self.osLog, OS_SIGNPOST_ID_EXCLUSIVE, "LogProcessing");
}

@end
```

#### 2. Custom Performance Metrics

```objc
@interface JKPerformanceMetrics : NSObject
+ (void)recordLogProcessingTime:(NSTimeInterval)time;
+ (void)recordMemoryUsage:(NSUInteger)bytes;
+ (NSDictionary *)getMetrics;
@end

// Use in your destinations to track performance
- (void)logMessage:(JKLogMessage *)message {
    NSDate *startTime = [NSDate date];
    
    // Process message...
    
    NSTimeInterval processingTime = [[NSDate date] timeIntervalSinceDate:startTime];
    [JKPerformanceMetrics recordLogProcessingTime:processingTime];
}
```

---

## Summary

### Key Performance Guidelines

1. **Set appropriate log levels** for different environments
2. **Use efficient formatters** based on your needs
3. **Configure destinations optimally** for your use case
4. **Monitor performance** in production
5. **Profile regularly** to catch performance regressions
6. **Optimize for your specific use case** - balance detail vs. performance

### Performance Checklist

- [ ] Log levels configured appropriately for environment
- [ ] Expensive operations avoided in log statements
- [ ] Efficient formatters chosen for each destination
- [ ] File destinations configured with appropriate buffer sizes
- [ ] Remote destinations use batching effectively
- [ ] Memory usage monitored and optimized
- [ ] Performance metrics tracked in production
- [ ] Regular profiling performed

For more detailed information, see the [API Reference](API.md) and [Advanced Features Guide](AdvancedFeatures.md).