//
//  JKFileDestination.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKFileDestination.h"
#import "../JKLogMessage.h"
#import "../JKLogFormatter.h"

@interface JKFileDestination ()

/**
 * 当前日志文件句柄
 */
@property (nonatomic, strong, nullable) NSFileHandle *currentFileHandle;

/**
 * 文件操作队列，确保线程安全
 */
@property (nonatomic, strong) dispatch_queue_t fileQueue;

/**
 * 当前日志文件路径
 */
@property (nonatomic, copy, nullable) NSString *currentLogFilePath;

@end

@implementation JKFileDestination

#pragma mark - Lifecycle

- (instancetype)init {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *logsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Logs"];
    
    return [self initWithDirectory:logsDirectory fileNamePrefix:@"app"];
}

- (instancetype)initWithDirectory:(NSString *)directory {
    return [self initWithDirectory:directory fileNamePrefix:@"app"];
}

- (instancetype)initWithDirectory:(NSString *)directory fileNamePrefix:(NSString *)prefix {
    self = [super init];
    if (self) {
        _logLevel = JKLogLevelDebug; // 默认输出所有等级
        _name = @"File";
        _logDirectory = [directory copy];
        _fileNamePrefix = [prefix copy];
        _maxFileSize = 10 * 1024 * 1024; // 10MB
        _maxFileCount = 5;
        _immediateFlush = NO;
        
        _fileQueue = dispatch_queue_create("com.jaker.jklogger.file", DISPATCH_QUEUE_SERIAL);
        
        [self setupLogDirectory];
        [self setupCurrentLogFile];
    }
    return self;
}

- (void)dealloc {
    [self closeCurrentLogFile];
}

#pragma mark - JKLogDestination

- (void)logMessage:(JKLogMessage *)message {
    if (!message) {
        return;
    }
    
    // 检查日志等级
    if (message.level > self.logLevel) {
        return;
    }
    
    dispatch_async(self.fileQueue, ^{
        [self writeMessageToFile:message];
    });
}

#pragma mark - Public Methods

- (void)rotateLogFile {
    dispatch_async(self.fileQueue, ^{
        [self performLogFileRotation];
    });
}

- (void)cleanupOldLogFiles {
    dispatch_async(self.fileQueue, ^{
        [self performCleanupOldLogFiles];
    });
}

- (NSArray<NSString *> *)allLogFilePaths {
    __block NSArray<NSString *> *result;
    dispatch_sync(self.fileQueue, ^{
        result = [self getAllLogFilePathsInternal];
    });
    return result;
}

#pragma mark - Private Methods

/**
 * 设置日志目录
 */
- (void)setupLogDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.logDirectory]) {
        NSError *error;
        BOOL success = [fileManager createDirectoryAtPath:self.logDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        if (!success) {
            NSLog(@"JKFileDestination: Failed to create log directory: %@", error);
        }
    }
}

/**
 * 设置当前日志文件
 */
- (void)setupCurrentLogFile {
    NSString *fileName = [self generateLogFileName];
    NSString *filePath = [self.logDirectory stringByAppendingPathComponent:fileName];
    
    self.currentLogFilePath = filePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 如果文件不存在，创建文件
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL success = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if (!success) {
            NSLog(@"JKFileDestination: Failed to create log file: %@", filePath);
            return;
        }
    }
    
    // 打开文件句柄
    NSError *error;
    self.currentFileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (!self.currentFileHandle) {
        NSLog(@"JKFileDestination: Failed to open log file: %@", error);
        return;
    }
    
    // 移动到文件末尾
    [self.currentFileHandle seekToEndOfFile];
}

/**
 * 生成日志文件名
 */
- (NSString *)generateLogFileName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@_%@.log", self.fileNamePrefix, timestamp];
}

/**
 * 写入消息到文件
 */
- (void)writeMessageToFile:(JKLogMessage *)message {
    if (!self.currentFileHandle) {
        return;
    }
    
    NSString *formattedMessage;
    
    // 使用格式化器格式化消息
    if (self.formatter) {
        formattedMessage = [self.formatter formatLogMessage:message];
    } else {
        // 使用默认格式
        formattedMessage = [self defaultFormatMessage:message];
    }
    
    // 添加换行符
    formattedMessage = [formattedMessage stringByAppendingString:@"\n"];
    
    // 写入文件
    NSData *data = [formattedMessage dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        @try {
            [self.currentFileHandle writeData:data];
            
            if (self.immediateFlush) {
                [self.currentFileHandle synchronizeFile];
            }
            
            // 检查文件大小，如果超过限制则轮转
            [self checkAndRotateIfNeeded];
            
        } @catch (NSException *exception) {
            NSLog(@"JKFileDestination: Failed to write to log file: %@", exception);
        }
    }
}

