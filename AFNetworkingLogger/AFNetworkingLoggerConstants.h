#pragma mark
#pragma mark NSURLError humanized codes

static inline NSDictionary * AFNL_NSURLErrorCodes() {
    static NSDictionary *NSURLErrorCodes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLErrorCodes = @{
            @(NSURLErrorCancelled)                     : @"NSURLErrorCancelled",
            @(NSURLErrorBadURL)                        : @"NSURLErrorBadURL",
            @(NSURLErrorTimedOut)                      : @"NSURLErrorTimedOut",
            @(NSURLErrorUnsupportedURL)                : @"NSURLErrorUnsupportedURL",
            @(NSURLErrorCannotFindHost)                : @"NSURLErrorCannotFindHost",
            @(NSURLErrorCannotConnectToHost)           : @"NSURLErrorCannotConnectToHost",
            @(NSURLErrorNetworkConnectionLost)         : @"NSURLErrorNetworkConnectionLost",
            @(NSURLErrorDNSLookupFailed)               : @"NSURLErrorDNSLookupFailed",
            @(NSURLErrorHTTPTooManyRedirects)          : @"NSURLErrorHTTPTooManyRedirects",
            @(NSURLErrorResourceUnavailable)           : @"NSURLErrorResourceUnavailable",
            @(NSURLErrorNotConnectedToInternet)        : @"NSURLErrorNotConnectedToInternet",
            @(NSURLErrorRedirectToNonExistentLocation) : @"NSURLErrorRedirectToNonExistentLocation",
            @(NSURLErrorBadServerResponse)             : @"NSURLErrorBadServerResponse",
            @(NSURLErrorUserCancelledAuthentication)   : @"NSURLErrorUserCancelledAuthentication",
            @(NSURLErrorUserAuthenticationRequired)    : @"NSURLErrorUserAuthenticationRequired",
            @(NSURLErrorZeroByteResource)              : @"NSURLErrorZeroByteResource",
            @(NSURLErrorCannotDecodeRawData)           : @"NSURLErrorCannotDecodeRawData",
            @(NSURLErrorCannotDecodeContentData)       : @"NSURLErrorCannotDecodeContentData",
            @(NSURLErrorCannotParseResponse)           : @"NSURLErrorCannotParseResponse",
            @(NSURLErrorFileIsDirectory)               : @"NSURLErrorFileIsDirectory",
            @(NSURLErrorFileDoesNotExist)              : @"NSURLErrorFileDoesNotExist",
            @(NSURLErrorNoPermissionsToReadFile)       : @"NSURLErrorNoPermissionsToReadFile",
            @(NSURLErrorDataLengthExceedsMaximum)      : @"NSURLErrorDataLengthExceedsMaximum"
        };
    });
    
    return NSURLErrorCodes;
}
