# Contributing to JKLoger

Thank you for your interest in contributing to JKLoger! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)

---

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please be respectful, inclusive, and constructive in all interactions.

### Our Standards

- **Be Respectful**: Treat everyone with respect and kindness
- **Be Inclusive**: Welcome contributors from all backgrounds and experience levels
- **Be Constructive**: Provide helpful feedback and suggestions
- **Be Professional**: Maintain a professional tone in all communications

---

## Getting Started

### Prerequisites

- **Xcode 12.0+**: Required for iOS development
- **iOS 13.0+**: Minimum deployment target
- **Git**: For version control
- **CocoaPods**: For dependency management (optional)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/JKLoger.git
   cd JKLoger
   ```

3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/Jaker/JKLoger.git
   ```

---

## Development Setup

### Project Structure

```
JKLoger/
├── JKLoger/                 # Core library source code
│   ├── JKLogger.h/.m       # Main logger implementation
│   ├── JKLogMessage.h/.m   # Log message encapsulation
│   ├── Destinations/       # Output destination implementations
│   └── Formatters/         # Message formatter implementations
├── Example/                # Example iOS application
├── Tests/                  # Unit and integration tests
├── Docs/                   # Documentation files
└── README.md              # Project overview
```

### Building the Project

1. **Open the workspace**:
   ```bash
   open JKLoger.xcworkspace
   ```

2. **Build the library**:
   - Select the JKLoger scheme
   - Build for iOS Simulator or Device
   - Ensure all targets compile successfully

3. **Run the example app**:
   ```bash
   cd Example
   pod install
   open JKLogerExample.xcworkspace
   ```

### Running Tests

```bash
# Run unit tests
xcodebuild test -workspace JKLoger.xcworkspace -scheme JKLoger -destination 'platform=iOS Simulator,name=iPhone 14'

# Run example app tests
cd Example
xcodebuild test -workspace JKLogerExample.xcworkspace -scheme JKLogerExample -destination 'platform=iOS Simulator,name=iPhone 14'
```

---

## Contributing Guidelines

### Types of Contributions

We welcome various types of contributions:

- **Bug Fixes**: Fix issues and improve stability
- **New Features**: Add new functionality or destinations/formatters
- **Performance Improvements**: Optimize existing code
- **Documentation**: Improve docs, examples, and guides
- **Testing**: Add or improve test coverage
- **Examples**: Create new usage examples or improve existing ones

### Coding Standards

#### Objective-C Style Guide

Follow these conventions for consistency:

```objc
// ✅ Good - Clear naming and documentation
/**
 * Processes a log message and sends it to all configured destinations.
 * @param message The log message to process
 */
- (void)processLogMessage:(JKLogMessage *)message {
    if (!message || !self.enabled) {
        return;
    }
    
    // Process message...
}

// ✅ Good - Proper property declarations
@property (nonatomic, strong, nullable) id<JKLogFormatter> formatter;
@property (nonatomic, assign) JKLogLevel logLevel;
@property (nonatomic, copy, readonly) NSString *name;

// ✅ Good - Error handling
@try {
    [self performOperation];
} @catch (NSException *exception) {
    NSLog(@"JKLoger: Operation failed: %@", exception.reason);
}
```

#### Code Organization

- **Header Files**: Keep public interfaces clean and well-documented
- **Implementation Files**: Use `#pragma mark` to organize code sections
- **Categories**: Use categories for extending functionality
- **Constants**: Define constants in header files with `FOUNDATION_EXPORT`

#### Naming Conventions

- **Classes**: Use `JK` prefix (e.g., `JKLogger`, `JKLogMessage`)
- **Methods**: Use descriptive names with proper parameter labels
- **Properties**: Use clear, descriptive names
- **Constants**: Use `k` prefix for constants (e.g., `kJKDefaultLogLevel`)

### Performance Considerations

- **Asynchronous Operations**: Keep the main thread responsive
- **Memory Management**: Use ARC properly, avoid retain cycles
- **String Operations**: Minimize string allocations in hot paths
- **Thread Safety**: Ensure thread-safe operations where needed

### Documentation Requirements

All public APIs must include:

```objc
/**
 * Brief description of what the method does.
 * 
 * Longer description if needed, including usage notes,
 * performance considerations, or important behavior.
 * 
 * @param parameter1 Description of first parameter
 * @param parameter2 Description of second parameter
 * @return Description of return value
 * 
 * @see RelatedClass
 * @since 1.0.0
 */
- (ReturnType *)methodName:(ParameterType *)parameter1 
            secondParameter:(AnotherType *)parameter2;
```

---

## Pull Request Process

### Before Submitting

1. **Create an Issue**: For significant changes, create an issue first to discuss the approach
2. **Branch Naming**: Use descriptive branch names:
   - `feature/add-custom-destination`
   - `bugfix/fix-memory-leak`
   - `docs/update-api-reference`

3. **Code Quality**: Ensure your code meets our standards:
   - Follows coding conventions
   - Includes appropriate tests
   - Has proper documentation
   - Passes all existing tests

