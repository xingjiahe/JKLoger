//
//  JKLogDestination.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

@class JKLogMessage;
@protocol JKLogFormatter;

/**
 * 日志输出目标协议
 * 实现此协议的类可以接收并处理日志消息
 */
@protocol JKLogDestination <NSObject>

@required
/**
 * 处理日志消息
 * @param message 日志消息对象
 */
- (void)logMessage:(JKLogMessage *)message;

@optional
/**
 * 日志格式化器，用于格式化日志消息
 */
@property (nonatomic, strong, nullable) id<JKLogFormatter> formatter;

/**
 * 该输出目标的最低日志等级
 * 只有等级不低于此值的日志才会被处理
 */
@property (nonatomic, assign) JKLogLevel logLevel;

/**
 * 输出目标的名称标识
 */
@property (nonatomic, copy, readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END