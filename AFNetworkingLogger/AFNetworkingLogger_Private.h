//
//  AFNetworkingLogger_Private.h
//  AFNetworkingLoggerApp
//
//  Created by Stanislaw Pankevich on 9/26/13.
//  Copyright (c) 2013 Stanislaw Pankevich. All rights reserved.
//

#import "AFNetworkingLogger.h"

#import "AFNetworkingLogGenerators.h"

@interface AFNetworkingLogger ()
@property (nonatomic, strong) id <AFNetworkingLogGenerator> logGenerator;
@end
