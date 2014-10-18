AFNetworkingLogger
==================

![AFNetworkingLogger example](https://raw.github.com/stanislaw/AFNetworkingLogger/master/Examples/AFNetworkingLogger.png)

## Overview

AFNetworkingLogger is a grateful child of [AFHTTPRequestOperationLogger](https://github.com/AFNetworking/AFHTTPRequestOperationLogger) created by Mattt Thompson (@mattt) for [AFNetworking](https://github.com/AFNetworking/AFNetworking) library. It is not the one: there is also its closest brother and companion [AFNetworkingMeter](https://github.com/stanislaw/AFNetworkingMeter) - they share similar design and are both built for the same purpose: to make a HTTP-logging routine for a daily basis of iOS/Mac development easy and informative.

Features list:

* Logging of HTTP interactions performed by iOS / Mac OS X applications.  AFNetworkingLogger logs the following HTTP data: 
    * HTTP methods: GET, POST, ...
    * HTTP headers Keep-Alive, Last-Modified, ... 
    * HTTP body: no comments. Large bodies are truncated
    * HTTP size: headers + body.
    * HTTP elapsed time: a time beetween `AFNetworkingOperationDidStartNotification` and `AFNetworkingOperationDidFinishNotification`. 

* Two levels of verbosity: normal (one string for one request like in [AFHTTPRequestOperationLogger](https://github.com/AFNetworking/AFHTTPRequestOperationLogger)) and verbose (example above).
* Logging HTTP errors and networking errors: both HTTP 400-600 errors and Cocoa NSURL-based errors (NSURLErrorNotConnectedToInternet and friends).
* Error-only logging.
* Remote logging: configure AFNetworkingLogger for logging inside your TestFlight builds by writing custom C function to stand proxy for TestFlight's `TFLog/TFLogv` functions.

----

__Note.__ AFNetworkingLogger does not support logging of NSURLSession-based operations.

----

## Installation

The recommended way is to install via Cocoapods:

Add into your Podfile:

```objective-c
pod 'AFNetworkingLogger', :git => 'https://github.com/stanislaw/AFNetworkingLogger'
```

And run `pod update`.

or you can just clone AFNetworkingLogger repository using git clone and copy the contents of its `AFNetworkingLogger/` folder to your project.

## Usage

You need to start AFNetworkingLogger somewhere. For example, your app's delegate is a good place to do this:

```objective-c
#import <AFNetworkingLogger.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [AFNetworkingLogger.sharedLogger startLogging];

    return YES;
}
```

## Configuration

### Logging levels

```objective-c
AFNetworkingLogger.sharedLogger.level = AFNetworkingLoggerLevelVerbose;
```

### Output

```objective-c
[AFNetworkingLogger sharedLogger].output = &printf; // Any other printf-like function is fine.
```

### Errors-only logging

The following will make AFNetworkingLogger to register only erroneuous HTTP responses: HTTP 400-600 errors and/or Cocoa NSURLError-based errors (including non-HTTP connection errors likeNSURLErrorNotConnectedToInternet).

```objective-c
[AFNetworkingLogger sharedLogger].errorsOnlyLogging = YES; 
```

## Remote logging

The following is an example of how to configure an iOS application for remote logging while it performs its TestFlight:

```objective-c
#import <TestFlightSDK/TestFlight.h>

int AFNetworkingRemoteLoggingCFunction(const char * format, ... ) {
    va_list arguments;

    va_start(arguments, format);

    NSString *formatString = [NSString stringWithUTF8String:format];

    TFLogv(formatString, arguments);

    va_end(arguments);

    return 0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // see https://github.com/stanislaw/iosenv
    if (isProduction()) { 
        [AFNetworkingLogger sharedLogger].output = &AFNetworkingRemoteLoggingCFunction;
        [AFNetworkingLogger sharedLogger].errorsOnlyLogging = YES;
        [AFNetworkingLogger startLogging];
    }
    
    // ...

    return YES;
}
```

## Notes
 
* Currently `AFNetworkingLogger` calculates HTTP headers size using `-[NSPropertyListSerialization dataFromPropertyList:...` (-[NSURLRequest allHTTPHeaderFields] => NSData). Let me know if there is a more precise way of doing this.
* This line is designated for excuses about Russian/Ukrainian english that probably resulted in some misspelings exist somewhere in this README. The author will be thankful for any spelling corrections that might appear.

## Credits

AFNetworkingLogger was created by Stanislaw Pankevich.

Thanks to Marina Balioura (@mettta) for her amazing contribution to the design of AFNetworkingLogger console-text output format: rigorous, clear and informative.
 
AFNetworkingLogger is a plugin for [AFNetworking](https://github.com/AFNetworking/AFNetworking) library created by [Mattt Thompson](http://github.com/mattt).

AFNetworkingLogger is inspired by the design of the similar [AFNetworking](https://github.com/AFNetworking/AFNetworking) plugin [AFHTTPRequestOperationLogger](https://github.com/AFNetworking/AFHTTPRequestOperationLogger), that was as well created by [Mattt Thompson](http://github.com/mattt).

## Copyright

Copyright (c) 2013, 2014 Stanislaw Pankevich. See LICENSE for details.
 
