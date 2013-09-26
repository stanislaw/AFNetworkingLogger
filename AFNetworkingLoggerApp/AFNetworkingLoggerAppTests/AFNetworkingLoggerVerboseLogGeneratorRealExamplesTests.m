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


@interface AFNetworkingLoggerVerboseLogGeneratorRealExamplesTests : XCTestCase
@end

@implementation AFNetworkingLoggerVerboseLogGeneratorRealExamplesTests

- (void)setUp {
    [super setUp];

    AFNetworkingLogger.sharedLogger.level = AFLoggerLevelVerbose;
    [AFNetworkingLogger.sharedLogger startLogging];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

    [OHHTTPStubs removeAllStubs];
}

- (void)testExample {
    __block BOOL flag = NO;

    NSURL *url = [[NSURL alloc] initWithString:@"https://www.google.com.ua/search?q=W+A+Mozart&ie=utf-8&oe=utf-8&rls=org.mozilla:en-US:official&client=firefox-a&channel=fflb&gws_rd=cr&ei=Z_9DUubbM8rAhAent4DIBg"];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        flag = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        abort();
    }];

    [requestOperation start];

    while(flag == NO) {
        runLoopIfNeeded();
    }
}


@end
