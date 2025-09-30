//
//  JKLogMessage.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 日志消息封装类
 * 包含日志的所有相关信息
 */
@interface JKLogMessage : NSObject

/**
 * 日志等级
 */
@property (nonatomic, assign, readonly) JKLogLevel level;

/**
 * 日志消息内容
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 * 源文件名
 */
@property (nonatomic, copy, readonly) NSString *file;

/**
 * 函数名
 */
@property (nonatomic, copy, readonly) NSString *function;

/**
 * 行号
 */
@property (nonatomic, assign, readonly) NSUInteger line;

/**
 * 时间戳
 */
@property (nonatomic, strong, readonly) NSDate *timestamp;

/**
 * 线程名称
 */
@property (nonatomic, copy, readonly) NSString *threadName;

/**
 * 队列标签
 */
@property (nonatomic, copy, readonly, nullable) NSString *queueLabel;

/**
 * 创建日志消息对象
 * @param level 日志等级
 * @param message 日志消息
 * @param file 源文件名
 * @param function 函数名
 * @param line 行号
 * @return 日志消息对象
 */
- (instancetype)initWithLevel:(JKLogLevel)level
                      message:(NSString *)message
                         file:(const char *)file
                     function:(const char *)function
                         line:(NSUInteger)line;

/**
 * 便利构造方法
 */
+ (instancetype)messageWithLevel:(JKLogLevel)level
                         message:(NSString *)message
                            file:(const char *)file
                        function:(const char *)function
                            line:(NSUInteger)line;

@end

NS_ASSUME_NONNULL_END