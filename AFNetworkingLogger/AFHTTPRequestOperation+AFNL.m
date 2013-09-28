//
//  AFHTTPRequestOperation+StartDate.m
//  AFNetworkingMeterApp
//
//  Created by Stanislaw Pankevich on 8/21/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFHTTPRequestOperation+AFNL.h"
#import <objc/runtime.h>

void * AFNLHTTPRequestOperationStartDate = &AFNLHTTPRequestOperationStartDate;

@implementation AFHTTPRequestOperation (AFNL)

- (NSDate *)AFNLStartDate {
    return objc_getAssociatedObject(self, AFNLHTTPRequestOperationStartDate);
}

- (void)setAFNLStartDate:(NSDate *)date {
    objc_setAssociatedObject(self, AFNLHTTPRequestOperationStartDate, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
