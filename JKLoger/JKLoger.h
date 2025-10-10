//
//  JKLoger.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for JKLoger.
FOUNDATION_EXPORT double JKLogerVersionNumber;

//! Project version string for JKLoger.
FOUNDATION_EXPORT const unsigned char JKLogerVersionString[];

// Core Components
#import "JKLogLevel.h"
#import "JKLogMessage.h"
#import "JKLogger.h"

// Protocols
#import "JKLogDestination.h"
#import "JKLogFormatter.h"

// Destinations
#import <JKLoger/JKConsoleDestination.h>
#import <JKLoger/JKFileDestination.h>
#import <JKLoger/JKRemoteDestination.h>

// Formatters
#import <JKLoger/JKDefaultFormatter.h>
#import <JKLoger/JKCustomFormatter.h>

/**
 * JKLoger - A lightweight and extensible logging library for iOS
 * 
 * Features:
 * - Multiple log levels (Fatal, Error, Warning, Info, Debug)
 * - Extensible output destinations (Console, File, Remote)
 * - Customizable log formatters
 * - Thread-safe logging
 * - Simple macro interface
 * 
 * Basic Usage:
 * 
 * @code
 * // Import the main header
 * #import <JKLoger/JKLoger.h>
 * 
 * // Use the convenient macros
 * JKLogInfo(@"Application started");
 * JKLogError(@"Error occurred: %@", error);
 * JKLogDebug(@"Debug info: %d", value);
 * @endcode
 * 
 * Advanced Usage:
 * 
 * @code
 * // Configure logger
 * JKLogger *logger = [JKLogger sharedLogger];
 * logger.logLevel = JKLogLevelDebug;
 * 
 * // Add custom destinations
 * [logger addDestination:[[JKConsoleDestination alloc] init]];
 * [logger addDestination:[[JKFileDestination alloc] init]];
 * @endcode
 * 
 * @author Jaker
 * @version 1.0.0
 */