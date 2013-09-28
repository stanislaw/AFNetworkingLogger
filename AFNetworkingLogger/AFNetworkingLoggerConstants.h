#pragma mark
#pragma mark NSURLError humanized codes

// https://github.com/stanislaw/FoundationExtensions/blob/master/FoundationExtensions/NSObjCRuntime.h
#define AFNL_NSStringFromMethodForEnumType(_name, _type, _components...) static inline NSString *AFNL_NSStringFrom##_name(_type value) {    \
    NSArray *componentsStrings = [@(#_components) componentsSeparatedByString:@", "];    \
    \
    int N = (sizeof((_type[]){0, ##_components})/sizeof(_type) - 1);    \
    _type componentsCArray[] = { _components };    \
    \
    for (int i = 0; i < N; i++) {    \
        if (componentsCArray[i] == value) return [componentsStrings objectAtIndex:i];    \
    }    \
    \
    return nil;    \
}

AFNL_NSStringFromMethodForEnumType(NSURLErrorCode,
                                   NSInteger,

                                   NSURLErrorCancelled,
                                   NSURLErrorBadURL,
                                   NSURLErrorTimedOut,
                                   NSURLErrorUnsupportedURL,
                                   NSURLErrorCannotFindHost,
                                   NSURLErrorCannotConnectToHost,
                                   NSURLErrorNetworkConnectionLost,
                                   NSURLErrorDNSLookupFailed,
                                   NSURLErrorHTTPTooManyRedirects,
                                   NSURLErrorResourceUnavailable,
                                   NSURLErrorNotConnectedToInternet,
                                   NSURLErrorRedirectToNonExistentLocation,
                                   NSURLErrorBadServerResponse,
                                   NSURLErrorUserCancelledAuthentication,
                                   NSURLErrorUserAuthenticationRequired,
                                   NSURLErrorZeroByteResource,
                                   NSURLErrorCannotDecodeRawData,
                                   NSURLErrorCannotDecodeContentData,
                                   NSURLErrorCannotParseResponse,
                                   NSURLErrorFileIsDirectory,
                                   NSURLErrorFileDoesNotExist,
                                   NSURLErrorNoPermissionsToReadFile,
                                   NSURLErrorDataLengthExceedsMaximum);

static inline NSString * AFNL_NSStringFromNSURLError(NSError *error) {
    return AFNL_NSStringFromNSURLErrorCode(error.code);
}
