//
//  JKCustomFormatter.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKCustomFormatter.h"
#import "../JKLogMessage.h"
#import "../JKLogLevel.h"

@implementation JKCustomFormatter

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithStyle:JKLogFormatStyleDefault];
}

- (instancetype)initWithStyle:(JKLogFormatStyle)style {
    self = [super init];
    if (self) {
        _name = @"CustomFormatter";
        _formatStyle = style;
        _enableColors = NO;
        _showMilliseconds = YES;
        _showThreadInfo = YES;
        _showFileInfo = YES;
        _showFunctionInfo = YES;
        _showQueueInfo = NO;
        _maxMessageLength = 0; // 不限制
        
        // 设置默认日期格式
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        
        // 设置默认颜色映射
        _levelColors = @{
            @(JKLogLevelFatal): @(JKLogColorRed),
            @(JKLogLevelError): @(JKLogColorRed),
            @(JKLogLevelWarning): @(JKLogColorYellow),
            @(JKLogLevelInfo): @(JKLogColorGreen),
            @(JKLogLevelDebug): @(JKLogColorCyan)
        };
        
        [self configureForStyle:style];
    }
    return self;
}

- (instancetype)initWithCustomTemplate:(NSString *)template {
    self = [self initWithStyle:JKLogFormatStyleCustom];
    if (self) {
        _customTemplate = [template copy];
    }
    return self;
}

#pragma mark - JKLogFormatter

- (NSString *)formatLogMessage:(JKLogMessage *)message {
    if (!message) {
        return @"";
    }
    
    switch (self.formatStyle) {
        case JKLogFormatStyleDefault:
            return [self formatDefaultStyle:message];
        case JKLogFormatStyleCompact:
            return [self formatCompactStyle:message];
        case JKLogFormatStyleDetailed:
            return [self formatDetailedStyle:message];
        case JKLogFormatStyleJSON:
            return [self formatJSONStyle:message];
        case JKLogFormatStyleXML:
            return [self formatXMLStyle:message];
        case JKLogFormatStyleCustom:
            return [self formatCustomStyle:message];
        default:
            return [self formatDefaultStyle:message];
    }
}

#pragma mark - Public Methods

- (void)setColor:(JKLogColor)color forLevel:(JKLogLevel)level {
    NSMutableDictionary *mutableColors = [self.levelColors mutableCopy];
    mutableColors[@(level)] = @(color);
    self.levelColors = [mutableColors copy];
}

#pragma mark - Class Methods

+ (instancetype)compactFormatter {
    JKCustomFormatter *formatter = [[self alloc] initWithStyle:JKLogFormatStyleCompact];
    return formatter;
}

+ (instancetype)detailedFormatter {
    JKCustomFormatter *formatter = [[self alloc] initWithStyle:JKLogFormatStyleDetailed];
    return formatter;
}

+ (instancetype)jsonFormatter {
    JKCustomFormatter *formatter = [[self alloc] initWithStyle:JKLogFormatStyleJSON];
    return formatter;
}

+ (instancetype)xmlFormatter {
    JKCustomFormatter *formatter = [[self alloc] initWithStyle:JKLogFormatStyleXML];
    return formatter;
}

+ (instancetype)colorfulFormatter {
    JKCustomFormatter *formatter = [[self alloc] initWithStyle:JKLogFormatStyleDefault];
    formatter.enableColors = YES;
    return formatter;
}

#pragma mark - Private Methods

/**
 * 根据样式配置格式化器
 */
- (void)configureForStyle:(JKLogFormatStyle)style {
    switch (style) {
        case JKLogFormatStyleCompact:
            self.showThreadInfo = NO;
            self.showFunctionInfo = NO;
            self.showMilliseconds = NO;
            self.dateFormatter.dateFormat = @"HH:mm:ss";
            break;
            
        case JKLogFormatStyleDetailed:
            self.showThreadInfo = YES;
            self.showFunctionInfo = YES;
            self.showQueueInfo = YES;
            self.showMilliseconds = YES;
            self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            break;
            
        case JKLogFormatStyleJSON:
        case JKLogFormatStyleXML:
            // JSON 和 XML 格式包含所有信息
            self.showThreadInfo = YES;
            self.showFunctionInfo = YES;
            self.showQueueInfo = YES;
            self.showMilliseconds = YES;
            break;
            
        default:
            // 保持默认设置
            break;
    }
}

