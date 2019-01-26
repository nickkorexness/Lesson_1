#import "PreviewAndSaveViewController.h"
#import "PreviewHtmlFetcher.h"
#import "WikiTextSectionUploader.h"
#import <WMF/SessionSingleton.h>
#import "PreviewWebViewContainer.h"
#import "PaddedLabel.h"
#import "MenuButton.h"
#import "EditSummaryViewController.h"
#import "PreviewLicenseView.h"
#import "UIScrollView+ScrollSubviewToLocation.h"
#import "AbuseFilterAlert.h"
#import <WMF/MWLanguageInfo.h>
#import "UIViewController+WMFStoryboardUtilities.h"
#import "UIBarButtonItem+WMFButtonConvenience.h"
#import "SavedPagesFunnel.h"
#import "EditFunnel.h"
#import "WMFOpenExternalLinkDelegateProtocol.h"
#import "Wikipedia-Swift.h"
#import "UIViewController+WMFOpenExternalUrl.h"
#import <WMF/AFHTTPSessionManager+WMFCancelAll.h>

typedef NS_ENUM(NSInteger, WMFCannedSummaryChoices) {
    CANNED_SUMMARY_TYPOS,
    CANNED_SUMMARY_GRAMMAR,
    CANNED_SUMMARY_LINKS,
    CANNED_SUMMARY_OTHER
};

typedef NS_ENUM(NSInteger, WMFPreviewAndSaveMode) {
    PREVIEW_MODE_EDIT_WIKITEXT,
    PREVIEW_MODE_EDIT_WIKITEXT_WARNING,
    PREVIEW_MODE_EDIT_WIKITEXT_DISALLOW,
    PREVIEW_MODE_EDIT_WIKITEXT_PREVIEW,
    PREVIEW_MODE_EDIT_WIKITEXT_CAPTCHA
};

@interface PreviewAndSaveViewController () <FetchFinishedDelegate, UITextFieldDelegate, UIScrollViewDelegate, WMFOpenExternalLinkDelegate, WMFPreviewSectionLanguageInfoDelegate, WMFPreviewAnchorTapAlertDelegate, PreviewLicenseViewDelegate, WMFCaptchaViewControllerDelegate>

@property (strong, nonatomic) WMFCaptchaViewController *captchaViewController;
@property (strong, nonatomic) IBOutlet UIView *captchaContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *captchaScrollView;
@property (strong, nonatomic) IBOutlet UIView *captchaScrollContainer;
@property (weak, nonatomic) IBOutlet UIView *previewLabelContainer;

@property (strong, nonatomic) IBOutlet UIView *editSummaryContainer;
@property (strong, nonatomic) IBOutlet PreviewWebViewContainer *previewWebViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWebViewHeightConstraint;
@property (strong, nonatomic) UILabel *aboutLabel;
@property (strong, nonatomic) MenuButton *cannedSummary01;
@property (strong, nonatomic) MenuButton *cannedSummary02;
@property (strong, nonatomic) MenuButton *cannedSummary03;
@property (strong, nonatomic) MenuButton *cannedSummary04;
@property (nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) IBOutlet PreviewLicenseView *previewLicenseView;
@property (strong, nonatomic) UIGestureRecognizer *previewLicenseTapGestureRecognizer;
@property (strong, nonatomic) IBOutlet PaddedLabel *previewLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *scrollContainer;
@property (strong, nonatomic) UIBarButtonItem *buttonSave;
@property (strong, nonatomic) UIBarButtonItem *buttonNext;
@property (strong, nonatomic) UIBarButtonItem *buttonX;
@property (strong, nonatomic) UIBarButtonItem *buttonLeftCaret;
@property (strong, nonatomic) NSString *abuseFilterCode;

//@property (nonatomic) BOOL saveAutomaticallyIfSignedIn;

@property (nonatomic) WMFPreviewAndSaveMode mode;

@property (strong, nonatomic) WikiTextSectionUploader *wikiTextSectionUploader;
@property (strong, nonatomic) PreviewHtmlFetcher *previewHtmlFetcher;
@property (strong, nonatomic) WMFAuthTokenFetcher *editTokenFetcher;

@property (strong, nonatomic) WMFTheme *theme;

@end

@implementation PreviewAndSaveViewController

