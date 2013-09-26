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
    NSString *log = [NSString stringWithFormat:@"%@ %@\n", operation.request.HTTPMethod, operation.request.URL.absoluteString];

    return log;
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *HTTPMethod = operation.request.HTTPMethod;
    NSUInteger statusCode = operation.response.statusCode;
    NSString *requestURL = operation.request.URL.absoluteString;
    NSData *responseData = operation.responseData;
    NSUInteger responseSize = responseData.length;

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, AFNLHTTPRequestOperationStartDate)];
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;

    NSString *elapsedTimeString = [numberFormatter stringFromNumber:@(elapsedTime)];


    // PATCH 200 https://api.a-a-ah.ru/v1/places?... 567 bytes in 234 ms

    NSString *logFormat = @("%@ %u %@, %u bytes in %@s\n");

    NSString *log = [NSString stringWithFormat:logFormat, HTTPMethod, statusCode, requestURL, responseSize, elapsedTimeString];

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
