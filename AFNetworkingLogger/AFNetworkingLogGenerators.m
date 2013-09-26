//
//  AFNetworkingLogGenerator.m
//  AFNetworkingLoggerApp
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFNetworkingLogGenerators.h"
#import "AFNetworkingLoggerConstants.h"

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
    NSString *log = [NSString string];

    @autoreleasepool {

#pragma mark AFHTTPRequestOperation components

        NSString *HTTPMethod = operation.request.HTTPMethod;
        NSDictionary *HTTPHeaders = operation.request.allHTTPHeaderFields;

        NSUInteger HTTPHeadersDataSize;

        if (HTTPHeaders && HTTPHeaders.count > 0) {
            NSData *HTTPHeadersData = [NSPropertyListSerialization dataFromPropertyList:HTTPHeaders
                                                                             format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
            HTTPHeadersDataSize = HTTPHeadersData.length;
        } else {
            HTTPHeadersDataSize = 0;
        }

        NSData *HTTPBodyData = operation.request.HTTPBody;
        NSUInteger HTTPBodyDataSize = HTTPBodyData ? HTTPBodyData.length : 0;

        NSUInteger requestSize = HTTPHeadersDataSize + HTTPBodyDataSize;

#pragma mark Paddings

        NSString *paddingString = [NSString stringWithFormat:@"%@ ", HTTPMethod];
        paddingString = [@"" stringByPaddingToLength:paddingString.length withString:@" " startingAtIndex:0];
        NSString *responseSizePaddingString = [@"" stringByPaddingToLength:(paddingString.length - 3) withString:@" " startingAtIndex:0];

#pragma mark Header string (HTTP method, status code, URL)

        NSArray *URLComponents = [operation.request.URL.absoluteString componentsSeparatedByString:@"?"];
        BOOL queryComponentsPresent = URLComponents.count == 2;

        NSString *URLStringWithoutQueryPart = [URLComponents objectAtIndex:0];
        NSString *headerString = [NSString stringWithFormat:@("%@ %@"), HTTPMethod, URLStringWithoutQueryPart];

        if (queryComponentsPresent) {
            headerString = [headerString stringByAppendingString:@"?"];
        }

        NSDictionary *queryComponents = operation.request.URL.queryComponents;
        NSMutableArray *queryComponentsStrings = [NSMutableArray array];
        [queryComponents enumerateKeysAndObjectsUsingBlock:^(id queryKey, id queryValue, BOOL *stop) {
            NSString *queryValueString = [queryValue lastObject];

            NSString *queryComponentString = [NSString stringWithFormat:@("%@%@"), paddingString, [@[queryKey, queryValueString] componentsJoinedByString:@"="]];

            if ([queryComponents.allKeys indexOfObject:queryKey] != (queryComponents.count - 1)) {
                queryComponentString = [queryComponentString stringByAppendingString:@"&"];
            }

            [queryComponentsStrings addObject:queryComponentString];
        }];
        NSString *queryComponentsString = [queryComponentsStrings componentsJoinedByString:@"\n"];

#pragma mark Request size

        NSString *requestSizeString = [NSString stringWithFormat:@"%@   %@ bytes", responseSizePaddingString, @(requestSize)];

#pragma mark HTTP headers
        NSString *HTTPHeadersString;

        if (HTTPHeaders) {
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

            HTTPHeadersString = [HTTPHeadersStrings componentsJoinedByString:@"\n"];
        }

#pragma mark HTTP response body

        NSString *requestBodyString = [paddingString copy];

        if (0 < HTTPBodyDataSize && HTTPBodyDataSize <= (1024 * 100)) {
            requestBodyString = [requestBodyString stringByAppendingString:[[NSString alloc] initWithData:HTTPBodyData encoding:NSUTF8StringEncoding]];
        } else if (HTTPBodyDataSize <= (1024 * 100)) {
            requestBodyString = [requestBodyString stringByAppendingString:@"Request body data is too large to be displayed..."];
        }

#pragma mark Aggregation of formatted log string

        NSMutableArray *logComponents = [NSMutableArray array];

        [logComponents addObject:@"\n"];

        [logComponents addObject:headerString];

        [logComponents addObject:@"\n"];

        if (queryComponentsPresent) {
            [logComponents addObject:queryComponentsString];

            [logComponents addObject:@"\n"];
            [logComponents addObject:@"\n"];
        } else {
            [logComponents addObject:@"\n"];
        }

        if (HTTPHeaders && HTTPHeaders.count > 0) {
            [logComponents addObject:HTTPHeadersString];

            [logComponents addObject:@"\n"];
            [logComponents addObject:@"\n"];
        }

        if (HTTPBodyDataSize > 0) {
            [logComponents addObject:requestBodyString];

            [logComponents addObject:@"\n"];
            [logComponents addObject:@"\n"];
        }

        [logComponents addObject:requestSizeString];

        [logComponents addObject:@"\n"];
        [logComponents addObject:@"\n"];

        log = [logComponents componentsJoinedByString:@""];
    }
    
    return log;
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *log = [NSString string];

    @autoreleasepool {

#pragma mark AFHTTPRequestOperation components

        NSString *HTTPMethod = operation.request.HTTPMethod;

        NSUInteger statusCode = operation.response.statusCode;

        NSString *statusCodeString;

        if (100 <= statusCode && statusCode < 600) {
            statusCodeString = [@(statusCode) stringValue];
        } else {
            statusCodeString = @"N/A";
        }

        NSData *responseData = operation.responseData;
        NSDictionary *HTTPHeaders = operation.response.allHeaderFields;
        NSData *HTTPHeadersData = [NSPropertyListSerialization dataFromPropertyList:HTTPHeaders
                                                                             format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

#pragma mark Paddings

        NSString *paddingString = [NSString stringWithFormat:@"%@ ", statusCodeString];
        paddingString = [@"" stringByPaddingToLength:paddingString.length withString:@" " startingAtIndex:0];
        NSString *responseSizePaddingString = [@"" stringByPaddingToLength:(paddingString.length - 3) withString:@" " startingAtIndex:0];

#pragma mark NSURLError 

        // *** Cocoa NSURLError: NSURLErrorCannotFindHost -1003 ***
        NSString *NSURLErrorWarningString;

        if (operation.error) {
            NSString *NSURLErrorCodeString = [AFNL_NSURLErrorCodes() objectForKey:@(operation.error.code)];
            NSURLErrorWarningString = [NSString stringWithFormat:@("*** %@ %@ ***"), NSURLErrorCodeString, @(operation.error.code)];
        }

#pragma mark Header string (HTTP method, status code, URL)

        NSArray *URLComponents = [operation.request.URL.absoluteString componentsSeparatedByString:@"?"];
        BOOL queryComponentsPresent = URLComponents.count == 2;

        NSString *URLStringWithoutQueryPart = [URLComponents objectAtIndex:0];
        NSString *headerString = [NSString stringWithFormat:@("%@ %@"), statusCodeString, URLStringWithoutQueryPart];

        if (queryComponentsPresent) {
            headerString = [headerString stringByAppendingString:@"?"];
        }

        NSDictionary *queryComponents = operation.request.URL.queryComponents;
        NSMutableArray *queryComponentsStrings = [NSMutableArray array];
        [queryComponents enumerateKeysAndObjectsUsingBlock:^(id queryKey, id queryValue, BOOL *stop) {
            NSString *queryValueString = [queryValue lastObject];

            NSString *queryComponentString = [NSString stringWithFormat:@("%@%@"), paddingString, [@[queryKey, queryValueString] componentsJoinedByString:@"="]];

            if ([queryComponents.allKeys indexOfObject:queryKey] != (queryComponents.count - 1)) {
                queryComponentString = [queryComponentString stringByAppendingString:@"&"];
            }

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
        NSString *HTTPHeadersString;

        if (HTTPHeaders) {
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

            HTTPHeadersString = [HTTPHeadersStrings componentsJoinedByString:@"\n"];
        }

#pragma mark HTTP response body

        NSString *responseBodyString = [paddingString copy];

        if (operation.responseData.length == 0) {
            responseBodyString = [responseBodyString stringByAppendingString:@"No response body."];
        } else if (operation.responseData.length <= (1024 * 100)) {
            responseBodyString = [responseBodyString stringByAppendingString:[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]];
        } else {
            responseBodyString = [responseBodyString stringByAppendingString:@"Response body data is too large to be displayed..."];
        }

#pragma mark Aggregation of formatted log string

        NSMutableArray *logComponents = [NSMutableArray array];

        [logComponents addObject:@"\n"];

        if (operation.error) {
            [logComponents addObject:NSURLErrorWarningString];
            [logComponents addObject:@"\n"];
            [logComponents addObject:@"\n"];
        }

        [logComponents addObject:headerString];
        [logComponents addObject:@"\n"];

        if (queryComponentsPresent) {
            [logComponents addObject:queryComponentsString];

            [logComponents addObject:@"\n"];
        }

        [logComponents addObject:@"\n"];

        [logComponents addObject:responseSizeAndElapsedTimeString];

        [logComponents addObject:@"\n"];

        if (HTTPHeaders) {
            [logComponents addObject:@"\n"];
            [logComponents addObject:HTTPHeadersString];
            [logComponents addObject:@"\n"];
        }

        [logComponents addObject:@"\n"];

        [logComponents addObject:responseBodyString];

        [logComponents addObject:@"\n"];
        [logComponents addObject:@"\n"];


        log = [logComponents componentsJoinedByString:@""];
    }

    return log;
}

@end