- (void)dealloc {
    [self.previewWebViewContainer.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (NSString *)getSummary {
    NSMutableArray *summaryArray = @[].mutableCopy;

    if (self.cannedSummary01.enabled) {
        [summaryArray addObject:self.cannedSummary01.text];
    }
    if (self.cannedSummary02.enabled) {
        [summaryArray addObject:self.cannedSummary02.text];
    }
    if (self.cannedSummary03.enabled) {
        [summaryArray addObject:self.cannedSummary03.text];
    }

    if (self.cannedSummary04.enabled) {
        if (self.summaryText && (self.summaryText.length > 0)) {
            [summaryArray addObject:self.summaryText];
        }
    }

    return [summaryArray componentsJoinedByString:@"; "];
}

- (void)wmf_showAlertForTappedAnchorHref:(NSString *)href {
    NSString *title = WMFLocalizedStringWithDefaultValue(@"wikitext-preview-link-preview-title", nil, nil, @"Link preview", @"Title for link preview popup");
    NSString *message = [NSString localizedStringWithFormat:WMFLocalizedStringWithDefaultValue(@"wikitext-preview-link-preview-description", nil, nil, @"This link leads to '%1$@'", @"Description of the link URL. %1$@ is the URL."), href];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:WMFLocalizedStringWithDefaultValue(@"button-ok", nil, nil, @"OK", @"Button text for ok button used in various places\n{{Identical|OK}}")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController
                       animated:YES
                     completion:^{
                     }];
}

- (void)setMode:(WMFPreviewAndSaveMode)mode {
    _mode = mode;

    [self updateNavigationForMode:mode];
}

- (void)updateNavigationForMode:(WMFPreviewAndSaveMode)mode {
    UIBarButtonItem *backButton = nil;
    UIBarButtonItem *forwardButton = nil;

    switch (mode) {
        case PREVIEW_MODE_EDIT_WIKITEXT:
            backButton = self.buttonLeftCaret;
            forwardButton = self.buttonNext;
            break;
        case PREVIEW_MODE_EDIT_WIKITEXT_WARNING:
            backButton = self.buttonLeftCaret;
            forwardButton = self.buttonSave;
            break;
        case PREVIEW_MODE_EDIT_WIKITEXT_DISALLOW:
            backButton = self.buttonLeftCaret;
            forwardButton = nil;
            break;
        case PREVIEW_MODE_EDIT_WIKITEXT_PREVIEW:
            backButton = self.buttonLeftCaret;
            forwardButton = self.buttonSave;
            break;
        case PREVIEW_MODE_EDIT_WIKITEXT_CAPTCHA:
            backButton = self.buttonX;
            forwardButton = self.buttonSave;
            break;
        default:
            break;
    }

    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = forwardButton;
}

- (void)goBack {
    if (self.mode == PREVIEW_MODE_EDIT_WIKITEXT_WARNING) {
        [self.funnel logAbuseFilterWarningBack:self.abuseFilterCode];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goForward {
    switch (self.mode) {
        case PREVIEW_MODE_EDIT_WIKITEXT_WARNING:
            [self save];
            [self.funnel logAbuseFilterWarningIgnore:self.abuseFilterCode];
            break;
        case PREVIEW_MODE_EDIT_WIKITEXT_CAPTCHA:
            [self save];
            break;
        default:
            [self save];
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.theme) {
        self.theme = [WMFTheme standard];
    }

    self.previewLicenseView.previewLicenseViewDelegate = self;
    self.previewWebViewContainer.externalLinksOpenerDelegate = self;

    self.buttonX = [UIBarButtonItem wmf_buttonType:WMFButtonTypeX target:self action:@selector(goBack)];

    self.buttonLeftCaret = [UIBarButtonItem wmf_buttonType:WMFButtonTypeCaretLeft target:self action:@selector(goBack)];

    self.buttonSave = [[UIBarButtonItem alloc] initWithTitle:WMFLocalizedStringWithDefaultValue(@"button-publish", nil, nil, @"Publish", @"Button text for publish button used in various places.\n{{Identical|Publish}}") style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];

    self.mode = PREVIEW_MODE_EDIT_WIKITEXT_PREVIEW;

    self.summaryText = @"";

    self.previewLabel.font = [UIFont boldSystemFontOfSize:15.0];

    self.previewLabel.text = WMFLocalizedStringWithDefaultValue(@"navbar-title-mode-edit-wikitext-preview", nil, nil, @"Preview", @"Header text shown when wikitext changes are being previewed.\n{{Identical|Preview}}");

    [self.previewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewLabelTapped:)]];

    //self.saveAutomaticallyIfSignedIn = NO;

    [self.funnel logPreview];

    self.borderWidth = 1.0f / [UIScreen mainScreen].scale;

    [self setupEditSummaryContainerSubviews];

    [self constrainEditSummaryContainerSubviews];

    // Disable the preview web view's scrolling since we're going to size it
    // such that its internal scroll view isn't ever going to be visble anyway.
    self.previewWebViewContainer.webView.scrollView.scrollEnabled = NO;

    // Observer the web view's contentSize property to enable the web view to expand to the
    // height of the html content it is displaying so the web view's scroll view doesn't show
    // any scroll bars. (Expand the web view to the full height of its content so it scrolls
    // with this view controller's scroll view rather than its own.) Note that to make this
    // work, the PreviewWebView object also uses a method called
    // "forceScrollViewContentSizeToReflectActualHTMLHeight".
    [self.previewWebViewContainer.webView.scrollView addObserver:self
                                                      forKeyPath:@"contentSize"
                                                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                                         context:nil];
    [self preview];
    [self applyTheme:self.theme];
}

- (void)previewLabelTapped:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.scrollView scrollSubViewToTop:self.previewLabel animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (
        (object == self.previewWebViewContainer.webView.scrollView) &&
        [keyPath isEqual:@"contentSize"]) {
        // Size the web view to the height of the html content it is displaying (gets rid of the web view's scroll bars).
        // Note: the PreviewWebView class has to call "forceScrollViewContentSizeToReflectActualHTMLHeight" in its
        // overridden "layoutSubviews" method for the contentSize to be reported accurately such that it reflects the
        // actual height of the web view content here. Without the web view class calling this method in its
        // layoutSubviews, the contentSize.height wouldn't change if we, say, rotated the device.
        self.previewWebViewHeightConstraint.constant = self.previewWebViewContainer.webView.scrollView.contentSize.height;
    }
}

