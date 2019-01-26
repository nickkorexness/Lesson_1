#import "PageHistoryViewController.h"
#import "PageHistoryResultCell.h"
#import "PaddedLabel.h"
#import "UITableView+DynamicCellHeight.h"
#import "UIBarButtonItem+WMFButtonConvenience.h"
#import "Wikipedia-Swift.h"
@import WMF.AFHTTPSessionManager_WMFCancelAll;
#import "WMFPageHistoryRevision.h"

#define TABLE_CELL_ID @"PageHistoryResultCell"

@interface PageHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) __block NSMutableArray<PageHistorySection *> *pageHistoryDataArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PageHistoryFetcher *pageHistoryFetcher;
@property (assign, nonatomic) BOOL isLoadingData;
@property (assign, nonatomic) BOOL batchComplete;
@property (strong, nonatomic) PageHistoryRequestParameters *historyFetcherParams;
@property (strong, nonatomic) WMFTheme *theme;

@end

@implementation PageHistoryViewController

- (NSString *)title {
    return WMFLocalizedStringWithDefaultValue(@"page-history-title", nil, nil, @"Article history", @"Header text for Page History interface.\n{{Identical|Article history}}");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self getPageHistoryData];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.theme) {
        self.theme = [WMFTheme standard];
    }
    self.historyFetcherParams = [[PageHistoryRequestParameters alloc] initWithTitle:self.article.url.wmf_title];
    self.pageHistoryFetcher = [PageHistoryFetcher new];
    UIBarButtonItem *xButton = [UIBarButtonItem wmf_buttonType:WMFButtonTypeX target:self action:@selector(closeButtonPressed)];
    self.navigationItem.leftBarButtonItem = xButton;

    self.pageHistoryDataArray = @[].mutableCopy;

    [self.tableView registerNib:[UINib nibWithNibName:@"PageHistoryResultPrototypeView" bundle:nil]
         forCellReuseIdentifier:TABLE_CELL_ID];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 75;

    [self applyTheme:self.theme];
}

- (void)closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getPageHistoryData {
    self.isLoadingData = YES;

    @weakify(self);
    [self.pageHistoryFetcher fetchRevisionInfo:self.article.url
        requestParams:self.historyFetcherParams
        failure:^(NSError *_Nonnull error) {
            @strongify(self);
            if (!self) {
                return;
            }
            DDLogError(@"Failed to fetch items for section %@. %@", self, error);
            [[WMFAlertManager sharedInstance] showErrorAlert:error sticky:YES dismissPreviousAlerts:NO tapCallBack:NULL];
            self.isLoadingData = NO;
        }
        success:^(HistoryFetchResults *_Nonnull historyFetchResults) {
            @strongify(self);
            if (!self) {
                return;
            }
            [self.pageHistoryDataArray addObjectsFromArray:historyFetchResults.items];
            self.historyFetcherParams = [historyFetchResults getPageHistoryRequestParameters:self.article.url];
            self.batchComplete = historyFetchResults.batchComplete;
            [[WMFAlertManager sharedInstance] dismissAlert];
            [self.tableView reloadData];
            self.isLoadingData = NO;

        }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pageHistoryDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PageHistorySection *sectionItems = self.pageHistoryDataArray[section];
    return sectionItems.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = TABLE_CELL_ID;
    PageHistoryResultCell *cell = (PageHistoryResultCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    [self updateViewsInCell:cell forIndexPath:indexPath];

    return cell;
}

- (void)updateViewsInCell:(PageHistoryResultCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    PageHistorySection *section = self.pageHistoryDataArray[indexPath.section];
    WMFPageHistoryRevision *row = section.items[indexPath.row];

    [cell setName:row.user
             date:row.revisionDate
            delta:@(row.revisionSize)
           isAnon:row.isAnon
          summary:row.parsedComment
            theme:self.theme];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = self.theme.colors.baseBackground;
    view.autoresizesSubviews = YES;
    PaddedLabel *label = [[PaddedLabel alloc] init];

    CGFloat leadingIndent = 10.0;
    label.padding = UIEdgeInsetsMake(0, leadingIndent, 0, 0);

    label.font = [UIFont wmf_preferredFontForFontFamily:WMFFontFamilySystemSemiBold
                                          withTextStyle:UIFontTextStyleFootnote
                          compatibleWithTraitCollection:self.traitCollection];
    label.textColor = self.theme.colors.secondaryText;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = self.theme.colors.baseBackground;

    label.textAlignment = NSTextAlignmentNatural;

    label.text = self.pageHistoryDataArray[section].sectionTitle;

    [label wmf_configureSubviewsForDynamicType];

    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27.0;
}

- (BOOL)shouldLoadNewData {
    if (self.batchComplete || self.isLoadingData) {
        return NO;
    }
    CGFloat maxY = self.tableView.contentOffset.y + self.tableView.frame.size.height + 200.0;
    BOOL shouldLoad = NO;
    if (maxY >= self.tableView.contentSize.height) {
        shouldLoad = YES;
    }
    return shouldLoad;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self shouldLoadNewData]) {
        [self getPageHistoryData];
    }
}

- (void)applyTheme:(WMFTheme *)theme {
    self.theme = theme;
    if (self.viewIfLoaded == nil) {
        return;
    }
    self.view.backgroundColor = theme.colors.baseBackground;
    self.tableView.backgroundColor = theme.colors.baseBackground;
    self.tableView.separatorColor = theme.colors.border;
    [self.tableView reloadData];
}

@end
