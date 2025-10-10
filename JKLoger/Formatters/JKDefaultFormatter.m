//
//  JKDefaultFormatter.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKDefaultFormatter.h"
#import <JKLoger/JKLogMessage.h>
#import <JKLoger/JKLogLevel.h>

@implementation JKDefaultFormatter

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
}

- (instancetype)initWithDateFormat:(NSString *)dateFormat {
    self = [super init];
    if (self) {
        _name = @"DefaultFormatter";
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = dateFormat ?: @"yyyy-MM-dd HH:mm:ss.SSS";
        _showThreadInfo = YES;
        _showFileInfo = YES;
        _showFunctionInfo = YES;
    }
    return self;
}

#pragma mark - JKLogFormatter

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    if (!message) {
        return @"";
    }
    
    NSMutableString *formattedMessage = [NSMutableString string];
    
    // 时间戳
    NSString *timestamp = [self.dateFormatter stringFromDate:message.timestamp];
    [formattedMessage appendFormat:@"%@ ", timestamp];
    
    // 日志等级
    NSString *levelString = JKLogLevelToString(message.level);
    [formattedMessage appendFormat:@"[%@] ", levelString];
    
    // 线程信息
    if (self.showThreadInfo) {
        [formattedMessage appendFormat:@"[%@] ", message.threadName];
    }
    
    // 文件和行号信息
    if (self.showFileInfo) {
        [formattedMessage appendFormat:@"%@:%lu ", message.file, (unsigned long)message.line];
    }
    
    // 函数信息
    if (self.showFunctionInfo) {
        [formattedMessage appendFormat:@"%@ ", message.function];
    }
    
    // 分隔符
    [formattedMessage appendString:@"- "];
    
    // 消息内容
    [formattedMessage appendString:message.message];
    
    return [formattedMessage copy];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name=%@, dateFormat=%@, showThreadInfo=%@, showFileInfo=%@, showFunctionInfo=%@",
            NSStringFromClass([self class]),
            self,
            self.name,
            self.dateFormatter.dateFormat,
            self.showThreadInfo ? @"YES" : @"NO",
            self.showFileInfo ? @"YES" : @"NO",
            self.showFunctionInfo ? @"YES" : @"NO"];
}

@end