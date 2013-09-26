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

You need to start AFNetworkingLogger somewhere. For example, your app's delegate is a good place to do this:

```objective-c
#import <AFNetworkingLogger.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    AFNetworkingLogger.sharedLogger.level = AFNetworkingLoggerLevelVerbose;
    [AFNetworkingLogger.sharedLogger startLogging];

    return YES;
}
```

## TODO

...

## Credits

AFNetworkingLogger was created by Stanislaw Pankevich.

Thanks to Marina Balioura (@mettta) for her amazing contribution to the design of AFNetworkingLogger console-text output format: rigorous, clear, informative.
 
`AFNetworkingLogger` is a plugin for [AFNetworking](https://github.com/AFNetworking/AFNetworking) library created by [Mattt Thompson](http://github.com/mattt).

AFNetworkingLogger is inspired by the design of the similar `AFNetworking` plugin [AFHTTPRequestOperationLogger](https://github.com/AFNetworking/AFHTTPRequestOperationLogger), that was as well created by [Mattt Thompson](http://github.com/mattt).

## Copyright

Not yet.

