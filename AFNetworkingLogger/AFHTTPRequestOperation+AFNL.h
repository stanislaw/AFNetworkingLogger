//
//  AFHTTPRequestOperation+StartDate.h
//  AFNetworkingMeterApp
//
//  Created by Stanislaw Pankevich on 8/21/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

extern void * AFNLHTTPRequestOperationStartDate;

@interface AFHTTPRequestOperation (AFNL)

- (NSDate *)AFNLStartDate;
- (void)setAFNLStartDate:(NSDate *)date;

@end
