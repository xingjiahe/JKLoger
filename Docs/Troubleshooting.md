# JKLoger Troubleshooting Guide

This guide helps you diagnose and resolve common issues with JKLoger.

## 🔍 Quick Diagnostics

### Check Logger Status

```objc
JKLogger *logger = [JKLogger sharedLogger];
NSLog(@"Logger enabled: %@", logger.enabled ? @"YES" : @"NO");
NSLog(@"Logger level: %@", JKLogLevelToString(logger.logLevel));
NSLog(@"Destinations count: %lu", (unsigned long)logger.destinations.count);

// List all destinations
for (id<JKLogDestination> destination in logger.destinations) {
    NSLog(@"Destination: %@", [destination class]);
    if ([destination respondsToSelector:@selector(logLevel)]) {
        NSLog(@"  - Level: %@", JKLogLevelToString(destination.logLevel));
    }
}
```

### Test Basic Logging

```objc
// Test each log level
JKLogFatal(@"🔴 Fatal test message");
JKLogError(@"🟠 Error test message");
JKLogWarning(@"🟡 Warning test message");
JKLogInfo(@"🔵 Info test message");
JKLogDebug(@"🟣 Debug test message");
```

---

## 🚫 Common Issues

### Issue: No Log Output Appears

**Symptoms:**
- Logging macros are called but no output is visible
- Console remains empty
- Log files are not created

**Diagnosis:**
```objc
// Check if logger is enabled
if (![JKLogger sharedLogger].enabled) {
    NSLog(@"❌ Logger is disabled");
}

// Check if destinations exist
if ([JKLogger sharedLogger].destinations.count == 0) {
    NSLog(@"❌ No destinations configured");
}

// Check log level
JKLogLevel currentLevel = [JKLogger sharedLogger].logLevel;
NSLog(@"Current log level: %@", JKLogLevelToString(currentLevel));
```

**Solutions:**
1. **Enable the logger:**
   ```objc
   [JKLogger sharedLogger].enabled = YES;
   ```

2. **Add at least one destination:**
   ```objc
   JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
   [[JKLogger sharedLogger] addDestination:console];
   ```

3. **Check log level:**
   ```objc
   [JKLogger sharedLogger].logLevel = JKLogLevelDebug; // Show all messages
   ```

---

### Issue: File Logging Not Working

**Symptoms:**
- Console logging works but files are not created
- Log directory is empty
- File destination seems configured correctly

**Diagnosis:**
```objc
JKFileDestination *fileDestination = /* your file destination */;

// Check configuration
NSLog(@"Log directory: %@", fileDestination.logDirectory);
NSLog(@"File prefix: %@", fileDestination.fileNamePrefix);
NSLog(@"Current file: %@", fileDestination.currentLogFilePath);

// Check directory permissions
NSFileManager *fm = [NSFileManager defaultManager];
BOOL isDir;
BOOL exists = [fm fileExistsAtPath:fileDestination.logDirectory isDirectory:&isDir];
NSLog(@"Directory exists: %@, is directory: %@", exists ? @"YES" : @"NO", isDir ? @"YES" : @"NO");

// Check if we can write to the directory
NSString *testFile = [fileDestination.logDirectory stringByAppendingPathComponent:@"test.txt"];
BOOL canWrite = [@"test" writeToFile:testFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
NSLog(@"Can write to directory: %@", canWrite ? @"YES" : @"NO");
[fm removeItemAtPath:testFile error:nil]; // Clean up

// List existing log files
NSArray<NSString *> *logFiles = [fileDestination allLogFilePaths];
NSLog(@"Existing log files: %@", logFiles);
```

**Solutions:**
1. **Check directory permissions:**
   ```objc
   // Use a writable directory
   NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
   NSString *logsPath = [documentsPath stringByAppendingPathComponent:@"Logs"];
   
   JKFileDestination *fileDestination = [[JKFileDestination alloc] initWithDirectory:logsPath];
   ```

2. **Enable immediate flush for testing:**
   ```objc
   fileDestination.immediateFlush = YES;
   ```

