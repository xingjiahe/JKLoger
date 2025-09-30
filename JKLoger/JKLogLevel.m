//
//  JKLogLevel.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKLogLevel.h"

NSString *JKLogLevelToString(JKLogLevel level) {
    switch (level) {
        case JKLogLevelFatal:
            return @"FATAL";
        case JKLogLevelError:
            return @"ERROR";
        case JKLogLevelWarning:
            return @"WARNING";
        case JKLogLevelInfo:
            return @"INFO";
        case JKLogLevelDebug:
            return @"DEBUG";
        default:
            return @"UNKNOWN";
    }
}

JKLogLevel JKLogLevelFromString(NSString *levelString) {
    if (!levelString) {
        return JKLogLevelInfo;
    }
    
    NSString *upperString = [levelString uppercaseString];
    
    if ([upperString isEqualToString:@"FATAL"]) {
        return JKLogLevelFatal;
    } else if ([upperString isEqualToString:@"ERROR"]) {
        return JKLogLevelError;
    } else if ([upperString isEqualToString:@"WARNING"] || [upperString isEqualToString:@"WARN"]) {
        return JKLogLevelWarning;
    } else if ([upperString isEqualToString:@"INFO"]) {
        return JKLogLevelInfo;
    } else if ([upperString isEqualToString:@"DEBUG"]) {
        return JKLogLevelDebug;
    }
    
    return JKLogLevelInfo; // 默认返回 Info 等级
}