#import "WMFDailyStatsLoggingFunnel.h"
#import "Wikipedia-Swift.h"
#import <WMF/NSCalendar+WMFCommonCalendars.h>

static NSString *const kAppInstallAgeKey = @"appInstallAgeDays";

@implementation WMFDailyStatsLoggingFunnel

- (instancetype)init {
    // https://meta.wikimedia.org/wiki/Schema:MobileWikiAppDailyStats
    self = [super initWithSchema:@"MobileWikiAppDailyStats" version:12637385];
    return self;
}

- (void)logAppNumberOfDaysSinceInstall {
    NSUserDefaults *userDefaults = [NSUserDefaults wmf_userDefaults];

    NSDate *installDate = [userDefaults wmf_appInstallDate];
    NSParameterAssert(installDate);
    if (!installDate) {
        return;
    }

    NSDate *currentDate = [NSDate date];
    NSInteger daysInstalled = [[NSCalendar wmf_gregorianCalendar] wmf_daysFromDate:installDate toDate:currentDate];

    NSNumber *daysInstalledNumber = [userDefaults wmf_daysInstalled];

    if (daysInstalledNumber != nil) {
        NSInteger lastLoggedDaysInstalled = [daysInstalledNumber integerValue];
        if (lastLoggedDaysInstalled == daysInstalled) {
            return;
        }
    }

    [self log:@{ kAppInstallAgeKey: @(daysInstalled) }];
    [userDefaults wmf_setDaysInstalled:@(daysInstalled)];
}

@end