3. **Check file size limits:**
   ```objc
   // Ensure limits are reasonable
   fileDestination.maxFileSize = 10 * 1024 * 1024; // 10MB
   fileDestination.maxFileCount = 5;
   ```

---

### Issue: Remote Logging Fails

**Symptoms:**
- Local logging works but remote server doesn't receive logs
- Network requests time out
- Authentication errors

**Diagnosis:**
```objc
JKRemoteDestination *remote = /* your remote destination */;

// Check network availability
BOOL networkAvailable = [remote isNetworkAvailable];
NSLog(@"Network available: %@", networkAvailable ? @"YES" : @"NO");

// Test server connectivity
NSURLRequest *testRequest = [NSURLRequest requestWithURL:remote.serverURL];
NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:testRequest 
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
        NSLog(@"❌ Server connectivity test failed: %@", error);
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"✅ Server responded with status: %ld", (long)httpResponse.statusCode);
    }
}];
[task resume];

// Test with a single message
JKLogMessage *testMessage = [JKLogMessage messageWithLevel:JKLogLevelInfo
                                                   message:@"Test message"
                                                      file:__FILE__
                                                  function:__PRETTY_FUNCTION__
                                                      line:__LINE__];

[remote sendLogMessage:testMessage completion:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"✅ Remote logging test successful");
    } else {
        NSLog(@"❌ Remote logging test failed: %@", error);
    }
}];
```

**Solutions:**
1. **Check server URL:**
   ```objc
   // Ensure URL is correct and accessible
   NSURL *serverURL = [NSURL URLWithString:@"https://your-log-server.com/api/logs"];
   remote.serverURL = serverURL;
   ```

2. **Configure authentication:**
   ```objc
   remote.customHeaders = @{
       @"Authorization": @"Bearer your-api-token",
       @"Content-Type": @"application/json"
   };
   ```

3. **Adjust timeout and retry settings:**
   ```objc
   remote.requestTimeout = 30.0; // 30 seconds
   remote.maxRetryCount = 3;
   ```

4. **Check network permissions:**
   - Ensure your app has network access permissions
   - Check if corporate firewall blocks the requests
   - Verify SSL certificate if using HTTPS

---

### Issue: Performance Problems

**Symptoms:**
- App becomes slow when logging is enabled
- UI freezes during heavy logging
- Memory usage increases significantly

**Diagnosis:**
```objc
// Profile logging performance
- (void)profileLoggingPerformance {
    NSDate *startTime = [NSDate date];
    
    for (int i = 0; i < 1000; i++) {
        JKLogInfo(@"Performance test message %d with data: %@", i, @{@"key": @"value"});
    }
    
    NSTimeInterval duration = -[startTime timeIntervalSinceNow];
    NSLog(@"1000 log messages took %.3fs (%.3fms per message)", duration, duration * 1000 / 1000);
}

// Check memory usage
- (void)checkMemoryUsage {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    if (kerr == KERN_SUCCESS) {
        NSLog(@"Memory usage: %.2f MB", info.resident_size / (1024.0 * 1024.0));
    }
}
```

**Solutions:**
1. **Optimize log level checking:**
   ```objc
   // Avoid expensive operations in log messages
   // Bad:
   JKLogDebug(@"User data: %@", [self expensiveDataCalculation]);
   
   // Good:
   if ([JKLogger sharedLogger].logLevel >= JKLogLevelDebug) {
       NSDictionary *userData = [self expensiveDataCalculation];
       JKLogDebug(@"User data: %@", userData);
   }
   ```

2. **Use appropriate log levels:**
   ```objc
   #ifdef DEBUG
       [JKLogger sharedLogger].logLevel = JKLogLevelDebug;
   #else
       [JKLogger sharedLogger].logLevel = JKLogLevelWarning; // Reduce production logging
   #endif
   ```

3. **Configure file rotation:**
   ```objc
   JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
   fileDestination.maxFileSize = 5 * 1024 * 1024; // 5MB (smaller files)
   fileDestination.maxFileCount = 3; // Keep fewer files
   fileDestination.immediateFlush = NO; // Use buffering
   ```