/**
 * 默认的消息格式化方法
 */
- (NSString *)defaultFormatMessage:(JKLogMessage *)message {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    NSString *timestamp = [dateFormatter stringFromDate:message.timestamp];
    NSString *levelString = JKLogLevelToString(message.level);
    
    return [NSString stringWithFormat:@"%@ [%@] [%@] %@:%lu %@ - %@",
            timestamp,
            levelString,
            message.threadName,
            message.file,
            (unsigned long)message.line,
            message.function,
            message.message];
}

/**
 * 检查文件大小并在需要时轮转
 */
- (void)checkAndRotateIfNeeded {
    if (!self.currentFileHandle || !self.currentLogFilePath) {
        return;
    }
    
    @try {
        unsigned long long fileSize = [self.currentFileHandle offsetInFile];
        if (fileSize >= self.maxFileSize) {
            [self performLogFileRotation];
        }
    } @catch (NSException *exception) {
        NSLog(@"JKFileDestination: Failed to check file size: %@", exception);
    }
}

/**
 * 执行日志文件轮转
 */
- (void)performLogFileRotation {
    // 关闭当前文件
    [self closeCurrentLogFile];
    
    // 创建新的日志文件
    [self setupCurrentLogFile];
    
    // 清理旧文件
    [self performCleanupOldLogFiles];
}

/**
 * 关闭当前日志文件
 */
- (void)closeCurrentLogFile {
    if (self.currentFileHandle) {
        @try {
            [self.currentFileHandle synchronizeFile];
            [self.currentFileHandle closeFile];
        } @catch (NSException *exception) {
            NSLog(@"JKFileDestination: Failed to close log file: %@", exception);
        }
        self.currentFileHandle = nil;
    }
}

/**
 * 执行清理旧日志文件
 */
- (void)performCleanupOldLogFiles {
    NSArray<NSString *> *allLogFiles = [self getAllLogFilePathsInternal];
    
    if (allLogFiles.count <= self.maxFileCount) {
        return;
    }
    
    // 删除超出限制的旧文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSUInteger filesToDelete = allLogFiles.count - self.maxFileCount;
    
    for (NSUInteger i = 0; i < filesToDelete; i++) {
        NSString *fileToDelete = allLogFiles[allLogFiles.count - 1 - i]; // 从最旧的开始删除
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:fileToDelete error:&error];
        if (!success) {
            NSLog(@"JKFileDestination: Failed to delete old log file %@: %@", fileToDelete, error);
        }
    }
}

/**
 * 获取所有日志文件路径（内部方法）
 */
- (NSArray<NSString *> *)getAllLogFilePathsInternal {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray<NSString *> *fileNames = [fileManager contentsOfDirectoryAtPath:self.logDirectory error:&error];
    if (!fileNames) {
        NSLog(@"JKFileDestination: Failed to list log directory: %@", error);
        return @[];
    }
    
    // 过滤出日志文件
    NSMutableArray<NSString *> *logFiles = [NSMutableArray array];
    NSString *logExtension = @".log";
    
    for (NSString *fileName in fileNames) {
        if ([fileName hasPrefix:self.fileNamePrefix] && [fileName hasSuffix:logExtension]) {
            NSString *fullPath = [self.logDirectory stringByAppendingPathComponent:fileName];
            [logFiles addObject:fullPath];
        }
    }
    
    // 按修改时间排序（最新的在前）
    [logFiles sortUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
        NSDictionary *attrs1 = [fileManager attributesOfItemAtPath:path1 error:nil];
        NSDictionary *attrs2 = [fileManager attributesOfItemAtPath:path2 error:nil];
        
        NSDate *date1 = attrs1[NSFileModificationDate];
        NSDate *date2 = attrs2[NSFileModificationDate];
        
        return [date2 compare:date1]; // 降序排列
    }];
    
    return [logFiles copy];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name=%@, logLevel=%@, directory=%@, maxFileSize=%lu, maxFileCount=%lu",
            NSStringFromClass([self class]),
            self,
            self.name,
            JKLogLevelToString(self.logLevel),
            self.logDirectory,
            (unsigned long)self.maxFileSize,
            (unsigned long)self.maxFileCount];
}

@end