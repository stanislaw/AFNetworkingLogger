// AFNetworkingLogger.m
//
// Copyright (c) 2013
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworkingLogger.h"
#import "AFNetworkingLogger_Private.h"

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperation+AFNL.h"

#import <objc/runtime.h>

@implementation AFNetworkingLogger

+ (instancetype)sharedLogger {
    static AFNetworkingLogger *_sharedLogger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });
    
    return _sharedLogger;
}

- (id)init {
    self = [super init];

    if (self == nil) return nil;
    
    self.level = AFNetworkingLoggerLevelNormal;
    self.errorsOnlyLogging = NO;

    self.maxResponseBodySizeToLogWithoutTruncationInVerboseMode = 8192;
    self.maxResponseBodySizeToLogWithTruncationInVerboseMode = 1024 * 1024;
    self.responseBodySymbolsToLogWithTruncationInVerboseMode = 128;
    self.logResponseBodiesContainingBinaryData = NO;

    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    [self stopLogging];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configuration

- (void)setLevel:(AFNetworkingLoggerLevel)level {
    if (level != self.level) {
        _logGenerator = nil;
    }

    _level = level;
}

- (AFNetworkingLoggerOutputCFunction)output {
    if (_output == NULL) {
        _output = &printf;
    }

    return _output;
}

- (id <AFNetworkingLogGenerator>)logGenerator {
    if (_logGenerator == nil) {
        switch (self.level) {
            case AFNetworkingLoggerLevelOff:
                _logGenerator = nil;

                break;
            case AFNetworkingLoggerLevelVerbose:
                _logGenerator = [[AFNetworkingVerboseLogGenerator alloc] init];

                break;
            default:
                _logGenerator = [[AFNetworkingLogGenerator alloc] init];

                break;
        }
    }
    
    return _logGenerator;
}

#pragma mark - NSNotification


- (void)HTTPOperationDidStart:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

    // Ignore malformed operations produced by UIImageView+AFNetworking.h
    if (operation.request.URL == nil) {
        return;
    }

    if ([operation isKindOfClass:[AFHTTPRequestOperation class]] == NO) {
        return;
    }
    
    objc_setAssociatedObject(operation, AFNLHTTPRequestOperationStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.filterPredicate && [self.filterPredicate evaluateWithObject:operation]) {
        return;
    }

    if (self.level != AFNetworkingLoggerLevelOff && self.errorsOnlyLogging == NO) {
        NSString *log = [self.logGenerator generateLogForRequestDataOfAFHTTPRequestOperation:operation];
        self.output("%s", log.UTF8String);
    }
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

    // Ignore malformed operations produced by UIImageView+AFNetworking.h
    if (operation.request.URL == nil) {
        return;
    }

    if ([operation isKindOfClass:[AFHTTPRequestOperation class]] == NO) {
        return;
    }
    
    if (self.filterPredicate && [self.filterPredicate evaluateWithObject:operation]) {
        return;
    }

    if (self.level != AFNetworkingLoggerLevelOff) {
        if (self.errorsOnlyLogging && operation.error == nil) return;

        NSString *log = [self.logGenerator generateLogForResponseDataOfAFHTTPRequestOperation:operation];
        self.output("%s", log.UTF8String);
    }
}

@end