4. **Optimize remote logging:**
   ```objc
   JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
   remote.batchSize = 50; // Larger batches
   remote.batchTimeout = 10.0; // Longer timeout
   remote.logLevel = JKLogLevelError; // Only send errors remotely
   ```

---

### Issue: Memory Leaks

**Symptoms:**
- Memory usage grows over time
- App receives memory warnings
- Instruments shows leaks in JKLoger code

**Diagnosis:**
```objc
// Check for retain cycles
- (void)checkForRetainCycles {
    __weak JKLogger *weakLogger = [JKLogger sharedLogger];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakLogger) {
            NSLog(@"Logger still alive (expected)");
        } else {
            NSLog(@"Logger was deallocated (unexpected)");
        }
    });
}

// Monitor destination count
NSLog(@"Destination count: %lu", (unsigned long)[JKLogger sharedLogger].destinations.count);
```

**Solutions:**
1. **Remove unused destinations:**
   ```objc
   // Remove specific destination
   [[JKLogger sharedLogger] removeDestination:oldDestination];
   
   // Remove all destinations
   [[JKLogger sharedLogger] removeAllDestinations];
   ```

2. **Check custom destination implementations:**
   ```objc
   // Ensure custom destinations don't create retain cycles
   @interface MyCustomDestination : NSObject <JKLogDestination>
   @property (nonatomic, weak) id delegate; // Use weak references
   @end
   ```

3. **Use Instruments to profile:**
   - Run your app with Instruments
   - Use the "Leaks" template
   - Look for leaks in JKLoger-related code

---

### Issue: Thread Safety Problems

**Symptoms:**
- Crashes in multi-threaded environments
- Inconsistent log output
- Race conditions

**Diagnosis:**
```objc
// Test concurrent logging
- (void)testConcurrentLogging {
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int j = 0; j < 100; j++) {
                JKLogInfo(@"Thread %d, Message %d", i, j);
            }
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"Concurrent logging test completed");
}
```

**Solutions:**
1. **JKLoger is thread-safe by design** - if you're seeing thread safety issues, check:
   - Custom destination implementations
   - Custom formatter implementations
   - External code that modifies logger configuration

2. **Ensure custom destinations are thread-safe:**
   ```objc
   @implementation MyCustomDestination {
       dispatch_queue_t _queue;
   }
   
   - (instancetype)init {
       if (self = [super init]) {
           _queue = dispatch_queue_create("com.myapp.logging", DISPATCH_QUEUE_SERIAL);
       }
       return self;
   }
   
   - (void)logMessage:(JKLogMessage *)message {
       dispatch_async(_queue, ^{
           // Your logging implementation
       });
   }
   @end
   ```

---

## 🛠 Debug Mode

Enable debug mode for detailed troubleshooting:

```objc
// Save current settings
JKLogLevel originalLevel = [JKLogger sharedLogger].logLevel;
NSArray *originalDestinations = [[JKLogger sharedLogger].destinations copy];

// Enable debug mode
[JKLogger sharedLogger].logLevel = JKLogLevelDebug;

// Add debug console with detailed formatter
JKConsoleDestination *debugConsole = [[JKConsoleDestination alloc] init];
debugConsole.formatter = [JKCustomFormatter detailedFormatter];
[[JKLogger sharedLogger] addDestination:debugConsole];

// Test logging
JKLogDebug(@"🔧 Debug mode enabled");
JKLogInfo(@"ℹ️ Testing log output");

// Restore original settings when done
// [JKLogger sharedLogger].logLevel = originalLevel;
// [[JKLogger sharedLogger] removeAllDestinations];
// for (id<JKLogDestination> destination in originalDestinations) {
//     [[JKLogger sharedLogger] addDestination:destination];
// }
```

---

## 📊 Performance Monitoring

### Benchmark Logging Performance

