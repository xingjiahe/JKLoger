# JKLoger Documentation

Welcome to the comprehensive documentation for JKLoger, a lightweight and extensible logging library for iOS applications.

## 📚 Documentation Overview

This documentation is organized to help you get started quickly and then dive deeper into advanced features as needed.

### 🚀 Getting Started

| Document | Description | Audience |
|----------|-------------|----------|
| [Getting Started Guide](GettingStarted.md) | Quick setup and basic usage | New users |
| [API Reference](API.md) | Complete API documentation with examples | All developers |
| [Usage Guide](Usage.md) | Practical examples and best practices | All developers |

### 🔧 Advanced Topics

| Document | Description | Audience |
|----------|-------------|----------|
| [Advanced Features](AdvancedFeatures.md) | Custom destinations, formatters, and patterns | Advanced users |
| [Performance Guide](Performance.md) | Optimization tips and best practices | Production apps |

### 🆘 Support & Troubleshooting

| Document | Description | Audience |
|----------|-------------|----------|
| [FAQ](FAQ.md) | Frequently asked questions and answers | All users |
| [Troubleshooting Guide](Troubleshooting.md) | Common issues and detailed solutions | All users |

### 📱 Examples and Tutorials

| Resource | Description | Level |
|----------|-------------|-------|
| [Example App](../Example/README.md) | Interactive demo with all features | Beginner to Advanced |
| [Code Examples](#code-examples) | Common usage patterns | All levels |

---

## 🎯 Quick Navigation

### By Use Case

**I want to...**

- **Get started quickly** → [Getting Started Guide](GettingStarted.md)
- **See all available APIs** → [API Reference](API.md)
- **Create custom destinations** → [Advanced Features - Custom Destinations](AdvancedFeatures.md#custom-destinations)
- **Optimize performance** → [Performance Guide](Performance.md)
- **See working examples** → [Example App](../Example/README.md)
- **Integrate with my CI/CD** → [Performance Guide - Production Recommendations](Performance.md#production-recommendations)

### By Experience Level

**Beginner Developers:**
1. Start with [Getting Started Guide](GettingStarted.md)
2. Try the [Example App](../Example/README.md)
3. Review [Common Use Cases](#common-use-cases)

**Experienced Developers:**
1. Skim [Getting Started Guide](GettingStarted.md) for setup
2. Jump to [API Reference](API.md) for detailed information
3. Explore [Advanced Features](AdvancedFeatures.md) for customization

**Production Apps:**
1. Review [Performance Guide](Performance.md)
2. Check [Advanced Features - Error Handling](AdvancedFeatures.md#error-handling)
3. Implement [Production Recommendations](Performance.md#production-recommendations)

---

## 📖 Documentation Structure

### Core Concepts

Understanding these concepts will help you use JKLoger effectively:

1. **Logger**: The main singleton that manages all logging operations
2. **Log Levels**: Hierarchical filtering system (Fatal → Error → Warning → Info → Debug)
3. **Destinations**: Where log messages are sent (Console, File, Remote)
4. **Formatters**: How log messages are formatted for output
5. **Messages**: Encapsulated log data with metadata

### Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your App      │───▶│    JKLogger      │───▶│  Destinations   │
│                 │    │   (Singleton)    │    │                 │
│ JKLogInfo(...)  │    │                  │    │ • Console       │
│ JKLogError(...) │    │ • Level Filter   │    │ • File          │
│ JKLogDebug(...) │    │ • Async Queue    │    │ • Remote        │
└─────────────────┘    │ • Thread Safety  │    │ • Custom        │
                       └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   JKLogMessage   │    │   Formatters    │
                       │                  │    │                 │
                       │ • Level          │    │ • Default       │
                       │ • Message        │    │ • Custom        │
                       │ • Timestamp      │    │ • JSON/XML      │
                       │ • File/Line      │    │ • Templates     │
                       │ • Thread Info    │    └─────────────────┘
                       └──────────────────┘
```

---

## 💡 Common Use Cases

### 1. Basic Application Logging

```objc
// Setup (in AppDelegate)
JKLogger *logger = [JKLogger sharedLogger];
[logger addDestination:[[JKConsoleDestination alloc] init]];

// Usage throughout your app
JKLogInfo(@"🚀 User %@ logged in", username);
JKLogError(@"❌ API request failed: %@", error);
```

### 2. Development vs Production Configuration

```objc
#ifdef DEBUG
    // Development: Verbose logging to console
    logger.logLevel = JKLogLevelDebug;
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.formatter = [JKCustomFormatter colorfulFormatter];
    [logger addDestination:console];
#else
    // Production: Minimal console, detailed file, error reporting
    logger.logLevel = JKLogLevelInfo;
    
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.logLevel = JKLogLevelWarning;
    [logger addDestination:console];
    
    JKFileDestination *file = [[JKFileDestination alloc] init];
    file.formatter = [JKCustomFormatter jsonFormatter];
    [logger addDestination:file];
    
    JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:errorURL];
    remote.logLevel = JKLogLevelError;
    [logger addDestination:remote];
#endif
```

### 3. Structured Logging for Analytics

```objc
// Create structured log entries
NSDictionary *userAction = @{
    @"action": @"purchase",
    @"item_id": @"12345",
    @"price": @29.99,
    @"currency": @"USD"
};

JKLogInfo(@"📊 User action: %@", userAction);
```

### 4. Performance Monitoring

```objc
- (void)performExpensiveOperation {
    NSDate *startTime = [NSDate date];
    JKLogDebug(@"⏱️ Starting expensive operation");
    
    // ... perform operation ...
    
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
    JKLogInfo(@"✅ Operation completed in %.3f seconds", duration);
    
    if (duration > 5.0) {
        JKLogWarning(@"⚠️ Operation took longer than expected: %.3f seconds", duration);
    }
}
```

### 5. Network Request Logging

```objc
- (void)performAPIRequest:(NSURLRequest *)request {
    JKLogInfo(@"🌐 API Request: %@ %@", request.HTTPMethod, request.URL);
    
    [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (error) {
            JKLogError(@"❌ API Error: %@ - %@", request.URL, error.localizedDescription);
        } else {
            JKLogInfo(@"✅ API Success: %@ - Status: %ld, Size: %lu bytes", 
                     request.URL, (long)httpResponse.statusCode, (unsigned long)data.length);
        }
    }];
}
```

---

## 🔍 Troubleshooting

### Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| No logs appearing | Silent application, no console output | Check log levels and destination configuration |
| Poor performance | App lag, high CPU usage | Review [Performance Guide](Performance.md) |
| File logging not working | No log files created | Check directory permissions and paths |
| Remote logging failing | Network errors, no server logs | Verify server URL and network connectivity |
| Memory issues | Increasing memory usage | Check for retained log messages and optimize formatters |

### Debug Checklist

1. **Verify Configuration**:
   ```objc
   JKLogger *logger = [JKLogger sharedLogger];
   NSLog(@"Logger enabled: %@", logger.enabled ? @"YES" : @"NO");
   NSLog(@"Log level: %@", JKLogLevelToString(logger.logLevel));
   NSLog(@"Destinations: %lu", (unsigned long)logger.destinations.count);
   ```

2. **Test Basic Functionality**:
   ```objc
   JKLogFatal(@"Test Fatal");
   JKLogError(@"Test Error");
   JKLogWarning(@"Test Warning");
   JKLogInfo(@"Test Info");
   JKLogDebug(@"Test Debug");
   ```

3. **Check Destination Status**:
   ```objc
   for (id<JKLogDestination> destination in logger.destinations) {
       NSLog(@"Destination: %@", destination);
   }
   ```

---

## 🚀 What's Next?

### Recommended Learning Path

1. **Start Here**: [Getting Started Guide](GettingStarted.md) (15 minutes)
2. **Try It**: Run the [Example App](../Example/README.md) (10 minutes)
3. **Integrate**: Add JKLoger to your project (30 minutes)
4. **Customize**: Explore [Advanced Features](AdvancedFeatures.md) (as needed)
5. **Optimize**: Review [Performance Guide](Performance.md) before production

### Stay Updated

- **GitHub**: Watch the repository for updates
- **Releases**: Check [GitHub Releases](https://github.com/Jaker/JKLoger/releases) for new versions
- **Changelog**: Review [CHANGELOG.md](../CHANGELOG.md) for detailed changes

### Contributing

Interested in contributing? See our [Contributing Guide](../CONTRIBUTING.md) for:
- Development setup
- Coding standards
- Pull request process
- Issue reporting guidelines

---

## 📞 Support

### Getting Help

1. **Documentation**: Search these docs first
2. **Example App**: Check if the example demonstrates your use case
3. **GitHub Issues**: Search existing issues for similar problems
4. **Create Issue**: Report bugs or request features
5. **Discussions**: Ask questions in GitHub Discussions

### Feedback

We value your feedback! Please let us know:
- What's working well
- What could be improved
- What features you'd like to see
- How you're using JKLoger in your projects

---

**Happy Logging!** 🎉

*JKLoger Documentation - Version 1.0.0*