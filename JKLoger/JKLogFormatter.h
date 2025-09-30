//
//  JKLogFormatter.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JKLogMessage;

/**
 * 日志格式化器协议
 * 实现此协议的类可以自定义日志消息的格式化方式
 */
@protocol JKLogFormatter <NSObject>

@required
/**
 * 格式化日志消息
 * @param message 日志消息对象
 * @return 格式化后的字符串
 */
- (NSString *)formatLogMessage:(JKLogMessage *)message;

@optional
/**
 * 格式化器的名称标识
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * 日期格式化器，用于格式化时间戳
 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

NS_ASSUME_NONNULL_END