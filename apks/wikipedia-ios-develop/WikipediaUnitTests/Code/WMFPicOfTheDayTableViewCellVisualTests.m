#import "FBSnapshotTestCase+WMFConvenience.h"
#import <Nocilla/LSNocilla.h>

#import "WMFPicOfTheDayCollectionViewCell.h"
#import "UIView+WMFDefaultNib.h"
#import "UIImageView+WMFImageFetchingInternal.h"
#import "WMFHTTPHangingProtocol.h"
#import "WMFAsyncTestCase.h"

@interface WMFPicOfTheDayTableViewCellVisualTests : FBSnapshotTestCase

@property (nonatomic, strong) WMFPicOfTheDayCollectionViewCell *cell;

@end

@implementation WMFPicOfTheDayTableViewCellVisualTests

- (void)setUp {
    [super setUp];
    self.recordMode = WMFIsVisualTestRecordModeEnabled;
    self.deviceAgnostic = YES;
    self.cell = [WMFPicOfTheDayCollectionViewCell wmf_viewFromClassNib];
    [self.cell setDisplayTitle:@"Hey! I'm a display title!"];
    self.cell.potdImageView.wmf_imageController = [WMFImageController temporaryController];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitialStateOnlyShowsPlaceholderWithoutCaption {
    [self wmf_verifyView:self.cell];
}

- (void)testStillShowsPlaceholderWithoutCaptionWhileImageIsDownloading {
    [[LSNocilla sharedInstance] start];
    // using a plain-white image to ensure the gradient is visible
    UIImage *testImage = [UIImage wmf_imageFromColor:[UIColor whiteColor]];
    NSRegularExpression *anyThumbRequest = [NSRegularExpression regularExpressionWithPattern:@"https://upload.wikimedia.org/wikipedia/commons/thumb/.*" options:0 error:nil];
    stubRequest(@"GET", anyThumbRequest).andReturnRawResponse(UIImageJPEGRepresentation(testImage, 0));

    NSURL *testURL = [NSURL URLWithString:@"http://dummyimage.com/foo"];
    NSData *imageData = UIImagePNGRepresentation(testImage);

    stubRequest(@"GET", testURL.absoluteString)
        .andReturnRawResponse(imageData);

    [NSURLProtocol registerClass:[WMFHTTPHangingProtocol class]];
    [self.cell setImageURL:testURL];
    [self wmf_verifyView:self.cell];
    [NSURLProtocol unregisterClass:[WMFHTTPHangingProtocol class]];
    [[LSNocilla sharedInstance] stop];
}

- (void)testShowsCaptionWhenImageIsFinallyDownloaded {
    [[LSNocilla sharedInstance] start];
    // using a plain-white image to ensure the gradient is visible
    UIImage *testImage = [UIImage wmf_imageFromColor:[UIColor whiteColor]];
    NSRegularExpression *anyThumbRequest = [NSRegularExpression regularExpressionWithPattern:@"https://upload.wikimedia.org/wikipedia/commons/thumb/.*" options:0 error:nil];
    stubRequest(@"GET", anyThumbRequest).andReturnRawResponse(UIImageJPEGRepresentation(testImage, 0));

    NSURL *testURL = [NSURL URLWithString:@"http://dummyimage.com/foo"];
    NSData *imageData = UIImagePNGRepresentation(testImage);

    stubRequest(@"GET", testURL.absoluteString)
        .andReturnRawResponse(imageData);

    [self.cell setImageURL:testURL];

    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(UIImageView *_Nonnull potdImageView, NSDictionary<NSString *, id> *_Nullable bindings) {
              NSData *currentImageData = UIImagePNGRepresentation(potdImageView.image);
              return [currentImageData isEqualToData:imageData];
          }]
              evaluatedWithObject:self.cell.potdImageView
                          handler:nil];

    [self waitForExpectationsWithTimeout:WMFDefaultExpectationTimeout handler:nil];

    [self wmf_verifyView:self.cell];
    [[LSNocilla sharedInstance] stop];
}

@end
