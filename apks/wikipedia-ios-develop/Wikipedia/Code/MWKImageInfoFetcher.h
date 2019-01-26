@import WMF.FetcherBase;
@import WMF.WMFBlockDefinitions;

@class MWKArticle;
@class NSURLSessionDataTask;
@class AFHTTPSessionManager;

@protocol MWKImageInfoRequest <NSObject>

- (void)cancel;

@end

@interface MWKImageInfoFetcher : FetcherBase

- (instancetype)initWithDelegate:(id<FetchFinishedDelegate>)delegate;

/**
 * Fetch the imageinfo for the given image page titles.
 * @param imageTitles One or more page titles to get imageinfo for (e.g. @c "File:My_Image_Title.jpg).
 * @param site        A site object for the MW site to target.
 * @return An operation which can be used to set success and failure handling or cancel the originating request.
 */
- (id<MWKImageInfoRequest>)fetchGalleryInfoForImageFiles:(NSArray *)imageTitles
                                             fromSiteURL:(NSURL *)siteURL
                                                 success:(void (^)(NSArray *infoObjects))success
                                                 failure:(void (^)(NSError *error))failure;

- (void)fetchGalleryInfoForImage:(NSString *)canonicalPageTitle fromSiteURL:(NSURL *)siteURL failure:(WMFErrorHandler)failure success:(WMFSuccessIdHandler)success;

/**
 * Fetch @c MWKImageInfo populated with only the data needed for display in the home view.
 *
 * Used in context where only the image URL and description are needed.
 *
 * @param pageTitles       One or more page titles to retrieve images from, and then fetch info for.
 * @param site             A site object for the MW site to target.
 * @param metadataLanguage The langauge to attempt to retrieve image metadata in. Falls back to English if the specified
 *                         langauge isn't available. Defaults to current locale's language if @c nil.
 * @param failure is passed an error on failure
 * @param success is passed @c MWKImageInfo containing info the images found on the specified pages.
 */
- (void)fetchPartialInfoForImagesOnPages:(NSArray *)pageTitles
                             fromSiteURL:(NSURL *)siteURL
                        metadataLanguage:(NSString *)metadataLanguage
                                 failure:(WMFErrorHandler)failure
                                 success:(WMFSuccessIdHandler)success;

/**
 * Fetch @c MWKImageInfo populated with enough suitable for display in a modal gallery.
 *
 * Used in contexts where image URL, description, artist, etc. are needed.
 *
 * @param pageTitles       One or more page titles to retrieve images from, and then fetch info for.
 * @param site             A site object for the MW site to target.
 * @param metadataLanguage The langauge to attempt to retrieve image metadata in. Falls back to English if the specified
 *                         langauge isn't available. Defaults to the current locale's language if @c nil.
 *
 * @param failure is passed an error on failure
 * @param success is passed @c MWKImageInfo containing info the images found on the specified pages.
 */

- (void)fetchGalleryInfoForImagesOnPages:(NSArray *)pageTitles
                             fromSiteURL:(NSURL *)siteURL
                        metadataLanguage:(NSString *)metadataLanguage
                                 failure:(WMFErrorHandler)failure
                                 success:(WMFSuccessIdHandler)success;

- (void)cancelAllFetches;

@end
