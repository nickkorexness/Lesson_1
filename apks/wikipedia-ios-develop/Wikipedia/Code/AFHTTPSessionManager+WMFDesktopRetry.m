#import <WMF/AFHTTPSessionManager+WMFDesktopRetry.h>
#import <WMF/NSError+WMFExtensions.h>
#import <WMF/SessionSingleton.h>
#import <WMF/NSURL+WMFLinkParsing.h>

@implementation AFHTTPSessionManager (WMFDesktopRetry)

- (NSURLSessionDataTask *)wmf_GETWithMobileURLString:(NSString *)mobileURLString
                                    desktopURLString:(NSString *)desktopURLString
                                          parameters:(id)parameters
                                               retry:(void (^)(NSURLSessionDataTask *retryOperation, NSError *error))retry
                                             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure {
    // If Zero rated try mobile domain first if Zero rated, with desktop fallback.
    BOOL isZeroRated = [SessionSingleton sharedInstance].zeroConfigurationManager.isZeroRated;
    if (isZeroRated) {
        return [self GET:mobileURLString
            parameters:parameters
            progress:NULL
            success:^(NSURLSessionDataTask *_Nonnull operation, id _Nonnull responseObject) {
                if (success) {
                    success(operation, responseObject);
                }
            }
            failure:^(NSURLSessionDataTask *_Nonnull operation, NSError *_Nonnull error) {
                if (failure) {
                    failure(operation, error);
                }
            }];
    } else {
        // If not Zero rated use desktop domain only.
        return [self GET:desktopURLString
            parameters:parameters
            progress:NULL
            success:^(NSURLSessionDataTask *_Nonnull operation, id _Nonnull responseObject) {
                if (success) {
                    success(operation, responseObject);
                }
            }
            failure:^(NSURLSessionDataTask *_Nonnull operation, NSError *_Nonnull error) {
                if (failure) {
                    failure(operation, error);
                }
            }];
    }
}

- (NSURLSessionDataTask *)wmf_GETAndRetryWithURL:(NSURL *)URL
                                      parameters:(id)parameters
                                           retry:(void (^)(NSURLSessionDataTask *retryOperation, NSError *error))retry
                                         success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                                         failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure {
    return [self wmf_GETWithMobileURLString:[NSURL wmf_mobileAPIURLForURL:URL].absoluteString
                           desktopURLString:[NSURL wmf_desktopAPIURLForURL:URL].absoluteString
                                 parameters:parameters
                                      retry:retry
                                    success:success
                                    failure:failure];
}

- (NSURLSessionDataTask *)wmf_POSTWithMobileURLString:(NSString *)mobileURLString
                                     desktopURLString:(NSString *)desktopURLString
                                           parameters:(id)parameters
                                                retry:(void (^)(NSURLSessionDataTask *retryOperation, NSError *error))retry
                                              success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                                              failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure {
    return [self POST:mobileURLString
        parameters:parameters
        progress:NULL
        success:^(NSURLSessionDataTask *_Nonnull operation, id _Nonnull responseObject) {
            if (success) {
                success(operation, responseObject);
            }
        }
        failure:^(NSURLSessionDataTask *_Nonnull operation, NSError *_Nonnull error) {
            if (failure) {
                failure(operation, error);
            }
        }];
}

@end
