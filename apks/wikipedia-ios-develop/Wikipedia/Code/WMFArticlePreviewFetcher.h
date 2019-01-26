@import Foundation;
@class MWKSearchResult;

NS_ASSUME_NONNULL_BEGIN

@interface WMFArticlePreviewFetcher : NSObject

- (void)fetchArticlePreviewResultsForArticleURLs:(NSArray<NSURL *> *)articleURLs
                                         siteURL:(NSURL *)siteURL
                                      completion:(void (^)(NSArray<MWKSearchResult *> *results))completion
                                         failure:(void (^)(NSError *error))failure;

- (void)fetchArticlePreviewResultsForArticleURLs:(NSArray<NSURL *> *)articleURLs
                                         siteURL:(NSURL *)siteURL
                                   extractLength:(NSUInteger)extractLength
                                  thumbnailWidth:(NSUInteger)thumbnailWidth
                                      completion:(void (^)(NSArray<MWKSearchResult *> *results))completion
                                         failure:(void (^)(NSError *error))failure;

@property (nonatomic, assign, readonly) BOOL isFetching;

@end

NS_ASSUME_NONNULL_END
