//
//  AFNetworkingLogGenerator.m
//  AFNetworkingLoggerApp
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFNetworkingLogGenerators.h"

#import "NSURL+QueryComponents.h"

#import <objc/runtime.h>

@implementation AFNetworkingLogGenerator

- (NSString *)generateLogForRequestDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSDictionary *HTTPHeaders = operation.request.allHTTPHeaderFields;
    NSData *HTTPHeadersData = [NSPropertyListSerialization dataFromPropertyList:HTTPHeaders
                                                                         format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    NSData *HTTPBodyData = operation.request.HTTPBody;

    NSString *log = [NSString stringWithFormat:@"%@ %@, %@ bytes\n", operation.request.HTTPMethod, operation.request.URL.absoluteString, @(HTTPHeadersData.length + HTTPBodyData.length)];

    return log;
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *HTTPMethod = operation.request.HTTPMethod;
    NSUInteger statusCode = operation.response.statusCode;
    NSString *requestURL = operation.request.URL.absoluteString;
    NSData *responseData = operation.responseData;

    NSDictionary *HTTPHeaders = operation.response.allHeaderFields;
    NSData *HTTPHeadersData = [NSPropertyListSerialization dataFromPropertyList:HTTPHeaders
                                                                         format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    NSNumber *responseSize = @(HTTPHeadersData.length + responseData.length);

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, AFNLHTTPRequestOperationStartDate)];
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;

    NSString *elapsedTimeString = [numberFormatter stringFromNumber:@(elapsedTime)];

    NSString *log = @"";
    if (operation.error == nil) {
        NSString *logFormat = @("%@ %u %@, %@ bytes in %@s\n");

        log = [NSString stringWithFormat:logFormat, HTTPMethod, statusCode, requestURL, responseSize, elapsedTimeString];
    } else {
        // TODO
    }

    return log;
}

@end

@implementation AFNetworkingVerboseLogGenerator

- (NSString *)generateLogForRequestDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {


    return @("");
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    // NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, AFNLHTTPRequestOperationStartDate)];


    return @("");
}

@end
