//
//  JKConsoleDestination.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../JKLogDestination.h"
#import "../JKLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 控制台输出目标
 * 将日志消息输出到控制台
 */
@interface JKConsoleDestination : NSObject <JKLogDestination>

/**
 * 日志格式化器
 */
@property (nonatomic, strong, nullable) id<JKLogFormatter> formatter;

/**
 * 该输出目标的最低日志等级
 */
@property (nonatomic, assign) JKLogLevel logLevel;

/**
 * 输出目标的名称
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * 是否使用 NSLog 输出
 * 默认为 YES，设置为 NO 时使用 printf 输出
 */
@property (nonatomic, assign) BOOL useNSLog;

/**
 * 初始化方法
 * @return 控制台输出目标实例
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END