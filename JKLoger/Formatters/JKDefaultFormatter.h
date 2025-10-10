//
//  JKDefaultFormatter.h
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JKLoger/JKLogFormatter.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 默认日志格式化器
 * 提供标准的日志格式化功能
 */
@interface JKDefaultFormatter : NSObject <JKLogFormatter>

/**
 * 格式化器的名称
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * 日期格式化器
 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/**
 * 是否显示线程信息
 * 默认为 YES
 */
@property (nonatomic, assign) BOOL showThreadInfo;

/**
 * 是否显示文件信息
 * 默认为 YES
 */
@property (nonatomic, assign) BOOL showFileInfo;

/**
 * 是否显示函数信息
 * 默认为 YES
 */
@property (nonatomic, assign) BOOL showFunctionInfo;

/**
 * 初始化方法
 * @return 默认格式化器实例
 */
- (instancetype)init;

/**
 * 使用自定义日期格式初始化
 * @param dateFormat 日期格式字符串
 * @return 默认格式化器实例
 */
- (instancetype)initWithDateFormat:(NSString *)dateFormat;

@end

NS_ASSUME_NONNULL_END