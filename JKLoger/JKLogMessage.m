//
//  JKLogMessage.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKLogMessage.h"

@implementation JKLogMessage

- (instancetype)initWithLevel:(JKLogLevel)level
                      message:(NSString *)message
                         file:(const char *)file
                     function:(const char *)function
                         line:(NSUInteger)line {
    self = [super init];
    if (self) {
        _level = level;
        _message = [message copy];
        _file = [self extractFileNameFromPath:file];
        _function = [[NSString alloc] initWithUTF8String:function];
        _line = line;
        _timestamp = [NSDate date];
        _threadName = [self currentThreadName];
        _queueLabel = [self currentQueueLabel];
    }
    return self;
}

+ (instancetype)messageWithLevel:(JKLogLevel)level
                         message:(NSString *)message
                            file:(const char *)file
                        function:(const char *)function
                            line:(NSUInteger)line {
    return [[self alloc] initWithLevel:level
                               message:message
                                  file:file
                              function:function
                                  line:line];
}

#pragma mark - Private Methods

/**
 * 从完整路径中提取文件名
 */
- (NSString *)extractFileNameFromPath:(const char *)filePath {
    if (!filePath) {
        return @"Unknown";
    }
    
    NSString *fullPath = [[NSString alloc] initWithUTF8String:filePath];
    return [fullPath lastPathComponent];
}

/**
 * 获取当前线程名称
 */
- (NSString *)currentThreadName {
    NSThread *currentThread = [NSThread currentThread];
    
    if ([currentThread isMainThread]) {
        return @"main";
    }
    
    NSString *threadName = currentThread.name;
    if (threadName && threadName.length > 0) {
        return threadName;
    }
    
    // 如果没有名称，使用线程描述
    return [NSString stringWithFormat:@"thread-%p", currentThread];
}

/**
 * 获取当前队列标签
 */
- (nullable NSString *)currentQueueLabel {
    const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    if (queueName) {
        return [[NSString alloc] initWithUTF8String:queueName];
    }
    return nil;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> level=%@, message=%@, file=%@:%lu, function=%@, timestamp=%@",
            NSStringFromClass([self class]),
            self,
            JKLogLevelToString(self.level),
            self.message,
            self.file,
            (unsigned long)self.line,
            self.function,
            self.timestamp];
}

@end