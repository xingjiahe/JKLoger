//
//  JKRemoteDestination.m
//  JKLoger
//
//  Created by Jaker on 2025/9/29.
//  Copyright © 2025 Jaker. All rights reserved.
//

#import "JKRemoteDestination.h"
#import "../JKLogMessage.h"
#import "../JKLogFormatter.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface JKRemoteDestination ()

/**
 * 待发送的日志消息队列
 */
@property (nonatomic, strong) NSMutableArray<JKLogMessage *> *pendingMessages;

/**
 * 网络操作队列
 */
@property (nonatomic, strong) dispatch_queue_t networkQueue;

/**
 * 批量发送定时器
 */
@property (nonatomic, strong, nullable) NSTimer *batchTimer;

/**
 * URL Session
 */
@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation JKRemoteDestination

#pragma mark - Lifecycle

- (instancetype)init {
    // 默认使用一个示例 URL，实际使用时需要替换
    NSURL *defaultURL = [NSURL URLWithString:@"https://api.example.com/logs"];
    return [self initWithServerURL:defaultURL];
}

- (instancetype)initWithServerURL:(NSURL *)serverURL {
    self = [super init];
    if (self) {
        _logLevel = JKLogLevelDebug; // 默认输出所有等级
        _name = @"Remote";
        _serverURL = serverURL;
        _requestTimeout = 30.0;
        _maxRetryCount = 3;
        _batchSize = 10;
        _batchTimeout = 5.0;
        _enableNetworkCheck = YES;
        _customHeaders = @{
            @"Content-Type": @"application/json",
            @"User-Agent": @"JKLoger/1.0"
        };
        
        _pendingMessages = [NSMutableArray array];
        _networkQueue = dispatch_queue_create("com.jaker.jklogger.remote", DISPATCH_QUEUE_SERIAL);
        
        // 配置 URL Session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = _requestTimeout;
        config.timeoutIntervalForResource = _requestTimeout * 2;
        _urlSession = [NSURLSession sessionWithConfiguration:config];
        
        [self startBatchTimer];
    }
    return self;
}

- (void)dealloc {
    [self stopBatchTimer];
    [self.urlSession invalidateAndCancel];
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
    
    // 检查网络状态
    if (self.enableNetworkCheck && ![self isNetworkAvailable]) {
        // 网络不可用时，可以选择缓存日志或直接丢弃
        // 这里选择直接丢弃，实际应用中可能需要持久化缓存
        return;
    }
    
    dispatch_async(self.networkQueue, ^{
        [self addMessageToBatch:message];
    });
}

#pragma mark - Public Methods

- (void)flush {
    dispatch_async(self.networkQueue, ^{
        [self sendPendingMessages];
    });
}

- (void)sendLogMessage:(JKLogMessage *)message completion:(JKRemoteLogCompletionBlock)completion {
    if (!message) {
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"JKRemoteDestination" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Message is nil"}]);
        }
        return;
    }
    
    [self sendLogMessages:@[message] completion:completion];
}

- (void)sendLogMessages:(NSArray<JKLogMessage *> *)messages completion:(JKRemoteLogCompletionBlock)completion {
    if (!messages || messages.count == 0) {
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"JKRemoteDestination" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Messages array is empty"}]);
        }
        return;
    }
    
    dispatch_async(self.networkQueue, ^{
        [self performSendLogMessages:messages retryCount:0 completion:completion];
    });
}

- (BOOL)isNetworkAvailable {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com");
    if (!reachability) {
        return NO;
    }
    
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!success) {
        return NO;
    }
    
    BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    BOOL needsConnection = (flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0;
    
    return isReachable && !needsConnection;
}

#pragma mark - Private Methods

/**
 * 添加消息到批次队列
 */
- (void)addMessageToBatch:(JKLogMessage *)message {
    [self.pendingMessages addObject:message];
    
    // 如果达到批次大小，立即发送
    if (self.pendingMessages.count >= self.batchSize) {
        [self sendPendingMessages];
    }
}

/**
 * 发送待发送的消息
 */