- (void)constrainEditSummaryContainerSubviews {
    NSDictionary *views = @{
        @"aboutLabel": self.aboutLabel,
        @"cannedSummary01": self.cannedSummary01,
        @"cannedSummary02": self.cannedSummary02,
        @"cannedSummary03": self.cannedSummary03,
        @"cannedSummary04": self.cannedSummary04
    };

    // Tighten up the spacing for 3.5 inch screens.
    CGFloat spaceAboveCC = ([UIScreen mainScreen].bounds.size.height != 480) ? 43 : 4;

    NSDictionary *metrics = @{
        @"buttonHeight": @(48),
        @"spaceAboveCC": @(spaceAboveCC)
    };

    NSArray *constraints = @[
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[aboutLabel]|"
                                                options:0
                                                metrics:metrics
                                                  views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cannedSummary01]"
                                                options:0
                                                metrics:metrics
                                                  views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cannedSummary02]"
                                                options:0
                                                metrics:metrics
                                                  views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cannedSummary03]"
                                                options:0
                                                metrics:metrics
                                                  views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cannedSummary04]"
                                                options:0
                                                metrics:metrics
                                                  views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40)-[aboutLabel]-(5)-[cannedSummary01(buttonHeight)][cannedSummary02(buttonHeight)][cannedSummary03(buttonHeight)][cannedSummary04(buttonHeight)]-(spaceAboveCC)-|"
                                                options:0
                                                metrics:metrics
                                                  views:views]
    ];
    [self.editSummaryContainer addConstraints:[constraints valueForKeyPath:@"@unionOfArrays.self"]];
}

