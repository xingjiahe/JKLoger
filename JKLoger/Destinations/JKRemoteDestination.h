//
//  JKRemoteDestination.h
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
 * 远程日志发送完成回调
 * @param success 是否发送成功
 * @param error 错误信息（如果有）
 */
typedef void (^JKRemoteLogCompletionBlock)(BOOL success, NSError * _Nullable error);

/**
 * 远程输出目标基础框架
 * 提供将日志发送到远程服务器的基础功能
 * 这是一个可扩展的示例实现
 */
@interface JKRemoteDestination : NSObject <JKLogDestination>

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
 * 远程服务器 URL
 */
@property (nonatomic, strong) NSURL *serverURL;

/**
 * HTTP 请求超时时间（秒）
 * 默认为 30 秒
 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/**
 * 最大重试次数
 * 默认为 3 次
 */
@property (nonatomic, assign) NSUInteger maxRetryCount;

/**
 * 批量发送的最大日志条数
 * 默认为 10 条，设置为 1 表示立即发送每条日志
 */
@property (nonatomic, assign) NSUInteger batchSize;

/**
 * 批量发送的最大等待时间（秒）
 * 默认为 5 秒，超过此时间会强制发送当前批次
 */
@property (nonatomic, assign) NSTimeInterval batchTimeout;

/**
 * 是否启用网络状态检查
 * 默认为 YES，只在网络可用时发送日志
 */
@property (nonatomic, assign) BOOL enableNetworkCheck;

/**
 * 自定义 HTTP 头部字段
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *customHeaders;

/**
 * 使用服务器 URL 初始化
 * @param serverURL 远程服务器 URL
 * @return 远程输出目标实例
 */
- (instancetype)initWithServerURL:(NSURL *)serverURL;

/**
 * 手动刷新待发送的日志
 * 立即发送当前批次中的所有日志
 */
- (void)flush;

/**
 * 手动发送单条日志消息
 * @param message 日志消息
 * @param completion 完成回调
 */
- (void)sendLogMessage:(JKLogMessage *)message completion:(nullable JKRemoteLogCompletionBlock)completion;

/**
 * 批量发送日志消息
 * @param messages 日志消息数组
 * @param completion 完成回调
 */
- (void)sendLogMessages:(NSArray<JKLogMessage *> *)messages completion:(nullable JKRemoteLogCompletionBlock)completion;

/**
 * 检查网络连接状态
 * @return YES 如果网络可用
 */
- (BOOL)isNetworkAvailable;

@end

NS_ASSUME_NONNULL_END