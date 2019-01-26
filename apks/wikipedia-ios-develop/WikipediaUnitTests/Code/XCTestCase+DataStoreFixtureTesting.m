#import "XCTestCase+DataStoreFixtureTesting.h"
#import "WMFRandomFileUtilities.h"
#import "XCTestCase+WMFBundleConvenience.h"
#import "MWKDataStore.h"

NS_ASSUME_NONNULL_BEGIN

@implementation XCTestCase (MWKDataStoreFixtureTesting)

- (nullable MWKDataStore *)wmf_temporaryCopyOfDataStoreFixtureAtPath:(NSString *)relativeFolderPath {
    NSString *absFolderPath = [[[self wmf_bundle] resourcePath] stringByAppendingPathComponent:relativeFolderPath];
    NSString *tmpCopyPath = WMFRandomTemporaryPath();
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:absFolderPath toPath:tmpCopyPath error:&error]) {
        [NSException raise:@"MWKLegacyDataFolderCopyError"
                    format:@"Failed to copy legacy data from %@ to %@. %@",
                           absFolderPath, tmpCopyPath, error];
    }
    return [[MWKDataStore alloc] initWithContainerURL:[NSURL fileURLWithPath:tmpCopyPath]];
}

@end

NS_ASSUME_NONNULL_END
