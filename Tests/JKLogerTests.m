//
//  JKLogerTests.m
//  JKLogerTests
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../JKLoger/JKLoger.h"

@interface JKLogerTests : XCTestCase

@end

@implementation JKLogerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[JKLogger sharedLogger] removeAllDestinations];
}

- (void)testLoggerSingleton {
    JKLogger *logger1 = [JKLogger sharedLogger];
    JKLogger *logger2 = [JKLogger sharedLogger];
    
    XCTAssertNotNil(logger1);
    XCTAssertNotNil(logger2);
    XCTAssertEqual(logger1, logger2, @"Logger should be singleton");
}

- (void)testLogLevelConversion {
    XCTAssertEqualObjects(JKLogLevelToString(JKLogLevelFatal), @"FATAL");
    XCTAssertEqualObjects(JKLogLevelToString(JKLogLevelError), @"ERROR");
    XCTAssertEqualObjects(JKLogLevelToString(JKLogLevelWarning), @"WARNING");
    XCTAssertEqualObjects(JKLogLevelToString(JKLogLevelInfo), @"INFO");
    XCTAssertEqualObjects(JKLogLevelToString(JKLogLevelDebug), @"DEBUG");
    
    XCTAssertEqual(JKLogLevelFromString(@"FATAL"), JKLogLevelFatal);
    XCTAssertEqual(JKLogLevelFromString(@"ERROR"), JKLogLevelError);
    XCTAssertEqual(JKLogLevelFromString(@"WARNING"), JKLogLevelWarning);
    XCTAssertEqual(JKLogLevelFromString(@"INFO"), JKLogLevelInfo);
    XCTAssertEqual(JKLogLevelFromString(@"DEBUG"), JKLogLevelDebug);
}

- (void)testLogMessageCreation {
    JKLogMessage *message = [[JKLogMessage alloc] initWithLevel:JKLogLevelInfo
                                                        message:@"Test message"
                                                           file:__FILE__
                                                       function:__PRETTY_FUNCTION__
                                                           line:__LINE__];
    
    XCTAssertNotNil(message);
    XCTAssertEqual(message.level, JKLogLevelInfo);
    XCTAssertEqualObjects(message.message, @"Test message");
    XCTAssertNotNil(message.file);
    XCTAssertNotNil(message.function);
    XCTAssertNotNil(message.timestamp);
    XCTAssertNotNil(message.threadName);
}

- (void)testConsoleDestination {
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    XCTAssertNotNil(console);
    XCTAssertEqualObjects(console.name, @"Console");
    XCTAssertEqual(console.logLevel, JKLogLevelDebug);
    XCTAssertTrue(console.useNSLog);
}

- (void)testDefaultFormatter {
    JKDefaultFormatter *formatter = [[JKDefaultFormatter alloc] init];
    XCTAssertNotNil(formatter);
    XCTAssertEqualObjects(formatter.name, @"DefaultFormatter");
    XCTAssertNotNil(formatter.dateFormatter);
    XCTAssertTrue(formatter.showThreadInfo);
    XCTAssertTrue(formatter.showFileInfo);
    XCTAssertTrue(formatter.showFunctionInfo);
}

- (void)testBasicLogging {
    JKLogger *logger = [JKLogger sharedLogger];
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    
    [logger addDestination:console];
    
    // Test basic logging macros
    JKLogInfo(@"This is an info message");
    JKLogError(@"This is an error message");
    JKLogDebug(@"This is a debug message with value: %d", 42);
    
    XCTAssertEqual(logger.destinations.count, 1);
}

- (void)testLogLevelFiltering {
    JKLogger *logger = [JKLogger sharedLogger];
    logger.logLevel = JKLogLevelWarning;
    
    JKConsoleDestination *console = [[JKConsoleDestination alloc] init];
    [logger addDestination:console];
    
    // These should be logged (Warning and above)
    JKLogFatal(@"Fatal message");
    JKLogError(@"Error message");
    JKLogWarning(@"Warning message");
    
    // These should be filtered out
    JKLogInfo(@"Info message - should not appear");
    JKLogDebug(@"Debug message - should not appear");
    
    XCTAssertEqual(logger.logLevel, JKLogLevelWarning);
}

@end