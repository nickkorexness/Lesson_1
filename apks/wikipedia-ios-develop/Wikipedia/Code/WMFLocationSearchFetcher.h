@import CoreLocation;

@class WMFLocationSearchResults;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WMFLocationSearchErrorDomain;

typedef NS_ENUM(NSUInteger, WMFLocationSearchErrorCode) {
    WMFLocationSearchErrorCodeUnknown = 0,
    WMFLocationSearchErrorCodeNoResults = 1
};

typedef NS_ENUM(NSUInteger, WMFLocationSearchSortStyle) {
    WMFLocationSearchSortStyleNone = 0,
    WMFLocationSearchSortStylePageViews,
    WMFLocationSearchSortStyleLinks,
    WMFLocationSearchSortStylePageViewsAndLinks
};

@interface WMFLocationSearchFetcher : NSObject

- (NSURLSessionDataTask *)fetchArticlesWithSiteURL:(NSURL *)siteURL
                                          location:(CLLocation *)location
                                       resultLimit:(NSUInteger)resultLimit
                                        completion:(void (^)(WMFLocationSearchResults *results))completion
                                           failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)fetchArticlesWithSiteURL:(NSURL *)siteURL
                                          inRegion:(CLCircularRegion *)region
                                matchingSearchTerm:(nullable NSString *)searchTerm
                                         sortStyle:(WMFLocationSearchSortStyle)sortStyle
                                       resultLimit:(NSUInteger)resultLimit
                                        completion:(void (^)(WMFLocationSearchResults *results))completion
                                           failure:(void (^)(NSError *error))failure;

- (BOOL)isFetching;

@end

NS_ASSUME_NONNULL_END
