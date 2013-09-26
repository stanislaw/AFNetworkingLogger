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

@interface AFNetworkingLoggerLogGeneratorTests : XCTestCase
@end

@implementation AFNetworkingLoggerLogGeneratorTests

- (void)setUp {
    [super setUp];

    AFNetworkingLogger.sharedLogger.level = AFLoggerLevelNormal;
    [AFNetworkingLogger.sharedLogger startLogging];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

    [OHHTTPStubs removeAllStubs];
}

- (void)testExample {
    __block BOOL flag = NO;

    NSDictionary *dictionary = @{ @"KEY": @"VALUE" };

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[dictionary JSONData] statusCode:200 headers:nil];
    }];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.foo.bar"]];
    urlRequest.HTTPBody = [dictionary JSONData];

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

- (void)testExample2 {
    __block BOOL flag = NO;

    NSDictionary *dictionary = @{ @"KEY": @"VALUE" };

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[dictionary JSONData] statusCode:200 headers:nil];
    }];

    NSURL *url = [[NSURL alloc] initWithString:@"https://api.a-a-ah.ru/v1/places?bounds=55.689972,37.770996;55.702354,37.792969&fields=id,lat,lng,type_ru,name_ru,maincategory_id,is_current_user_like,is_current_user_wish&limit=100&order=rating&rating=20&with_photo=1"];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPBody = [dictionary JSONData];

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