- (void)setupEditSummaryContainerSubviews {
    // Setup the canned edit summary buttons.
    UIColor *color = self.theme.colors.link;
    UIEdgeInsets padding = UIEdgeInsetsMake(6, 10, 6, 10);
    UIEdgeInsets margin = UIEdgeInsetsMake(8, 0, 8, 0);
    CGFloat fontSize = 14.0;

    MenuButton * (^setupButton)(NSString *, NSInteger) = ^MenuButton *(NSString *text, WMFCannedSummaryChoices tag) {
        MenuButton *button = [[MenuButton alloc] initWithText:text
                                                     fontSize:fontSize
                                                         bold:NO
                                                        color:color
                                                      padding:padding
                                                       margin:margin];
        button.enabled = NO;
        button.tag = tag;
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)]];
        [self.editSummaryContainer addSubview:button];
        return button;
    };

    self.cannedSummary01 = setupButton(WMFLocalizedStringWithDefaultValue(@"edit-summary-choice-fixed-typos", nil, nil, @"Fixed typo", @"Button text for quick 'fixed typos' edit summary selection"), CANNED_SUMMARY_TYPOS);
    self.cannedSummary02 = setupButton(WMFLocalizedStringWithDefaultValue(@"edit-summary-choice-fixed-grammar", nil, nil, @"Fixed grammar", @"Button text for quick 'improved grammar' edit summary selection"), CANNED_SUMMARY_GRAMMAR);
    self.cannedSummary03 = setupButton(WMFLocalizedStringWithDefaultValue(@"edit-summary-choice-linked-words", nil, nil, @"Added links", @"Button text for quick 'link addition' edit summary selection"), CANNED_SUMMARY_LINKS);
    self.cannedSummary04 = setupButton(WMFLocalizedStringWithDefaultValue(@"edit-summary-choice-other", nil, nil, @"Other", @"Button text for quick \"other\" edit summary selection.\n{{Identical|Other}}"), CANNED_SUMMARY_OTHER);

    // Setup the canned edit summaries label.
    self.aboutLabel = [[UILabel alloc] init];
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.aboutLabel.textColor = self.theme.colors.secondaryText;
    self.aboutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.aboutLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.aboutLabel.text = WMFLocalizedStringWithDefaultValue(@"edit-summary-title", nil, nil, @"How did you improve the article?", @"Title for edit summary area of the preview page");
    self.aboutLabel.textAlignment = NSTextAlignmentNatural;

    [self.editSummaryContainer addSubview:self.aboutLabel];
}

- (void)buttonTapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MenuButton *tappedButton = (MenuButton *)recognizer.view;

        NSString *summaryKey;
        switch (tappedButton.tag) {
            case CANNED_SUMMARY_TYPOS:
                summaryKey = @"typo";
                break;
            case CANNED_SUMMARY_GRAMMAR:
                summaryKey = @"grammar";
                break;
            case CANNED_SUMMARY_LINKS:
                summaryKey = @"links";
                break;
            case CANNED_SUMMARY_OTHER:
                summaryKey = @"other";
                break;
            default:
                NSLog(@"unrecognized button");
        }
        [self.funnel logEditSummaryTap:summaryKey];

        switch (tappedButton.tag) {
            case CANNED_SUMMARY_OTHER:
                [self showSummaryOverlay];
                break;

            default:
                tappedButton.enabled = !tappedButton.enabled;

                break;
        }
    }
}

- (void)showSummaryOverlay {
    EditSummaryViewController *summaryVC = [EditSummaryViewController wmf_initialViewControllerFromClassStoryboard];
    // Set the overlay's text field to self.summaryText so it can display
    // any existing value (in case user taps "Other" again)
    summaryVC.summaryText = self.summaryText;
    summaryVC.previewVC = self;
    [summaryVC applyTheme:self.theme];
    [self presentViewController:[[WMFThemeableNavigationController alloc] initWithRootViewController:summaryVC theme:self.theme] animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.captchaScrollView.alpha = 0.0f;

    self.captchaViewController = [WMFCaptchaViewController wmf_initialViewControllerFromClassStoryboard];
    self.captchaViewController.captchaDelegate = self;
    [self wmf_addWithChildController:self.captchaViewController andConstrainToEdgesOfContainerView:self.captchaContainer];

    self.mode = PREVIEW_MODE_EDIT_WIKITEXT_PREVIEW;

    //[self saveAutomaticallyIfNecessary];

    // Highlight the "Other" button if the user entered some "other" text.
    self.cannedSummary04.enabled = (self.summaryText.length > 0) ? YES : NO;

    if ([[WMFAuthenticationManager sharedInstance] isLoggedIn]) {
        self.previewLicenseView.licenseLoginLabel.userInteractionEnabled = NO;
        self.previewLicenseView.licenseLoginLabel.attributedText = nil;
    } else {
        self.previewLicenseView.licenseLoginLabel.userInteractionEnabled = YES;
    }

    self.previewLicenseTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(licenseLabelTapped:)];
    [self.previewLicenseView.licenseLoginLabel addGestureRecognizer:self.previewLicenseTapGestureRecognizer];

    self.previewWebViewContainer.webView.scrollView.delegate = self;

    [super viewWillAppear:animated];
}

