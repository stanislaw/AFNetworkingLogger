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

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {

#pragma mark AFHTTPRequestOperation components

    NSString *HTTPMethod = operation.request.HTTPMethod;
    NSUInteger statusCode = operation.response.statusCode;
    NSData *responseData = operation.responseData;
    NSDictionary *HTTPHeaders = operation.response.allHeaderFields;
    NSData *HTTPHeadersData = [NSPropertyListSerialization dataFromPropertyList:HTTPHeaders
                                                                         format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

#pragma mark Paddings

    NSString *paddingString = [NSString stringWithFormat:@"%@ %@ ", HTTPMethod, @(statusCode)];
    paddingString = [@"" stringByPaddingToLength:paddingString.length withString:@" " startingAtIndex:0];
    NSString *responseSizePaddingString = [@"" stringByPaddingToLength:(paddingString.length - 3) withString:@" " startingAtIndex:0];

#pragma mark Header string (HTTP method, status code, URL)

    NSString *URLStringWithoutQueryPart = [[operation.request.URL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
    NSString *headerString = [NSString stringWithFormat:@("%@ %@ %@"), HTTPMethod, @(statusCode), URLStringWithoutQueryPart];

    NSDictionary *queryComponents = operation.request.URL.queryComponents;
    NSMutableArray *queryComponentsStrings = [NSMutableArray array];
    [queryComponents enumerateKeysAndObjectsUsingBlock:^(id queryKey, id queryValue, BOOL *stop) {
        NSString *queryValueString = [queryValue lastObject];

        NSString *queryComponentString = [NSString stringWithFormat:@("%@%@"), paddingString, [@[queryKey, queryValueString] componentsJoinedByString:@"="]];

        [queryComponentsStrings addObject:queryComponentString];
    }];
    NSString *queryComponentsString = [queryComponentsStrings componentsJoinedByString:@"\n"];

#pragma mark Response size and elapsed time

    NSNumber *responseSize = @(HTTPHeadersData.length + responseData.length);

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, AFNLHTTPRequestOperationStartDate)];
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;

    NSString *elapsedTimeString = [numberFormatter stringFromNumber:@(elapsedTime)];

    NSString *responseSizeAndElapsedTimeString = [NSString stringWithFormat:@"%@-> %@ bytes in %@s", responseSizePaddingString, responseSize, elapsedTimeString];

#pragma mark HTTP headers
    NSMutableArray *HTTPHeadersStrings = [NSMutableArray array];

    __block NSUInteger calculatedHTTPHeadersPadding = 0;
    [HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         calculatedHTTPHeadersPadding = MAX(calculatedHTTPHeadersPadding, [key length]);
    }];

    [HTTPHeaders enumerateKeysAndObjectsUsingBlock:^(id HTTPHeaderKey, id HTTPHeaderKeyValue, BOOL *stop) {
        NSString *HTTPHeaderKeyString = [HTTPHeaderKey stringByPaddingToLength:calculatedHTTPHeadersPadding withString:@" " startingAtIndex:0];
        NSString *HTTPHeaderString = [NSString stringWithFormat:@"%@%@ = %@", paddingString, HTTPHeaderKeyString, HTTPHeaderKeyValue];
        [HTTPHeadersStrings addObject:HTTPHeaderString];
    }];

    NSString *HTTPHeadersString = [HTTPHeadersStrings componentsJoinedByString:@"\n"];

#pragma mark HTTP response body

    NSString *responseBodyString = [paddingString copy];

    if (operation.responseData.length == 0) {
        responseBodyString = [responseBodyString stringByAppendingString:@"Response body is empty"];
    } else if (operation.responseData.length <= (1024 * 100)) {
        responseBodyString = [responseBodyString stringByAppendingString:[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]];
    } else {
        responseBodyString = [responseBodyString stringByAppendingString:@"Response body data is too large"];
    }

#pragma mark Aggregation of formatted log string

    NSMutableArray *logComponents = [NSMutableArray array];

    [logComponents addObject:@"\n"];

    [logComponents addObject:headerString];
    [logComponents addObject:@"\n"];

    [logComponents addObject:queryComponentsString];

    [logComponents addObject:@"\n"];
    [logComponents addObject:@"\n"];

    [logComponents addObject:responseSizeAndElapsedTimeString];

    [logComponents addObject:@"\n"];
    [logComponents addObject:@"\n"];

    [logComponents addObject:HTTPHeadersString];

    [logComponents addObject:@"\n"];
    [logComponents addObject:@"\n"];

    [logComponents addObject:responseBodyString];

    [logComponents addObject:@"\n"];

    NSString *log = @"";
    if (operation.error == nil) {

        // log = [NSString stringWithFormat:logFormat, HTTPMethod, statusCode, requestURL, responseSize, elapsedTimeString];

        log = [logComponents componentsJoinedByString:@""];
    } else {
        // TODO
    }
    
    return log;
}

@end
