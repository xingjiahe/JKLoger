//
//  JKLogger.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKLogLevel.h"
#import "JKLogMessage.h"
#import "JKLogDestination.h"
#import "JKLogFormatter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * JKLoger 主日志管理器
 * 负责管理日志输出目标和处理日志消息
 */
@interface JKLogger : NSObject

/**
 * 获取共享的日志管理器实例
 * @return 单例对象
 */
+ (instancetype)sharedLogger;

/**
 * 全局日志等级
 * 只有等级不低于此值的日志才会被处理
 */
@property (nonatomic, assign) JKLogLevel logLevel;

/**
 * 是否启用日志功能
 * 默认为 YES
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * 添加日志输出目标
 * @param destination 输出目标对象
 */
- (void)addDestination:(id<JKLogDestination>)destination;

/**
 * 移除日志输出目标
 * @param destination 要移除的输出目标对象
 */
- (void)removeDestination:(id<JKLogDestination>)destination;

/**
 * 移除所有日志输出目标
 */
- (void)removeAllDestinations;

/**
 * 获取所有输出目标
 * @return 输出目标数组的副本
 */
- (NSArray<id<JKLogDestination>> *)destinations;

/**
 * 核心日志记录方法
 * @param level 日志等级
 * @param file 源文件名
 * @param function 函数名
 * @param line 行号
 * @param format 格式化字符串
 */
- (void)logWithLevel:(JKLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ... NS_FORMAT_FUNCTION(5,6);

/**
 * 使用 va_list 的日志记录方法
 * @param level 日志等级
 * @param file 源文件名
 * @param function 函数名
 * @param line 行号
 * @param format 格式化字符串
 * @param args 参数列表
 */
- (void)logWithLevel:(JKLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format
                args:(va_list)args;

@end

#pragma mark - 便利宏定义

/**
 * 日志宏定义
 * 提供简洁的日志记录接口
 */
#define JKLogFatal(fmt, ...)   [[JKLogger sharedLogger] logWithLevel:JKLogLevelFatal file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]
#define JKLogError(fmt, ...)   [[JKLogger sharedLogger] logWithLevel:JKLogLevelError file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]
#define JKLogWarning(fmt, ...) [[JKLogger sharedLogger] logWithLevel:JKLogLevelWarning file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]
#define JKLogInfo(fmt, ...)    [[JKLogger sharedLogger] logWithLevel:JKLogLevelInfo file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]
#define JKLogDebug(fmt, ...)   [[JKLogger sharedLogger] logWithLevel:JKLogLevelDebug file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]

/**
 * 条件编译宏 - 在 Release 模式下禁用 Debug 日志
 */
#ifdef DEBUG
    #define JKLogD(fmt, ...) JKLogDebug(fmt, ##__VA_ARGS__)
#else
    #define JKLogD(fmt, ...)
#endif

NS_ASSUME_NONNULL_END