//
//  JKCustomFormatter.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../JKLogFormatter.h"
#import "../JKLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 日志格式化样式
 */
typedef NS_ENUM(NSUInteger, JKLogFormatStyle) {
    JKLogFormatStyleDefault = 0,    // 默认格式
    JKLogFormatStyleCompact,        // 紧凑格式
    JKLogFormatStyleDetailed,       // 详细格式
    JKLogFormatStyleJSON,           // JSON 格式
    JKLogFormatStyleXML,            // XML 格式
    JKLogFormatStyleCustom          // 自定义格式
};

/**
 * 颜色代码枚举（用于控制台输出）
 */
typedef NS_ENUM(NSUInteger, JKLogColor) {
    JKLogColorNone = 0,
    JKLogColorRed,
    JKLogColorGreen,
    JKLogColorYellow,
    JKLogColorBlue,
    JKLogColorMagenta,
    JKLogColorCyan,
    JKLogColorWhite
};

/**
 * 自定义日志格式化器
 * 提供多种格式化样式和高级定制选项
 */
@interface JKCustomFormatter : NSObject <JKLogFormatter>

/**
 * 格式化器的名称
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * 日期格式化器
 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/**
 * 格式化样式
 */
@property (nonatomic, assign) JKLogFormatStyle formatStyle;

/**
 * 是否启用颜色输出（仅对控制台有效）
 */
@property (nonatomic, assign) BOOL enableColors;

/**
 * 是否显示毫秒
 */
@property (nonatomic, assign) BOOL showMilliseconds;

/**
 * 是否显示线程信息
 */
@property (nonatomic, assign) BOOL showThreadInfo;

/**
 * 是否显示文件信息
 */
@property (nonatomic, assign) BOOL showFileInfo;

/**
 * 是否显示函数信息
 */
@property (nonatomic, assign) BOOL showFunctionInfo;

/**
 * 是否显示队列信息
 */
@property (nonatomic, assign) BOOL showQueueInfo;

/**
 * 消息最大长度（0表示不限制）
 */
@property (nonatomic, assign) NSUInteger maxMessageLength;

/**
 * 自定义格式模板（当 formatStyle 为 JKLogFormatStyleCustom 时使用）
 * 支持的占位符：
 * {timestamp} - 时间戳
 * {level} - 日志等级
 * {thread} - 线程名
 * {queue} - 队列名
 * {file} - 文件名
 * {line} - 行号
 * {function} - 函数名
 * {message} - 消息内容
 */
@property (nonatomic, copy, nullable) NSString *customTemplate;

/**
 * 不同日志等级的颜色映射
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *levelColors;

/**
 * 初始化方法
 * @return 自定义格式化器实例
 */
- (instancetype)init;

/**
 * 使用指定样式初始化
 * @param style 格式化样式
 * @return 自定义格式化器实例
 */
- (instancetype)initWithStyle:(JKLogFormatStyle)style;

/**
 * 使用自定义模板初始化
 * @param template 自定义格式模板
 * @return 自定义格式化器实例
 */
- (instancetype)initWithCustomTemplate:(NSString *)template;

/**
 * 设置日志等级的颜色
 * @param color 颜色代码
 * @param level 日志等级
 */
- (void)setColor:(JKLogColor)color forLevel:(JKLogLevel)level;

/**
 * 获取预定义的格式化器
 */
+ (instancetype)compactFormatter;
+ (instancetype)detailedFormatter;
+ (instancetype)jsonFormatter;
+ (instancetype)xmlFormatter;
+ (instancetype)colorfulFormatter;

@end

NS_ASSUME_NONNULL_END