- (void)licenseLabelTapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Call if user taps the blue "Log In" text in the CC text.
        //self.saveAutomaticallyIfSignedIn = YES;
        WMFLoginViewController *loginVC = [WMFLoginViewController wmf_initialViewControllerFromClassStoryboard];
        loginVC.funnel = [[LoginFunnel alloc] init];
        [loginVC.funnel logStartFromEdit:self.funnel.editSessionToken];
        [loginVC applyTheme:self.theme];
        UINavigationController *nc = [[WMFThemeableNavigationController alloc] initWithRootViewController:loginVC theme:self.theme];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)highlightCaptchaSubmitButton:(BOOL)highlight {
    self.buttonSave.enabled = highlight;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.previewWebViewContainer.webView.scrollView.delegate = nil;

    [[WMFAlertManager sharedInstance] dismissAlert];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"TabularScrollViewItemTapped"
                                                  object:nil];

    [self.previewLicenseView.licenseLoginLabel removeGestureRecognizer:self.previewLicenseTapGestureRecognizer];

    [super viewWillDisappear:animated];
}

- (MWLanguageInfo *)wmf_editedSectionLanguageInfo {
    return [MWLanguageInfo languageInfoForCode:self.section.url.wmf_language];
}

- (void)fetchFinished:(id)sender
          fetchedData:(id)fetchedData
               status:(FetchFinalStatus)status
                error:(NSError *)error {
    if ([sender isKindOfClass:[PreviewHtmlFetcher class]]) {
        switch (status) {
            case FETCH_FINAL_STATUS_SUCCEEDED: {
                [[WMFAlertManager sharedInstance] dismissAlert];
                [self.previewWebViewContainer.webView loadHTML:fetchedData baseURL:[NSURL URLWithString:@"https://wikipedia.org"] withAssetsFile:@"preview.html" scrolledToFragment:nil padding:UIEdgeInsetsZero theme:self.theme];
            } break;
            case FETCH_FINAL_STATUS_FAILED: {
                [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];
            } break;
            case FETCH_FINAL_STATUS_CANCELLED: {
                [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];
            } break;
        }
    } else if ([sender isKindOfClass:[WikiTextSectionUploader class]]) {
        //WikiTextSectionUploader* uploader = (WikiTextSectionUploader*)sender;

        switch (status) {
            case FETCH_FINAL_STATUS_SUCCEEDED: {
                [self.funnel logSavedRevision:[fetchedData[@"newrevid"] intValue]];
                dispatchOnMainQueue(^{
                    [self.delegate previewViewControllerDidSave:self];
                });
            } break;

            case FETCH_FINAL_STATUS_CANCELLED: {
                [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];
            } break;

            case FETCH_FINAL_STATUS_FAILED: {

                switch (error.code) {
                    case WIKITEXT_UPLOAD_ERROR_NEEDS_CAPTCHA: {
                        if (self.mode == PREVIEW_MODE_EDIT_WIKITEXT_CAPTCHA) {
                            [self.funnel logCaptchaFailure];
                        }

                        NSURL *captchaUrl = [[NSURL alloc] initWithString:error.userInfo[@"captchaUrl"]];
                        NSString *captchaId = error.userInfo[@"captchaId"];
                        [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:NO dismissPreviousAlerts:YES tapCallBack:NULL];
                        self.captchaViewController.captcha = [[WMFCaptcha alloc] initWithCaptchaID:captchaId captchaURL:captchaUrl];
                        [self revealCaptcha];
                    } break;

                    case WIKITEXT_UPLOAD_ERROR_ABUSEFILTER_DISALLOWED:
                    case WIKITEXT_UPLOAD_ERROR_ABUSEFILTER_WARNING:
                    case WIKITEXT_UPLOAD_ERROR_ABUSEFILTER_OTHER: {
                        //NSString *warningHtml = error.userInfo[@"warning"];
                        [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];

                        [self wmf_hideKeyboard];

                        if ((error.code == WIKITEXT_UPLOAD_ERROR_ABUSEFILTER_DISALLOWED)) {
                            self.mode = PREVIEW_MODE_EDIT_WIKITEXT_DISALLOW;
                            self.abuseFilterCode = error.userInfo[@"code"];
                            [self.funnel logAbuseFilterError:self.abuseFilterCode];
                        } else {
                            self.mode = PREVIEW_MODE_EDIT_WIKITEXT_WARNING;
                            self.abuseFilterCode = error.userInfo[@"code"];
                            [self.funnel logAbuseFilterWarning:self.abuseFilterCode];
                        }

                        // Hides the license panel. Needed if logged in and a disallow is triggered.
                        [[WMFAlertManager sharedInstance] dismissAlert];

                        AbuseFilterAlertType alertType =
                            (error.code == WIKITEXT_UPLOAD_ERROR_ABUSEFILTER_DISALLOWED) ? ABUSE_FILTER_DISALLOW : ABUSE_FILTER_WARNING;
                        [self showAbuseFilterAlertOfType:alertType];
                    } break;

                    case WIKITEXT_UPLOAD_ERROR_SERVER:
                    case WIKITEXT_UPLOAD_ERROR_UNKNOWN:
                        [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];

                        [self.funnel logError:error.localizedDescription]; // @fixme is this right msg?
                        break;

                    default:
                        [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];
                        break;
                }
            } break;
        }
    }
}

