# Changelog

All notable changes to JKLoger will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Swift bridging support improvements
- watchOS and tvOS support
- Advanced filtering capabilities
- Plugin architecture for custom destinations

## [1.0.0] - 2025-09-29

### Added
- Initial release of JKLoger
- Core logging functionality with 5 log levels (Fatal, Error, Warning, Info, Debug)
- Thread-safe asynchronous logging with serial queue processing
- Multiple output destinations:
  - **JKConsoleDestination**: Console output with NSLog/printf support
  - **JKFileDestination**: File output with automatic rotation and cleanup
  - **JKRemoteDestination**: HTTP-based remote logging with batching and retry logic
- Flexible formatting system:
  - **JKDefaultFormatter**: Standard formatting with configurable options
  - **JKCustomFormatter**: Advanced formatting with multiple styles (Default, Compact, Detailed, JSON, XML, Custom Template)
  - Color support for console output with ANSI codes
  - Custom template support with placeholder substitution
- Convenient macro interface:
  - `JKLogFatal`, `JKLogError`, `JKLogWarning`, `JKLogInfo`, `JKLogDebug`
  - `JKLogD` for debug-only logging (disabled in Release builds)
- Comprehensive metadata capture:
  - File name, line number, function name
  - Thread name and dispatch queue label
  - Precise timestamps with millisecond accuracy
- Package manager support:
  - CocoaPods integration with subspecs
  - Swift Package Manager support
- Performance optimizations:
  - Lazy message formatting
  - Efficient log level filtering
  - Minimal memory footprint
  - Optimized string operations
- Error handling and resilience:
  - Silent failure principle (logging errors don't crash the app)
  - Graceful degradation for failed destinations
  - Network resilience for remote logging
- File management features:
  - Configurable file size limits and rotation
  - Automatic cleanup of old log files
  - Custom log directory and file naming
  - Immediate flush option for critical logging
- Remote logging capabilities:
  - Configurable batching for efficiency
  - Custom HTTP headers support
  - Network availability checking
  - Exponential backoff for failed requests
- Comprehensive example application:
  - Interactive UI demonstrating all features
  - In-app log file viewer
  - Real-time configuration changes
  - Performance testing tools
- Complete documentation:
  - API reference with detailed examples
  - Getting started guide
  - Advanced features documentation
  - Performance optimization guide
- Testing infrastructure:
  - Unit tests for core functionality
  - Integration tests for destinations and formatters
  - Performance benchmarking tools
  - Memory usage monitoring

### Technical Details
- **Minimum iOS Version**: iOS 13.0+
- **Language**: Objective-C with ARC support
- **Thread Safety**: Full thread safety with serial queue processing
- **Memory Management**: Optimized for minimal memory usage
- **Performance**: Sub-microsecond log level checking, asynchronous processing
- **Dependencies**: Foundation framework only (SystemConfiguration for network checking)

### Package Information
- **CocoaPods**: Available as `JKLoger` with subspecs for modular usage
- **Swift Package Manager**: Full SPM support with proper module configuration
- **Manual Integration**: Source files can be directly added to projects

### Example Usage
```objc
// Basic setup
JKLogger *logger = [JKLogger sharedLogger];
logger.logLevel = JKLogLevelDebug;

// Add destinations
[logger addDestination:[[JKConsoleDestination alloc] init]];
[logger addDestination:[[JKFileDestination alloc] init]];

// Start logging
JKLogInfo(@"🚀 Application started");
JKLogError(@"❌ Network error: %@", error);
```

### Breaking Changes
- N/A (Initial release)

### Migration Guide
- N/A (Initial release)

### Known Issues
- SystemConfiguration APIs show deprecation warnings on macOS 14.4+ (functionality remains intact)
- Remote logging requires network permissions in app configuration

### Contributors
- **Jaker** - Initial development and design
- Community feedback and testing

---

## Release Notes Template

### [Version] - YYYY-MM-DD

#### Added
- New features and capabilities

#### Changed
- Changes to existing functionality

#### Deprecated
- Features that will be removed in future versions

#### Removed
- Features that have been removed

#### Fixed
- Bug fixes and corrections

#### Security
- Security-related improvements

---

## Versioning Strategy

JKLoger follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

### Version History

- **1.0.0**: Initial stable release with full feature set
- **0.x.x**: Pre-release development versions (not publicly released)

### Upgrade Guidelines

When upgrading JKLoger:

1. **Major Version Changes**: Review breaking changes and migration guide
2. **Minor Version Changes**: New features available, existing code continues to work
3. **Patch Version Changes**: Bug fixes only, safe to upgrade immediately

### Support Policy

- **Current Version (1.x)**: Full support with new features and bug fixes
- **Previous Major Version**: Security fixes and critical bug fixes only
- **Older Versions**: Community support only

For the latest updates and release information, visit the [GitHub Releases](https://github.com/Jaker/JKLoger/releases) page.