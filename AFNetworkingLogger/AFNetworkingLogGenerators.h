//
//  AFNetworkingLogGenerator.h
//  AFNetworkingLoggerApp
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFHTTPRequestOperation.h>
#import "AFHTTPRequestOperation+AFNL.h"

@protocol AFNetworkingLogGenerator <NSObject>
- (NSString *)generateLogForRequestDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation;
- (NSString *)generateLogForResponseDataOfAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation;
@end

@interface AFNetworkingLogGenerator : NSObject <AFNetworkingLogGenerator>
@end

@interface AFNetworkingVerboseLogGenerator : AFNetworkingLogGenerator
@end