- (void)sendPendingMessages {
    if (self.pendingMessages.count == 0) {
        return;
    }
    
    NSArray<JKLogMessage *> *messagesToSend = [self.pendingMessages copy];
    [self.pendingMessages removeAllObjects];
    
    [self performSendLogMessages:messagesToSend retryCount:0 completion:nil];
}

/**
 * 执行发送日志消息
 */
- (void)performSendLogMessages:(NSArray<JKLogMessage *> *)messages retryCount:(NSUInteger)retryCount completion:(JKRemoteLogCompletionBlock)completion {
    
    // 构建请求数据
    NSArray *jsonArray = [self convertMessagesToJSONArray:messages];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&jsonError];
    
    if (!jsonData) {
        NSLog(@"JKRemoteDestination: Failed to serialize messages to JSON: %@", jsonError);
        if (completion) {
            completion(NO, jsonError);
        }
        return;
    }
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serverURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    
    // 设置自定义头部
    for (NSString *key in self.customHeaders) {
        [request setValue:self.customHeaders[key] forHTTPHeaderField:key];
    }
    
    // 发送请求
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = NO;
        NSError *resultError = error;
        
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                success = YES;
            } else {
                resultError = [NSError errorWithDomain:@"JKRemoteDestination" 
                                                  code:httpResponse.statusCode 
                                              userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error: %ld", (long)httpResponse.statusCode]}];
            }
        }
        
        if (!success && retryCount < self.maxRetryCount) {
            // 重试
            NSLog(@"JKRemoteDestination: Retrying send (%lu/%lu): %@", (unsigned long)(retryCount + 1), (unsigned long)self.maxRetryCount, resultError);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), self.networkQueue, ^{
                [self performSendLogMessages:messages retryCount:retryCount + 1 completion:completion];
            });
            return;
        }
        
        if (!success) {
            NSLog(@"JKRemoteDestination: Failed to send logs after %lu retries: %@", (unsigned long)self.maxRetryCount, resultError);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, resultError);
            });
        }
    }];
    
    [task resume];
}

/**
 * 将日志消息转换为 JSON 数组
 */
- (NSArray *)convertMessagesToJSONArray:(NSArray<JKLogMessage *> *)messages {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (JKLogMessage *message in messages) {
        NSString *formattedMessage;
        
        // 使用格式化器格式化消息
        if (self.formatter) {
            formattedMessage = [self.formatter formatLogMessage:message];
        } else {
            formattedMessage = message.message;
        }
        
        NSDictionary *messageDict = @{
            @"timestamp": @([message.timestamp timeIntervalSince1970] * 1000), // 毫秒时间戳
            @"level": JKLogLevelToString(message.level),
            @"message": formattedMessage,
            @"file": message.file,
            @"function": message.function,
            @"line": @(message.line),
            @"thread": message.threadName,
            @"queue": message.queueLabel ?: @""
        };
        
        [jsonArray addObject:messageDict];
    }
    
    return [jsonArray copy];
}

/**
 * 启动批次定时器
 */
- (void)startBatchTimer {
    [self stopBatchTimer];
    
    self.batchTimer = [NSTimer scheduledTimerWithTimeInterval:self.batchTimeout
                                                       target:self
                                                     selector:@selector(batchTimerFired:)
                                                     userInfo:nil
                                                      repeats:YES];
}

/**
 * 停止批次定时器
 */
- (void)stopBatchTimer {
    if (self.batchTimer) {
        [self.batchTimer invalidate];
        self.batchTimer = nil;
    }
}

/**
 * 批次定时器触发
 */
- (void)batchTimerFired:(NSTimer *)timer {
    dispatch_async(self.networkQueue, ^{
        [self sendPendingMessages];
    });
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name=%@, logLevel=%@, serverURL=%@, batchSize=%lu, networkAvailable=%@",
            NSStringFromClass([self class]),
            self,
            self.name,
            JKLogLevelToString(self.logLevel),
            self.serverURL,
            (unsigned long)self.batchSize,
            self.isNetworkAvailable ? @"YES" : @"NO"];
}

@end