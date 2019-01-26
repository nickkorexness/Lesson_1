#import <WMF/MWKDataObject.h>
@import CoreGraphics;
@class MWKLicense;

NS_ASSUME_NONNULL_BEGIN
@interface MWKImageInfo : MWKDataObject

/// Name of the canonical file associated with this image, in the format @c "File:Some_file_name.extension".
@property (nullable, nonatomic, readonly, copy) NSString *canonicalPageTitle;

/// Name of the file associated with this image, without the "File:" prefix;
- (nullable NSString *)canonicalPageName;

/// URL pointing at the canonical file associated with this gallery item, e.g. @c "//site/.../Some_file_name.extension".
/// @warning These images can be *very* large. Special handling may be needed when downloading or displaying.
@property (nullable, nonatomic, readonly, copy) NSURL *canonicalFileURL;

/// Short description of the image contents (e.g. "John Smith posing for a picture").
@property (nullable, nonatomic, readonly, copy) NSString *imageDescription;

@property (nullable, nonatomic, readonly, strong) MWKLicense *license;

/// URL pointing to the corresponding file page for the receiver.
@property (nullable, nonatomic, readonly, copy) NSURL *filePageURL;

/// URL pointing at a thumbnail version of the image at @c imageURL.
@property (nullable, nonatomic, readonly, copy) NSURL *imageThumbURL;

/// Size of the original image.
@property (nonatomic, readonly, assign) CGSize imageSize;

/// Size of the thumbnail at @c imageThumbURL.
@property (nonatomic, readonly, assign) CGSize thumbSize;

/// Name of the entity owning this image.
@property (nullable, nonatomic, readonly, copy) NSString *owner;

/// Value which can be used to associate the receiver with a @c MWKImage.
@property (nullable, nonatomic, readonly, strong) id imageAssociationValue;

/// Factory method for creating an instance from the output of @c exportData.
+ (instancetype)imageInfoWithExportedData:(nullable NSDictionary *)exportedData;

- (instancetype)initWithCanonicalPageTitle:(nullable NSString *)canonicalPageTitle
                          canonicalFileURL:(nullable NSURL *)canonicalFileURL
                          imageDescription:(nullable NSString *)imageDescription
                                   license:(nullable MWKLicense *)license
                               filePageURL:(nullable NSURL *)filePageURL
                             imageThumbURL:(nullable NSURL *)imageThumbURL
                                     owner:(nullable NSString *)owner
                                 imageSize:(CGSize)imageSize
                                 thumbSize:(CGSize)thumbSize;

@end
NS_ASSUME_NONNULL_END