### Submission Checklist

- [ ] Code follows the project's coding standards
- [ ] All tests pass (existing and new)
- [ ] Documentation is updated (if applicable)
- [ ] Example app demonstrates new features (if applicable)
- [ ] CHANGELOG.md is updated (for significant changes)
- [ ] Commit messages are clear and descriptive

### Pull Request Template

When creating a pull request, include:

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] Example app updated (if applicable)

## Checklist
- [ ] Code follows the style guidelines
- [ ] Self-review of code completed
- [ ] Code is commented, particularly in hard-to-understand areas
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process

1. **Automated Checks**: CI will run tests and checks automatically
2. **Code Review**: Maintainers will review your code for:
   - Correctness and functionality
   - Code quality and style
   - Performance implications
   - Documentation completeness
3. **Feedback**: Address any feedback from reviewers
4. **Approval**: Once approved, your PR will be merged

---

## Issue Reporting

### Bug Reports

Use the bug report template and include:

- **Environment**: iOS version, Xcode version, device type
- **JKLoger Version**: Which version you're using
- **Steps to Reproduce**: Clear, numbered steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Code Sample**: Minimal code that reproduces the issue
- **Logs**: Relevant log output or error messages

### Feature Requests

Use the feature request template and include:

- **Problem Description**: What problem does this solve?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other solutions you've considered
- **Use Cases**: Real-world scenarios where this would be useful

### Questions and Discussions

For questions about usage or implementation:

- Check existing documentation first
- Search existing issues
- Use GitHub Discussions for general questions
- Create an issue for specific problems

---

## Development Workflow

### Branching Strategy

- **main**: Stable release branch
- **develop**: Integration branch for new features
- **feature/***: Feature development branches
- **bugfix/***: Bug fix branches
- **release/***: Release preparation branches

### Commit Guidelines

Use clear, descriptive commit messages:

```bash
# Good commit messages
git commit -m "Add JSON formatter with customizable date format"
git commit -m "Fix memory leak in file destination cleanup"
git commit -m "Update API documentation for remote destination"

# Poor commit messages (avoid these)
git commit -m "Fix bug"
git commit -m "Update code"
git commit -m "WIP"
```

### Keeping Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Update your main branch
git checkout main
git merge upstream/main

# Update your feature branch
git checkout feature/your-feature
git rebase main
```

---

## Testing

### Test Categories

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test component interactions
3. **Performance Tests**: Verify performance characteristics
4. **Example Tests**: Ensure example code works correctly

### Writing Tests

```objc
// Example unit test
- (void)testLoggerSingleton {
    JKLogger *logger1 = [JKLogger sharedLogger];
    JKLogger *logger2 = [JKLogger sharedLogger];
    
    XCTAssertNotNil(logger1);
    XCTAssertEqual(logger1, logger2, @"Logger should be singleton");
}

// Example integration test
- (void)testFileDestinationLogging {
    JKFileDestination *destination = [[JKFileDestination alloc] init];
    JKLogMessage *message = [self createTestMessage];
    
    [destination logMessage:message];
    
    // Verify file was created and contains expected content
    XCTAssertTrue([self verifyLogFileContains:message.message]);
}
```

### Test Coverage

Aim for high test coverage, especially for:

- Core logging functionality
- All public APIs
- Error handling paths
- Edge cases and boundary conditions

---

## Documentation

### Types of Documentation

1. **API Reference**: Comprehensive API documentation
2. **Guides**: Getting started, advanced features, performance
3. **Examples**: Code samples and tutorials
4. **README**: Project overview and quick start

### Documentation Standards

- Use clear, concise language
- Include code examples for all features
- Keep examples up-to-date with the current API
- Use proper markdown formatting
- Include performance notes where relevant

### Updating Documentation

When adding features or changing APIs:

1. Update relevant documentation files
2. Add new examples if needed
3. Update the example app if applicable
4. Verify all links and references work

---

## Release Process

### Version Numbering

JKLoger follows [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers updated
- [ ] Example app works with new version
- [ ] Performance regression testing completed
- [ ] Release notes prepared

### Release Timeline

- **Major Releases**: Planned releases with significant new features
- **Minor Releases**: Regular feature releases (monthly/quarterly)
- **Patch Releases**: Bug fixes as needed

---

## Getting Help

### Resources

- **Documentation**: Check the [Docs](./Docs/) directory
- **Example App**: See [Example](./Example/) for usage patterns
- **Issues**: Search existing [GitHub Issues](https://github.com/Jaker/JKLoger/issues)
- **Discussions**: Use [GitHub Discussions](https://github.com/Jaker/JKLoger/discussions) for questions

### Contact

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: For security issues or private matters

---

## Recognition

Contributors will be recognized in:

- **CHANGELOG.md**: For significant contributions
- **README.md**: For major features or improvements
- **Release Notes**: For notable contributions

Thank you for contributing to JKLoger! Your efforts help make this library better for everyone. 🎉