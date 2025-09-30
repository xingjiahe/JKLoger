//
//  JKLogger.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKLogger.h"

@interface JKLogger ()

/**
 * 日志处理队列，确保线程安全
 */
@property (nonatomic, strong) dispatch_queue_t loggingQueue;

/**
 * 输出目标数组
 */
@property (nonatomic, strong) NSMutableArray<id<JKLogDestination>> *mutableDestinations;

@end

@implementation JKLogger

#pragma mark - Singleton

+ (instancetype)sharedLogger {
    static JKLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _loggingQueue = dispatch_queue_create("com.jaker.jklogger", DISPATCH_QUEUE_SERIAL);
        _mutableDestinations = [NSMutableArray array];
        _logLevel = JKLogLevelInfo;
        _enabled = YES;
    }
    return self;
}

#pragma mark - Public Methods

- (void)addDestination:(id<JKLogDestination>)destination {
    if (!destination) {
        return;
    }
    
    dispatch_async(self.loggingQueue, ^{
        if (![self.mutableDestinations containsObject:destination]) {
            [self.mutableDestinations addObject:destination];
        }
    });
}

- (void)removeDestination:(id<JKLogDestination>)destination {
    if (!destination) {
        return;
    }
    
    dispatch_async(self.loggingQueue, ^{
        [self.mutableDestinations removeObject:destination];
    });
}

- (void)removeAllDestinations {
    dispatch_async(self.loggingQueue, ^{
        [self.mutableDestinations removeAllObjects];
    });
}

- (NSArray<id<JKLogDestination>> *)destinations {
    __block NSArray *result;
    dispatch_sync(self.loggingQueue, ^{
        result = [self.mutableDestinations copy];
    });
    return result;
}

- (void)logWithLevel:(JKLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self logWithLevel:level file:file function:function line:line format:format args:args];
    va_end(args);
}

- (void)logWithLevel:(JKLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format
                args:(va_list)args {
    
    // 检查是否启用日志
    if (!self.enabled) {
        return;
    }
    
    // 检查日志等级
    if (level > self.logLevel) {
        return;
    }
    
    // 格式化消息
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    
    // 创建日志消息对象
    JKLogMessage *logMessage = [[JKLogMessage alloc] initWithLevel:level
                                                           message:message
                                                              file:file
                                                          function:function
                                                              line:line];
    
    // 异步处理日志消息
    dispatch_async(self.loggingQueue, ^{
        [self processLogMessage:logMessage];
    });
}

#pragma mark - Private Methods

/**
 * 处理日志消息，分发到各个输出目标
 */
- (void)processLogMessage:(JKLogMessage *)message {
    @try {
        for (id<JKLogDestination> destination in self.mutableDestinations) {
            // 检查输出目标的日志等级
            if ([destination respondsToSelector:@selector(logLevel)]) {
                if (message.level > destination.logLevel) {
                    continue;
                }
            }
            
            // 发送日志消息到输出目标
            [destination logMessage:message];
        }
    } @catch (NSException *exception) {
        // 日志库内部错误不应该影响应用程序
        // 使用 NSLog 输出错误信息到系统日志
        NSLog(@"JKLogger internal error: %@", exception);
    }
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> enabled=%@, logLevel=%@, destinations=%lu",
            NSStringFromClass([self class]),
            self,
            self.enabled ? @"YES" : @"NO",
            JKLogLevelToString(self.logLevel),
            (unsigned long)self.mutableDestinations.count];
}

@end