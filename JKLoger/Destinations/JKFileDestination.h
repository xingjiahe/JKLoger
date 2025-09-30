//
//  JKFileDestination.h
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
 * 文件输出目标
 * 将日志消息输出到文件，支持文件轮转和大小限制
 */
@interface JKFileDestination : NSObject <JKLogDestination>

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
 * 日志文件目录路径
 * 默认为 Documents/Logs/
 */
@property (nonatomic, copy) NSString *logDirectory;

/**
 * 日志文件名前缀
 * 默认为 "app"
 */
@property (nonatomic, copy) NSString *fileNamePrefix;

/**
 * 单个日志文件的最大大小（字节）
 * 默认为 10MB (10 * 1024 * 1024)
 */
@property (nonatomic, assign) NSUInteger maxFileSize;

/**
 * 最大保留的日志文件数量
 * 默认为 5 个文件
 */
@property (nonatomic, assign) NSUInteger maxFileCount;

/**
 * 是否立即刷新文件缓冲区
 * 默认为 NO，设置为 YES 可确保日志立即写入磁盘
 */
@property (nonatomic, assign) BOOL immediateFlush;

/**
 * 当前日志文件的完整路径
 */
@property (nonatomic, copy, readonly, nullable) NSString *currentLogFilePath;

/**
 * 初始化方法
 * @return 文件输出目标实例
 */
- (instancetype)init;

/**
 * 使用指定目录初始化
 * @param directory 日志文件目录路径
 * @return 文件输出目标实例
 */
- (instancetype)initWithDirectory:(NSString *)directory;

/**
 * 使用指定目录和文件名前缀初始化
 * @param directory 日志文件目录路径
 * @param prefix 文件名前缀
 * @return 文件输出目标实例
 */
- (instancetype)initWithDirectory:(NSString *)directory fileNamePrefix:(NSString *)prefix;

/**
 * 手动触发日志文件轮转
 * 当当前文件大小超过限制时会自动轮转，也可以手动调用此方法
 */
- (void)rotateLogFile;

/**
 * 清理旧的日志文件
 * 删除超过 maxFileCount 限制的旧文件
 */
- (void)cleanupOldLogFiles;

/**
 * 获取所有日志文件路径
 * @return 按创建时间排序的日志文件路径数组（最新的在前）
 */
- (NSArray<NSString *> *)allLogFilePaths;

@end

NS_ASSUME_NONNULL_END