# JKLoger

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/xingjiahe/JKLoger)
[![Platform](https://img.shields.io/badge/platform-iOS%2013%2B-lightgrey.svg)](https://github.com/xingjiahe/JKLoger)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/xingjiahe/JKLoger/blob/main/LICENSE)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg)](https://cocoapods.org/pods/JKLoger)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

JKLoger is a lightweight, high-performance Objective-C logging library designed for iOS applications. It provides multiple log levels, extensible output destinations, customizable formatters, and thread-safe logging capabilities.

> **🌟 Perfect for production apps** - Lightweight, fast, and reliable logging with minimal performance impact.

## ✨ Features

- 🎯 **Multiple Log Levels**: Fatal, Error, Warning, Info, Debug with intelligent filtering
- 📤 **Extensible Destinations**: Console, File, Remote server with custom destination support
- 🎨 **Flexible Formatters**: Default, Compact, Detailed, JSON, XML, and custom template formatters
- 🔒 **Thread-Safe**: Asynchronous processing with serial queue for optimal performance
- 🚀 **Simple Interface**: Convenient macros for easy integration (`JKLogInfo`, `JKLogError`, etc.)
- 📱 **iOS 13+ Support**: Compatible with modern iOS versions and Xcode
- 📦 **Package Manager Support**: CocoaPods and Swift Package Manager integration
- 🔧 **Production Ready**: Optimized for performance with comprehensive error handling
- 📊 **Rich Metadata**: Automatic capture of file, line, function, thread, and timestamp information
- 🌐 **Remote Logging**: Built-in HTTP-based remote logging with batching and retry logic

## 安装

### CocoaPods

在你的 `Podfile` 中添加：

```ruby
pod 'JKLoger', '~> 1.0'
```

然后运行：

```bash
pod install
```

### Swift Package Manager

在 Xcode 中，选择 `File` > `Add Package Dependencies`，然后输入：

```
https://github.com/xingjiahe/JKLoger.git
```

或者在你的 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/xingjiahe/JKLoger.git", from: "1.0.0")
]
```

## 快速开始

## 🚀 Quick Start

### Basic Usage

```objc
#import <JKLoger/JKLoger.h>

// Use convenient macros for logging
JKLogInfo(@"🚀 Application started");
JKLogError(@"❌ Network error: %@", error);
JKLogDebug(@"🔍 Processing %lu items", (unsigned long)items.count);
JKLogWarning(@"⚠️ Memory usage high: %.1f%%", memoryUsage);
JKLogFatal(@"💀 Critical system failure");
```

### Setup in AppDelegate

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure JKLoger
    JKLogger *logger = [JKLogger sharedLogger];
    
    #ifdef DEBUG
        logger.logLevel = JKLogLevelDebug;
    #else
        logger.logLevel = JKLogLevelInfo;
    #endif
    
    // Add console output with colors
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    console.formatter = [JKCustomFormatter colorfulFormatter];
    [logger addDestination:console];
    
    // Add file output with JSON format
    JKFileDestination *fileDestination = [[JKFileDestination alloc] init];
    fileDestination.formatter = [JKCustomFormatter jsonFormatter];
    [logger addDestination:fileDestination];
    
    JKLogInfo(@"✅ Logging configured successfully");
    return YES;
}
```

### Advanced Configuration

```objc
// Multiple destinations with different levels
JKLogger *logger = [JKLogger sharedLogger];

// Console: Warnings and above
JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
console.logLevel = JKLogLevelWarning;
console.formatter = [JKCustomFormatter compactFormatter];
[logger addDestination:console];

// File: All messages with detailed format
JKFileDestination *file = [[JKFileDestination alloc] init];
file.maxFileSize = 10 * 1024 * 1024; // 10MB
file.maxFileCount = 5;
file.formatter = [JKCustomFormatter detailedFormatter];
[logger addDestination:file];

// Remote: Only errors with JSON format
NSURL *serverURL = [NSURL URLWithString:@"https://logs.myapp.com/api"];
JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:serverURL];
remote.logLevel = JKLogLevelError;
remote.formatter = [JKCustomFormatter jsonFormatter];
remote.customHeaders = @{@"Authorization": @"Bearer token"};
[logger addDestination:remote];
```

### Custom Templates

```objc
// Create custom format template
NSString *template = @"[{level}] {timestamp} | {file}:{line} | {message}";
JKCustomFormatter *customFormatter = [[JKCustomFormatter alloc] initWithCustomTemplate:template];

// Result: [INFO] 2025-09-29 16:20:30.123 | ViewController.m:42 | User logged in
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [📖 API Reference](./Docs/API.md) | Complete API documentation with examples |
| [🚀 Getting Started](./Docs/GettingStarted.md) | Quick setup guide and basic usage |
| [⚡ Advanced Features](./Docs/AdvancedFeatures.md) | Custom destinations, formatters, and patterns |
| [🔧 Performance Guide](./Docs/Performance.md) | Optimization tips and best practices |
| [📱 Example App](./Example/README.md) | Interactive demo showcasing all features |

### Log Levels

| Level | Macro | Description | Use Case |
|-------|-------|-------------|----------|
| Fatal | `JKLogFatal` | Critical system failures | App crashes, data corruption |
| Error | `JKLogError` | Error conditions | Network failures, API errors |
| Warning | `JKLogWarning` | Potential issues | Deprecated API usage, high memory |
| Info | `JKLogInfo` | General information | User actions, app lifecycle |
| Debug | `JKLogDebug` | Detailed debugging | Variable values, flow control |

### Core Components

- **JKLogger**: Main logging manager (singleton pattern)
- **JKLogMessage**: Log message encapsulation with metadata
- **JKConsoleDestination**: Console output with color support
- **JKFileDestination**: File output with rotation and cleanup
- **JKRemoteDestination**: HTTP-based remote logging
- **JKCustomFormatter**: Advanced formatting with multiple styles

## 示例项目

查看 `Example/` 目录中的示例项目，了解如何在实际应用中使用 JKLoger。

```bash
cd Example
open JKLogerExample.xcworkspace
```

## 贡献

欢迎贡献代码！请查看 [贡献指南](CONTRIBUTING.md) 了解详细信息。

## 许可证

JKLoger 使用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 作者

**xingjiahe** - [GitHub](https://github.com/xingjiahe)

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新信息。