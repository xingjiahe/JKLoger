# Security Policy

## Supported Versions

We actively support the following versions of JKLoger with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of JKLoger seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@jkloger.com**

If you prefer, you can also use GitHub's private vulnerability reporting feature:
1. Go to the [Security tab](https://github.com/Jaker/JKLoger/security) of this repository
2. Click "Report a vulnerability"
3. Fill out the form with details about the vulnerability

### What to Include

Please include the following information in your report:

- **Description**: A clear description of the vulnerability
- **Impact**: What could an attacker accomplish by exploiting this vulnerability?
- **Reproduction**: Step-by-step instructions to reproduce the vulnerability
- **Affected Versions**: Which versions of JKLoger are affected
- **Environment**: iOS version, Xcode version, and any other relevant environment details
- **Proof of Concept**: If possible, include a minimal code example that demonstrates the vulnerability

### Example Report Format

```
Subject: [SECURITY] Potential vulnerability in JKLoger logging mechanism

Description:
A potential security vulnerability has been identified in the remote logging functionality...

Impact:
An attacker could potentially...

Reproduction Steps:
1. Configure JKLoger with remote destination
2. Set custom headers with...
3. Observe that...

Affected Versions:
JKLoger 1.0.0 and earlier

Environment:
- iOS 17.0
- Xcode 15.0
- Installation method: CocoaPods

Proof of Concept:
[Include minimal code example]
```

## Response Timeline

We will acknowledge receipt of your vulnerability report within **48 hours** and will send a more detailed response within **7 days** indicating the next steps in handling your report.

After the initial reply to your report, we will:
- Investigate and validate the vulnerability
- Develop a fix if the vulnerability is confirmed
- Prepare a security advisory
- Release a patched version
- Publicly disclose the vulnerability after a fix is available

We aim to resolve critical security vulnerabilities within **30 days** of the initial report.

## Security Considerations for JKLoger

### Data Privacy

JKLoger is designed with privacy in mind:

- **No Automatic PII Collection**: JKLoger does not automatically collect or log personally identifiable information
- **Developer Responsibility**: It is the developer's responsibility to ensure they do not log sensitive information
- **Local Storage**: File logging stores data locally on the device
- **Remote Logging**: When using remote logging, ensure your server endpoint uses HTTPS and proper authentication

### Best Practices

When using JKLoger in your applications:

1. **Avoid Logging Sensitive Data**:
   ```objc
   // ❌ Don't do this
   JKLogInfo(@"User password: %@", password);
   
   // ✅ Do this instead
   JKLogInfo(@"User authentication successful");
   ```

2. **Sanitize Data Before Logging**:
   ```objc
   // ✅ Sanitize sensitive information
   NSString *sanitizedToken = [token substringToIndex:MIN(8, token.length)];
   JKLogDebug(@"API token prefix: %@...", sanitizedToken);
   ```

3. **Secure Remote Logging**:
   ```objc
   // ✅ Use HTTPS and authentication
   NSURL *secureURL = [NSURL URLWithString:@"https://secure-logs.yourapp.com/api"];
   JKRemoteDestination *remote = [[JKRemoteDestination alloc] initWithServerURL:secureURL];
   remote.customHeaders = @{@"Authorization": @"Bearer secure-token"};
   ```

4. **Production Log Levels**:
   ```objc
   // ✅ Use appropriate log levels in production
   #ifdef DEBUG
       logger.logLevel = JKLogLevelDebug;
   #else
       logger.logLevel = JKLogLevelWarning; // Reduce information exposure
   #endif
   ```

### Known Security Considerations

1. **File Permissions**: Log files are created with standard iOS app sandbox permissions
2. **Network Security**: Remote logging uses standard HTTP/HTTPS protocols
3. **Memory Safety**: JKLoger uses ARC and follows iOS memory management best practices
4. **Thread Safety**: All operations are thread-safe using serial queues

### Security Updates

Security updates will be:
- Released as patch versions (e.g., 1.0.1, 1.0.2)
- Documented in the [CHANGELOG.md](CHANGELOG.md)
- Announced through GitHub releases
- Communicated via security advisories for critical issues

## Responsible Disclosure

We follow responsible disclosure practices:

1. **Private Reporting**: Security issues should be reported privately first
2. **Coordinated Disclosure**: We work with reporters to coordinate public disclosure
3. **Credit**: We will credit security researchers who report vulnerabilities (unless they prefer to remain anonymous)
4. **Timeline**: We aim for disclosure within 90 days of the initial report, or sooner if a fix is available

## Security Hall of Fame

We appreciate the security researchers who help keep JKLoger secure:

<!-- This section will be updated as we receive and address security reports -->
*No security vulnerabilities have been reported yet.*

## Contact

For security-related questions or concerns:
- **Email**: security@jkloger.com
- **GitHub**: Use private vulnerability reporting
- **General Questions**: Use GitHub Discussions for non-security related questions

## Legal

This security policy is provided in good faith. We reserve the right to modify this policy at any time. By reporting a vulnerability, you agree to:
- Allow us reasonable time to investigate and address the issue
- Not publicly disclose the vulnerability until we have had a chance to address it
- Not use the vulnerability for malicious purposes

Thank you for helping keep JKLoger and its users safe!