- (void)preview {
    [[WMFAlertManager sharedInstance] showAlert:WMFLocalizedStringWithDefaultValue(@"wikitext-preview-changes", nil, nil, @"Retrieving preview of your changes...", @"Alert text shown when getting preview of user changes to wikitext") sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];

    [[QueuesSingleton sharedInstance].sectionPreviewHtmlFetchManager wmf_cancelAllTasksWithCompletionHandler:^{
        self.previewHtmlFetcher =
            [[PreviewHtmlFetcher alloc] initAndFetchHtmlForWikiText:self.wikiText
                                                         articleURL:self.section.url
                                                        withManager:[QueuesSingleton sharedInstance].sectionPreviewHtmlFetchManager
                                                 thenNotifyDelegate:self];
    }];
}

- (void)save {
    //TODO: maybe? if we have credentials, yet the edit token retrieved for an edit
    // is an anonymous token (i think this happens if you try to get an edit token
    // and your login session has expired), need to pop up alert asking user if they
    // want to log in before continuing with their edit

    [[WMFAlertManager sharedInstance] showAlert:WMFLocalizedStringWithDefaultValue(@"wikitext-upload-save", nil, nil, @"Publishing...", @"Alert text shown when changes to section wikitext are being published\n{{Identical|Publishing}}") sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];

    [self.funnel logSaveAttempt];
    if (self.savedPagesFunnel) {
        [self.savedPagesFunnel logEditAttempt];
    }

    [[QueuesSingleton sharedInstance].sectionWikiTextUploadManager wmf_cancelAllTasksWithCompletionHandler:^{
        // If fromTitle was set, the section was transcluded, so use the title of the page
        // it was transcluded from.
        NSURL *editURL = self.section.fromURL ? self.section.fromURL : self.section.article.url;

        // First try to get an edit token for the page's domain before trying to upload the changes.
        // Only the domain is used to actually fetch the token, the other values are
        // parked in EditTokenFetcher so the actual uploader can have quick read-only
        // access to the exact params which kicked off the token request.

        NSURL *url = [[SessionSingleton sharedInstance] urlForLanguage:editURL.wmf_language];
        self.editTokenFetcher = [[WMFAuthTokenFetcher alloc] init];
        @weakify(self)
            [self.editTokenFetcher fetchTokenOfType:WMFAuthTokenTypeCsrf
                siteURL:url
                success:^(WMFAuthToken *result) {
                    @strongify(self)

                        self.wikiTextSectionUploader =
                        [[WikiTextSectionUploader alloc] initAndUploadWikiText:self.wikiText
                                                                 forArticleURL:editURL
                                                                       section:[NSString stringWithFormat:@"%d", self.section.sectionId]
                                                                       summary:[self getSummary]
                                                                     captchaId:self.captchaViewController.captcha.captchaID
                                                                   captchaWord:self.captchaViewController.solution
                                                                         token:result.token
                                                                   withManager:[QueuesSingleton sharedInstance].sectionWikiTextUploadManager
                                                            thenNotifyDelegate:self];

                }
                failure:^(NSError *error) {
                    [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:YES tapCallBack:NULL];
                }];

    }];
}

