//
//  AFNetworkingLogGenerator.m
//  AFNetworkingLoggerApp
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFNetworkingLogger.h"
#import "AFNetworkingLogGenerators.h"
#import "AFNetworkingLoggerConstants.h"

#import "NSURL+AFNL.h"

#import <objc/runtime.h>

@implementation AFNetworkingLogGenerator

- (NSString *)generateLogForRequestDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSDictionary *HTTPHeaders = operation.request.allHTTPHeaderFields;
    NSUInteger HTTPHeadersSize = 0;

    if (HTTPHeaders) {
        NSData *HTTPHeadersData = [NSPropertyListSerialization dataWithPropertyList:HTTPHeaders
                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                            options:0
                                                                              error:NULL];

        HTTPHeadersSize = HTTPHeadersData.length;
    }

    NSData *HTTPBodyData = operation.request.HTTPBody;
    NSUInteger HTTPBodySize = HTTPBodyData ? HTTPBodyData.length : 0;

    NSString *log = [NSString stringWithFormat:@"%@ %@, %@ bytes\n", operation.request.HTTPMethod, operation.request.URL.absoluteString, @(HTTPHeadersSize + HTTPBodySize)];

    return log;
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *statusCodeString;
    NSUInteger statusCode = operation.response.statusCode;
    if (100 <= statusCode && statusCode < 600) {
        statusCodeString = [@(statusCode) stringValue];
    } else {
        statusCodeString = @"N/A";
    }

    NSString *requestURL = operation.request.URL.absoluteString;

    NSDictionary *HTTPHeaders = operation.response.allHeaderFields;
    NSUInteger HTTPHeadersSize = 0;

    if (HTTPHeaders) {
        NSData *HTTPHeadersData = [NSPropertyListSerialization dataWithPropertyList:HTTPHeaders
                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                            options:0
                                                                              error:NULL];
        HTTPHeadersSize = HTTPHeadersData.length;
    }

    NSData *responseData = operation.responseData;
    NSUInteger responseDataSize = responseData ? responseData.length : 0;

    NSNumber *responseSize = @(HTTPHeadersSize + responseDataSize);

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, AFNLHTTPRequestOperationStartDate)];
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;

    NSString *elapsedTimeString = [numberFormatter stringFromNumber:@(elapsedTime)];

    NSString *log;

    if (operation.error == nil) {
        NSString *logFormat = @("%@ %@, %@ bytes in %@s\n");
        log = [NSString stringWithFormat:logFormat, statusCodeString, requestURL, responseSize, elapsedTimeString];
    } else {
        NSString *logFormat = @("%@ %@ %@, %@ bytes in %@s\n");

        NSString *NSURLErrorWarningString = [NSString stringWithFormat:@"/*** %@ %@ ***/", AFNL_NSStringFromNSURLError(operation.error), @(operation.error.code)];

        log = [NSString stringWithFormat:logFormat, NSURLErrorWarningString, statusCodeString, requestURL, responseSize, elapsedTimeString];
    }

    return log;
}

@end

@implementation AFNetworkingVerboseLogGenerator

