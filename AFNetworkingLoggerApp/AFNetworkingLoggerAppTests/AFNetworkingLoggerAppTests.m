//
//  AFNetworkingLoggerAppTests.m
//  AFNetworkingLoggerAppTests
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//


#import "TestHelpers.h"

#import <AFNetworking/AFNetworking.h>
#import "AFNetworkingLogger.h"

@interface AFNetworkingLoggerAppTests : XCTestCase

@end

@implementation AFNetworkingLoggerAppTests

- (void)setUp {
    [super setUp];

    [AFNetworkingLogger.sharedLogger startLogging];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSDictionary *dictionary = @{ @"KEY": @"VALUE" };

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[dictionary JSONData] statusCode:200 responseTime:0 headers:nil];
    }];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"www.foo.bar"]];
    urlRequest.HTTPBody = [dictionary JSONData];

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Received data: %@", [operation.responseData objectFromJSONData]);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        abort();
    }];

    [requestOperation start];

    runLoopIfNeeded();
}

@end