- (void)showAbuseFilterAlertOfType:(AbuseFilterAlertType)alertType {
    AbuseFilterAlert *abuseFilterAlert = [[AbuseFilterAlert alloc] initWithType:alertType];

    [self.view addSubview:abuseFilterAlert];

    NSDictionary *views = @{@"abuseFilterAlert": abuseFilterAlert};

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[abuseFilterAlert]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[abuseFilterAlert]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.captchaViewController.solution.length > 0) {
        [self save];
    }
    return YES;
}

- (NSURL *_Nonnull)captchaSiteURL {
    return [SessionSingleton sharedInstance].currentArticleSiteURL;
}

- (void)captchaReloadPushed:(id)sender {
}

- (BOOL)captchaHideSubtitle {
    return YES;
}

- (void)captchaKeyboardReturnKeyTapped {
    [self save];
}

- (void)captchaSolutionChanged:(id)sender solutionText:(nullable NSString *)solutionText {
    [self highlightCaptchaSubmitButton:(solutionText.length == 0) ? NO : YES];
}

- (void)revealCaptcha {
    [self.funnel logCaptchaShown];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone
                           forView:self.view
                             cache:NO];

    [self.view bringSubviewToFront:self.captchaScrollView];

    self.captchaScrollView.alpha = 1.0f;
    self.captchaScrollView.backgroundColor = self.theme.colors.paperBackground;

    self.captchaScrollContainer.backgroundColor = [UIColor clearColor];
    self.captchaContainer.backgroundColor = [UIColor clearColor];

    [UIView commitAnimations];

    self.mode = PREVIEW_MODE_EDIT_WIKITEXT_CAPTCHA;

    [self highlightCaptchaSubmitButton:NO];
}

- (void)previewLicenseViewTermsLicenseLabelWasTapped:(PreviewLicenseView *)previewLicenseview {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [sheet addAction:[UIAlertAction actionWithTitle:WMFLicenses.localizedSaveTermsTitle
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                                [self wmf_openExternalUrl:WMFLicenses.saveTermsURL];
                                            }]];
    [sheet addAction:[UIAlertAction actionWithTitle:WMFLicenses.localizedCCBYSA3Title
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                                [self wmf_openExternalUrl:WMFLicenses.CCBYSA3URL];
                                            }]];
    [sheet addAction:[UIAlertAction actionWithTitle:WMFLicenses.localizedGFDLTitle
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                                [self wmf_openExternalUrl:WMFLicenses.GFDLURL];
                                            }]];
    [sheet addAction:[UIAlertAction actionWithTitle:WMFLocalizedStringWithDefaultValue(@"open-link-cancel", nil, nil, @"Cancel", @"Text for cancel button in popup menu of terms/license link options\n{{Identical|Cancel}}") style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:sheet animated:YES completion:NULL];
}

#pragma mark - WMFThemeable

- (void)applyTheme:(WMFTheme *)theme {
    self.theme = theme;
    if (self.viewIfLoaded == nil) {
        return;
    }

    self.previewWebViewContainer.webView.opaque = NO;
    self.previewWebViewContainer.webView.scrollView.backgroundColor = [UIColor clearColor];

    self.scrollView.backgroundColor = theme.colors.baseBackground;
    self.captchaScrollView.backgroundColor = theme.colors.baseBackground;

    [self.previewLicenseView applyTheme:theme];

    self.scrollContainer.backgroundColor = theme.colors.paperBackground;
    self.editSummaryContainer.backgroundColor = theme.colors.paperBackground;
    self.captchaContainer.backgroundColor = theme.colors.paperBackground;
    self.captchaScrollContainer.backgroundColor = theme.colors.paperBackground;
    self.previewWebViewContainer.webView.backgroundColor = theme.colors.paperBackground;

    self.previewLabel.backgroundColor = theme.colors.midBackground;
    self.previewLabel.textColor = theme.colors.secondaryText;
    self.previewLabelContainer.backgroundColor = theme.colors.midBackground;

    self.previewWebViewContainer.backgroundColor = theme.colors.paperBackground;
}

@end
