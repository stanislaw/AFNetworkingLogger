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


@interface AFNetworkingLoggerVerboseLogGeneratorTests : XCTestCase
@end

@implementation AFNetworkingLoggerVerboseLogGeneratorTests

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

    NSDictionary *HTTPHeaders = @{
        @"Cache-Control"   : @"public, max-age=1800",
        @"Connection"      : @"Keep-Alive",
        @"Content-Length"  : @(50),
        @"Content-Type"    : @"application/json",
        @"Date"            : @"Mon, 23 Sep 2013 23:24:52 GMT",
        @"Expires"         : @"Mon, 23 Sep 2013 23:54:52 GMT",
        @"Keep-Alive"      : @"timeout=15, max=98",
        @"Last-Modified"   : @"",
        @"Pragma"          : @"",
        @"Server"          : @"Apache/2.2.16 (Debian)",
        @"Vary"            : @"Host"
    };

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[dictionary JSONData] statusCode:200 headers:HTTPHeaders];
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

- (void)testExample3 {
    __block BOOL flag = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"www.foo.bar"]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        abort();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        flag = YES;
    }];

    [requestOperation start];

    while (flag == NO) {
        runLoopIfNeeded();
    }
};

- (void)testExample4 {
    __block BOOL flag = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil statusCode:404 headers:nil];
    }];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"www.foo.bar"]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        abort();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        flag = YES;
    }];

    [requestOperation start];

    while (flag == NO) {
        runLoopIfNeeded();
    }
}

@end
