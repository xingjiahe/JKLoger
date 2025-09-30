//
//  JKConsoleDestination.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKConsoleDestination.h"
#import "../JKLogMessage.h"
#import "../JKLogFormatter.h"

@implementation JKConsoleDestination

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _logLevel = JKLogLevelDebug; // 默认输出所有等级
        _name = @"Console";
        _useNSLog = YES;
    }
    return self;
}

#pragma mark - JKLogDestination

- (void)logMessage:(JKLogMessage *)message {
    if (!message) {
        return;
    }
    
    // 检查日志等级
    if (message.level > self.logLevel) {
        return;
    }
    
    NSString *formattedMessage;
    
    // 使用格式化器格式化消息
    if (self.formatter) {
        formattedMessage = [self.formatter formatLogMessage:message];
    } else {
        // 使用默认格式
        formattedMessage = [self defaultFormatMessage:message];
    }
    
    // 输出到控制台
    if (self.useNSLog) {
        NSLog(@"%@", formattedMessage);
    } else {
        printf("%s\n", [formattedMessage UTF8String]);
        fflush(stdout);
    }
}

#pragma mark - Private Methods

/**
 * 默认的消息格式化方法
 */
- (NSString *)defaultFormatMessage:(JKLogMessage *)message {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    NSString *timestamp = [dateFormatter stringFromDate:message.timestamp];
    NSString *levelString = JKLogLevelToString(message.level);
    
    return [NSString stringWithFormat:@"%@ [%@] [%@] %@:%lu %@ - %@",
            timestamp,
            levelString,
            message.threadName,
            message.file,
            (unsigned long)message.line,
            message.function,
            message.message];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name=%@, logLevel=%@, useNSLog=%@",
            NSStringFromClass([self class]),
            self,
            self.name,
            JKLogLevelToString(self.logLevel),
            self.useNSLog ? @"YES" : @"NO"];
}

@end