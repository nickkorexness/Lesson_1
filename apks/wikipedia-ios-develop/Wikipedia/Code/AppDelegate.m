#import "AppDelegate.h"
@import UserNotifications;
@import WMF.NSUserActivity_WMFExtensions;
@import WMF.PiwikTracker_WMFExtensions;
@import WMF.NSFileManager_WMFGroup;
#import "BITHockeyManager+WMFExtensions.h"
#import "WMFAppViewController.h"
#import "UIApplicationShortcutItem+WMFShortcutItem.h"
#import "Wikipedia-Swift.h"
#import "WMFQuoteMacros.h"

static NSTimeInterval const WMFBackgroundFetchInterval = 10800; // 3 Hours

@interface AppDelegate ()

@property (nonatomic, strong) WMFAppViewController *appViewController;
@property (nonatomic) BOOL appNeedsResume;

@end

@implementation AppDelegate

#pragma mark - Defaults

+ (void)load {
    /**
     * Register default application preferences.
     * @note This must be loaded before application launch so unit tests can run
     */
    NSString *defaultLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    [[NSUserDefaults wmf_userDefaults] registerDefaults:@{
        @"CurrentArticleDomain": defaultLanguage,
        @"Domain": defaultLanguage,
        WMFZeroWarnWhenLeaving: @YES,
        WMFZeroOnDialogShownOnce: @NO,
        @"LastHousekeepingDate": [NSDate date],
        @"SendUsageReports": @NO,
        @"AccessSavedPagesMessageShown": @NO
    }];
}

#pragma mark - Accessors

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _window;
}

#pragma mark - Shortcuts

- (void)updateDynamicIconShortcutItems {
    if (![[UIApplication sharedApplication] respondsToSelector:@selector(shortcutItems)]) {
        return;
    }

    NSMutableArray<UIApplicationShortcutItem *> *shortcutItems =
        [[NSMutableArray alloc] initWithObjects:
                                    [UIApplicationShortcutItem wmf_random],
                                    [UIApplicationShortcutItem wmf_nearby],
                                    nil];

    [shortcutItems addObject:[UIApplicationShortcutItem wmf_search]];

    [UIApplication sharedApplication].shortcutItems = shortcutItems;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if WMF_IS_NEW_EVENT_LOGGING_ENABLED
    [[WMFEventLoggingService sharedInstance] start];
#endif

    [application setMinimumBackgroundFetchInterval:WMFBackgroundFetchInterval];
#if DEBUG
    NSLog(@"\n\nSimulator documents directory:\n\t%@\n\n",
          [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    NSLog(@"\n\nSimulator container directory:\n\t%@\n\n",
          [[NSFileManager defaultManager] wmf_containerPath]);
#endif
    [NSUserDefaults wmf_migrateToWMFGroupUserDefaultsIfNecessary];
    [[NSUserDefaults wmf_userDefaults] wmf_migrateFontSizeMultiplier];
    [[BITHockeyManager sharedHockeyManager] wmf_setupAndStart];
    [PiwikTracker wmf_start];

    [[NSUserDefaults wmf_userDefaults] wmf_setAppLaunchDate:[NSDate date]];
    [[NSUserDefaults wmf_userDefaults] wmf_setAppInstallDateIfNil:[NSDate date]];

    self.appNeedsResume = YES;
    WMFAppViewController *vc = [WMFAppViewController initialAppViewControllerFromDefaultStoryBoard];
    [UNUserNotificationCenter currentNotificationCenter].delegate = vc; // this needs to be set before the end of didFinishLaunchingWithOptions:
    [vc launchAppInWindow:self.window waitToResumeApp:self.appNeedsResume];
    self.appViewController = vc;

    [self updateDynamicIconShortcutItems];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSUserDefaults wmf_userDefaults] wmf_setAppBecomeActiveDate:[NSDate date]];
    [self resumeAppIfNecessary];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [self.appViewController processShortcutItem:shortcutItem completion:completionHandler];
}

#pragma mark - AppVC Resume

- (void)resumeAppIfNecessary {
    if (self.appNeedsResume) {
#if WMF_IS_NEW_EVENT_LOGGING_ENABLED
        [[WMFEventLoggingService sharedInstance] start];
#endif
        [self.appViewController hideSplashScreenAndResumeApp];
        self.appNeedsResume = false;
    }
}

#pragma mark - NSUserActivity Handling

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL result = [self.appViewController processUserActivity:userActivity
                                                     animated:NO
                                                   completion:^{
                                                       [self resumeAppIfNecessary];
                                                   }];
    return result;
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error {
    DDLogDebug(@"didFailToContinueUserActivityWithType: %@ error: %@", userActivityType, error);
}

- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity {
    DDLogDebug(@"didUpdateUserActivity: %@", userActivity);
}

#pragma mark - NSURL Handling

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
    return [self application:application openURL:url options:@{}];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    if (activity) {
        BOOL result = [self.appViewController processUserActivity:activity
                                                         animated:NO
                                                       completion:^{
                                                           [self resumeAppIfNecessary];
                                                       }];
        return result;
    } else {
        [self resumeAppIfNecessary];
        return NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSUserDefaults wmf_userDefaults] wmf_setAppResignActiveDate:[NSDate date]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self updateDynamicIconShortcutItems];
#if WMF_IS_NEW_EVENT_LOGGING_ENABLED
    [[WMFEventLoggingService sharedInstance] stop];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self applicationDidEnterBackground:application];
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self.appViewController performBackgroundFetchWithCompletion:completionHandler];
}

@end
