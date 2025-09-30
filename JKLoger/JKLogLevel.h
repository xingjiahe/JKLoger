//
//  JKLogLevel.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 日志等级枚举
 * 数值越小，等级越高
 */
typedef NS_ENUM(NSUInteger, JKLogLevel) {
    JKLogLevelFatal = 0,    // 致命错误
    JKLogLevelError = 1,    // 错误
    JKLogLevelWarning = 2,  // 警告
    JKLogLevelInfo = 3,     // 信息
    JKLogLevelDebug = 4     // 调试
};

/**
 * 将日志等级转换为字符串
 * @param level 日志等级
 * @return 日志等级对应的字符串
 */
FOUNDATION_EXPORT NSString *JKLogLevelToString(JKLogLevel level);

/**
 * 从字符串解析日志等级
 * @param levelString 日志等级字符串
 * @return 对应的日志等级，如果解析失败返回 JKLogLevelInfo
 */
FOUNDATION_EXPORT JKLogLevel JKLogLevelFromString(NSString *levelString);

NS_ASSUME_NONNULL_END