AFNetworkingLogger
==================

![AFNetworkingLogger example](https://raw.github.com/stanislaw/AFNetworkingLogger/master/Examples/AFNetworkingLogger.png)

Docs are coming...

## Installation

The recommended way is to install via Cocoapods:

Add into your Podfile:

```objective-c
pod 'AFNetworkingLogger', :git => 'https://github.com/stanislaw/AFNetworkingLogger'
```

And run `pod update`.

or you can just clone AFNetworkingLogger repository using git clone and copy the contents of its `AFNetworkingLogger/` folder to your project.

## Usage

You need to start AFNetworkingLogger somewhere. For example, your app's
delegate is a good place to do this:

```objective-c
#import <AFNetworkingLogger.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AFNetworkingLogger.sharedLogger.level = AFNetworkingLoggerLevelVerbose;
    [AFNetworkingLogger.sharedLogger startLogging];

    return YES;
}
```