/**
 * 默认格式化样式
 */
- (NSString *)formatDefaultStyle:(JKLogMessage *)message {
    NSMutableString *result = [NSMutableString string];
    
    // 时间戳
    NSString *timestamp = [self.dateFormatter stringFromDate:message.timestamp];
    [result appendFormat:@"%@ ", timestamp];
    
    // 日志等级（带颜色）
    NSString *levelString = JKLogLevelToString(message.level);
    if (self.enableColors) {
        levelString = [self colorizeString:levelString withColor:[self colorForLevel:message.level]];
    }
    [result appendFormat:@"[%@] ", levelString];
    
    // 线程信息
    if (self.showThreadInfo) {
        [result appendFormat:@"[%@] ", message.threadName];
    }
    
    // 队列信息
    if (self.showQueueInfo && message.queueLabel) {
        [result appendFormat:@"[%@] ", message.queueLabel];
    }
    
    // 文件和行号信息
    if (self.showFileInfo) {
        [result appendFormat:@"%@:%lu ", message.file, (unsigned long)message.line];
    }
    
    // 函数信息
    if (self.showFunctionInfo) {
        [result appendFormat:@"%@ ", message.function];
    }
    
    // 分隔符
    [result appendString:@"- "];
    
    // 消息内容
    NSString *messageContent = [self truncateMessage:message.message];
    [result appendString:messageContent];
    
    return [result copy];
}

/**
 * 紧凑格式化样式
 */
- (NSString *)formatCompactStyle:(JKLogMessage *)message {
    NSString *timestamp = [self.dateFormatter stringFromDate:message.timestamp];
    NSString *levelString = JKLogLevelToString(message.level);
    NSString *messageContent = [self truncateMessage:message.message];
    
    if (self.enableColors) {
        levelString = [self colorizeString:levelString withColor:[self colorForLevel:message.level]];
    }
    
    return [NSString stringWithFormat:@"%@ [%@] %@", timestamp, levelString, messageContent];
}

/**
 * 详细格式化样式
 */
- (NSString *)formatDetailedStyle:(JKLogMessage *)message {
    NSMutableString *result = [NSMutableString string];
    
    [result appendString:@"=====================================\n"];
    [result appendFormat:@"Timestamp: %@\n", [self.dateFormatter stringFromDate:message.timestamp]];
    [result appendFormat:@"Level: %@\n", JKLogLevelToString(message.level)];
    [result appendFormat:@"Thread: %@\n", message.threadName];
    
    if (message.queueLabel) {
        [result appendFormat:@"Queue: %@\n", message.queueLabel];
    }
    
    [result appendFormat:@"File: %@:%lu\n", message.file, (unsigned long)message.line];
    [result appendFormat:@"Function: %@\n", message.function];
    [result appendFormat:@"Message: %@\n", [self truncateMessage:message.message]];
    [result appendString:@"====================================="];
    
    return [result copy];
}

/**
 * JSON 格式化样式
 */
- (NSString *)formatJSONStyle:(JKLogMessage *)message {
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    
    jsonDict[@"timestamp"] = @([message.timestamp timeIntervalSince1970] * 1000); // 毫秒时间戳
    jsonDict[@"level"] = JKLogLevelToString(message.level);
    jsonDict[@"thread"] = message.threadName;
    jsonDict[@"file"] = message.file;
    jsonDict[@"line"] = @(message.line);
    jsonDict[@"function"] = message.function;
    jsonDict[@"message"] = [self truncateMessage:message.message];
    
    if (message.queueLabel) {
        jsonDict[@"queue"] = message.queueLabel;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return [NSString stringWithFormat:@"{\"error\":\"Failed to serialize JSON: %@\"}", error.localizedDescription];
    }
}

/**
 * XML 格式化样式
 */