```objc
- (void)benchmarkLoggingPerformance {
    NSLog(@"🏃‍♂️ Starting performance benchmark...");
    
    // Test different scenarios
    [self benchmarkScenario:@"Console Only" block:^{
        JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
        [[JKLogger sharedLogger] addDestination:console];
    }];
    
    [self benchmarkScenario:@"File Only" block:^{
        JKFileDestination *file = [[JKFileDestination alloc] init];
        [[JKLogger sharedLogger] addDestination:file];
    }];
    
    [self benchmarkScenario:@"Multiple Destinations" block:^{
        [[JKLogger sharedLogger] addDestination:[[JKConsoleDestination alloc] init]];
        [[JKLogger sharedLogger] addDestination:[[JKFileDestination alloc] init]];
    }];
}

- (void)benchmarkScenario:(NSString *)name block:(void(^)(void))setupBlock {
    [[JKLogger sharedLogger] removeAllDestinations];
    setupBlock();
    
    NSDate *startTime = [NSDate date];
    for (int i = 0; i < 1000; i++) {
        JKLogInfo(@"Benchmark message %d", i);
    }
    NSTimeInterval duration = -[startTime timeIntervalSinceNow];
    
    NSLog(@"📈 %@: %.3fs (%.3fms per message)", name, duration, duration * 1000 / 1000);
}
```

### Monitor Memory Usage

```objc
- (void)monitorMemoryUsage {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    if (kerr == KERN_SUCCESS) {
        double memoryMB = info.resident_size / (1024.0 * 1024.0);
        JKLogInfo(@"📊 Memory usage: %.2f MB", memoryMB);
        
        if (memoryMB > 100.0) { // Adjust threshold as needed
            JKLogWarning(@"⚠️ High memory usage detected: %.2f MB", memoryMB);
        }
    }
}
```

---

## 🆘 Getting Help

If you're still experiencing issues:

1. **Check the [FAQ](FAQ.md)** for common questions
2. **Review the [API Documentation](API.md)** for detailed usage
3. **Look at the [Example Project](../Example/README.md)** for working code
4. **Search [GitHub Issues](https://github.com/Jaker/JKLoger/issues)** for similar problems
5. **Create a new issue** with:
   - JKLoger version
   - iOS version and device
   - Minimal code to reproduce the issue
   - Expected vs actual behavior
   - Console output or crash logs

### Issue Template

```markdown
**JKLoger Version:** 1.0.0
**iOS Version:** 17.0
**Device:** iPhone 15 Pro
**Xcode Version:** 15.0

**Description:**
Brief description of the issue

**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Behavior:**
What you expected to happen

**Actual Behavior:**
What actually happened

**Code Sample:**
```objc
// Minimal code to reproduce the issue
```

**Console Output:**
```
// Any relevant console output or error messages
```

**Additional Context:**
Any other relevant information
```

---

## 🔧 Advanced Debugging

### Custom Debug Destination

Create a debug destination that captures all log messages for analysis:

```objc
@interface DebugDestination : NSObject <JKLogDestination>
@property (nonatomic, strong) NSMutableArray<JKLogMessage *> *capturedMessages;
@end

@implementation DebugDestination

- (instancetype)init {
    if (self = [super init]) {
        _capturedMessages = [NSMutableArray array];
    }
    return self;
}

- (void)logMessage:(JKLogMessage *)message {
    [self.capturedMessages addObject:message];
    
    // Print detailed debug info
    NSLog(@"🔍 DEBUG: Level=%@ Thread=%@ Queue=%@ File=%@:%lu Function=%@ Message=%@",
          JKLogLevelToString(message.level),
          message.threadName,
          message.queueLabel ?: @"unknown",
          message.file,
          (unsigned long)message.line,
          message.function,
          message.message);
}

- (void)dumpCapturedMessages {
    NSLog(@"📋 Captured %lu messages:", (unsigned long)self.capturedMessages.count);
    for (JKLogMessage *message in self.capturedMessages) {
        NSLog(@"  - [%@] %@", JKLogLevelToString(message.level), message.message);
    }
}

@end

// Usage
DebugDestination *debugDest = [[DebugDestination alloc] init];
[[JKLogger sharedLogger] addDestination:debugDest];

// Later, analyze captured messages
[debugDest dumpCapturedMessages];
```

This troubleshooting guide should help you resolve most issues with JKLoger. Remember that JKLoger is designed to fail gracefully - logging problems should never crash your app!