- (NSString *)generateLogForRequestDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *log;

    @autoreleasepool {

#pragma mark AFHTTPRequestOperation components

        NSString *HTTPMethod = operation.request.HTTPMethod;
        NSDictionary *HTTPHeaders = operation.request.allHTTPHeaderFields;

        NSUInteger HTTPHeadersDataSize;

        if (HTTPHeaders && HTTPHeaders.count > 0) {
            NSData *HTTPHeadersData = [NSPropertyListSerialization dataWithPropertyList:HTTPHeaders
                                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                                                options:0
                                                                                  error:NULL];

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

        NSString *headerString;

        BOOL queryComponentsPresent = NO;
        NSString *queryComponentsString;

        if (operation.request.URL.absoluteString.length > 56) {
            NSArray *URLComponents = [operation.request.URL.absoluteString componentsSeparatedByString:@"?"];
            queryComponentsPresent = URLComponents.count == 2;

            NSString *URLStringWithoutQueryPart = [URLComponents objectAtIndex:0];
            headerString = [NSString stringWithFormat:@("%@ %@"), HTTPMethod, URLStringWithoutQueryPart];

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
            queryComponentsString = [queryComponentsStrings componentsJoinedByString:@"\n"];
        } else {
            headerString = [NSString stringWithFormat:@("%@ %@"), HTTPMethod, operation.request.URL.absoluteString];
        }

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

#pragma mark HTTP request body

        NSString *requestBodyString = [paddingString copy];

        if (0 < HTTPBodyDataSize && HTTPBodyDataSize <= (1024 * 100)) {
            requestBodyString = [requestBodyString stringByAppendingString:[[NSString alloc] initWithData:HTTPBodyData encoding:NSUTF8StringEncoding]];
        }

        else if (HTTPBodyDataSize <= (1024 * 100)) {
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

        if (requestSize > 0) {
            [logComponents addObject:requestSizeString];
            [logComponents addObject:@"\n"];
            [logComponents addObject:@"\n"];
        }

        log = [logComponents componentsJoinedByString:@""];
    }

    return log;
}

- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSString *log;

    @autoreleasepool {

#pragma mark AFHTTPRequestOperation components
        NSUInteger statusCode = operation.response.statusCode;

        NSString *statusCodeString;

        if (100 <= statusCode && statusCode < 600) {
            statusCodeString = [@(statusCode) stringValue];
        } else {
            statusCodeString = @"N/A";
        }

        NSData *responseData = operation.responseData;
        NSDictionary *HTTPHeaders = operation.response.allHeaderFields;
        NSData *HTTPHeadersData = [NSPropertyListSerialization dataWithPropertyList:HTTPHeaders
                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                            options:0
                                                                              error:NULL];

#pragma mark Paddings

        NSString *paddingString = [NSString stringWithFormat:@"%@ ", statusCodeString];
        paddingString = [@"" stringByPaddingToLength:paddingString.length withString:@" " startingAtIndex:0];
        NSString *responseSizePaddingString = [@"" stringByPaddingToLength:(paddingString.length - 3) withString:@" " startingAtIndex:0];

#pragma mark NSURLError 

        // *** Cocoa NSURLError: NSURLErrorCannotFindHost -1003 ***
        NSString *NSURLErrorWarningString;

            // Call operation.error twice because of bug in either AFNetworking or Cocoa (NSURLError)
        NSError *error = operation.error ?: operation.error;

        if (error) {
            // Malformed JSON: Error Domain=NSCocoaErrorDomain Code=3840 "The operation couldn’t be completed. (Cocoa error 3840.)" (JSON text did not start with array or object and option to allow fragments not set.) UserInfo=0xad9b5a0 {NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}
            if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSPropertyListReadCorruptError) {
                NSURLErrorWarningString = @"/* NSPropertyListReadCorruptError 3840 */";
            } else {
                NSString *NSURLErrorCodeString = AFNL_NSStringFromNSURLError(operation.error);

                if (NSURLErrorCodeString == nil) {
                    NSURLErrorCodeString = @"Unknown error";
                }

                NSURLErrorWarningString = [NSString stringWithFormat:@("/* %@ %@ */"), NSURLErrorCodeString, @(operation.error.code)];
            }
        }

#pragma mark Header string (HTTP method, status code, URL)

        NSString *headerString;

        BOOL queryComponentsPresent = NO;
        NSString *queryComponentsString;

        if (operation.request.URL.absoluteString.length > 56) {
            NSArray *URLComponents = [operation.request.URL.absoluteString componentsSeparatedByString:@"?"];
            queryComponentsPresent = URLComponents.count == 2;

            NSString *URLStringWithoutQueryPart = [URLComponents objectAtIndex:0];
            headerString = [NSString stringWithFormat:@("%@ %@"), statusCodeString, URLStringWithoutQueryPart];

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
            queryComponentsString = [queryComponentsStrings componentsJoinedByString:@"\n"];
        } else {
            headerString = [NSString stringWithFormat:@("%@ %@"), statusCodeString, operation.request.URL.absoluteString];
        }

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

        NSUInteger responseDataLength = operation.responseData.length;

        if (responseDataLength == 0) {
            responseBodyString = [responseBodyString stringByAppendingString:@"No response body."];
        }

        else if (0 < responseDataLength && responseDataLength <= ([AFNetworkingLogger sharedLogger].maxResponseBodySizeToLogWithoutTruncationInVerboseMode)) {

            NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

            if (responseDataString) {
                responseBodyString = [responseBodyString stringByAppendingString:responseDataString];
            }

            else {
                if ([AFNetworkingLogger sharedLogger].logResponseBodiesContainingBinaryData) {
                    responseDataString = [NSString stringWithFormat:@"Response contains non-UTF8 data: %@", responseData.description];
                }

                else {
                    responseDataString = [NSString stringWithFormat:@"Response contains non-UTF8 data and is not displayed"];
                }

                responseBodyString = [responseBodyString stringByAppendingString:responseDataString];
            }
        }

        else if (responseDataLength <= ([AFNetworkingLogger sharedLogger].maxResponseBodySizeToLogWithTruncationInVerboseMode)) {

            NSUInteger N = [AFNetworkingLogger sharedLogger].responseBodySymbolsToLogWithTruncationInVerboseMode;

            NSData *truncatedResponseData;

            if (N < responseDataLength) {
                truncatedResponseData = [responseData subdataWithRange:NSMakeRange(0, N)];
            } else {
                truncatedResponseData = responseData;
            }

            NSString *responseDataString = [[NSString alloc] initWithData:truncatedResponseData encoding:NSUTF8StringEncoding];

            if (responseDataString) {
                responseBodyString = [responseBodyString stringByAppendingString:[NSString stringWithFormat:@"%@ ...TRUNCATED...", responseDataString]];
            }

            else {
                if ([AFNetworkingLogger sharedLogger].logResponseBodiesContainingBinaryData) {
                    responseDataString = [NSString stringWithFormat:@"Response contains non-UTF8 data: %@ ...TRUNCATED...", truncatedResponseData.description];
                }

                else {
                    responseDataString = [NSString stringWithFormat:@"Response contains non-UTF8 data and is not displayed"];
                }

                responseBodyString = [responseBodyString stringByAppendingString:responseDataString];
            }
        }

        else {
            responseBodyString = [responseBodyString stringByAppendingString:@"Response body data is too large to be displayed..."];
        }

#pragma mark Aggregation of formatted log string

        NSMutableArray *logComponents = [NSMutableArray array];

        [logComponents addObject:@"\n"];

        if (operation.error && NSURLErrorWarningString) {
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