- (NSString *)formatXMLStyle:(JKLogMessage *)message {
    NSMutableString *xml = [NSMutableString string];
    
    [xml appendString:@"<log>"];
    [xml appendFormat:@"<timestamp>%.0f</timestamp>", [message.timestamp timeIntervalSince1970] * 1000];
    [xml appendFormat:@"<level>%@</level>", [self escapeXMLString:JKLogLevelToString(message.level)]];
    [xml appendFormat:@"<thread>%@</thread>", [self escapeXMLString:message.threadName]];
    [xml appendFormat:@"<file>%@</file>", [self escapeXMLString:message.file]];
    [xml appendFormat:@"<line>%lu</line>", (unsigned long)message.line];
    [xml appendFormat:@"<function>%@</function>", [self escapeXMLString:message.function]];
    
    if (message.queueLabel) {
        [xml appendFormat:@"<queue>%@</queue>", [self escapeXMLString:message.queueLabel]];
    }
    
    [xml appendFormat:@"<message>%@</message>", [self escapeXMLString:[self truncateMessage:message.message]]];
    [xml appendString:@"</log>"];
    
    return [xml copy];
}

/**
 * 自定义模板格式化样式
 */
- (NSString *)formatCustomStyle:(JKLogMessage *)message {
    if (!self.customTemplate) {
        return [self formatDefaultStyle:message];
    }
    
    NSString *result = self.customTemplate;
    
    // 替换占位符
    result = [result stringByReplacingOccurrencesOfString:@"{timestamp}" 
                                               withString:[self.dateFormatter stringFromDate:message.timestamp]];
    result = [result stringByReplacingOccurrencesOfString:@"{level}" 
                                               withString:JKLogLevelToString(message.level)];
    result = [result stringByReplacingOccurrencesOfString:@"{thread}" 
                                               withString:message.threadName];
    result = [result stringByReplacingOccurrencesOfString:@"{queue}" 
                                               withString:message.queueLabel ?: @""];
    result = [result stringByReplacingOccurrencesOfString:@"{file}" 
                                               withString:message.file];
    result = [result stringByReplacingOccurrencesOfString:@"{line}" 
                                               withString:[NSString stringWithFormat:@"%lu", (unsigned long)message.line]];
    result = [result stringByReplacingOccurrencesOfString:@"{function}" 
                                               withString:message.function];
    result = [result stringByReplacingOccurrencesOfString:@"{message}" 
                                               withString:[self truncateMessage:message.message]];
    
    return result;
}

/**
 * 获取日志等级对应的颜色
 */
- (JKLogColor)colorForLevel:(JKLogLevel)level {
    NSNumber *colorNumber = self.levelColors[@(level)];
    return colorNumber ? colorNumber.unsignedIntegerValue : JKLogColorNone;
}

/**
 * 为字符串添加颜色代码
 */
- (NSString *)colorizeString:(NSString *)string withColor:(JKLogColor)color {
    if (color == JKLogColorNone) {
        return string;
    }
    
    NSString *colorCode = [self ansiColorCodeForColor:color];
    NSString *resetCode = @"\033[0m";
    
    return [NSString stringWithFormat:@"%@%@%@", colorCode, string, resetCode];
}

/**
 * 获取 ANSI 颜色代码
 */
- (NSString *)ansiColorCodeForColor:(JKLogColor)color {
    switch (color) {
        case JKLogColorRed:     return @"\033[31m";
        case JKLogColorGreen:   return @"\033[32m";
        case JKLogColorYellow:  return @"\033[33m";
        case JKLogColorBlue:    return @"\033[34m";
        case JKLogColorMagenta: return @"\033[35m";
        case JKLogColorCyan:    return @"\033[36m";
        case JKLogColorWhite:   return @"\033[37m";
        default:                return @"";
    }
}

/**
 * 截断消息内容
 */
- (NSString *)truncateMessage:(NSString *)message {
    if (self.maxMessageLength == 0 || message.length <= self.maxMessageLength) {
        return message;
    }
    
    NSString *truncated = [message substringToIndex:self.maxMessageLength - 3];
    return [truncated stringByAppendingString:@"..."];
}

/**
 * 转义 XML 字符串
 */
- (NSString *)escapeXMLString:(NSString *)string {
    NSMutableString *escaped = [string mutableCopy];
    
    [escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"'" withString:@"&#39;" options:0 range:NSMakeRange(0, escaped.length)];
    
    return [escaped copy];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name=%@, style=%lu, colors=%@, maxLength=%lu",
            NSStringFromClass([self class]),
            self,
            self.name,
            (unsigned long)self.formatStyle,
            self.enableColors ? @"YES" : @"NO",
            (unsigned long)self.maxMessageLength];
}

@end