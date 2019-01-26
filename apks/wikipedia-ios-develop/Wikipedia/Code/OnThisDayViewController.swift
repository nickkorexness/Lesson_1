import WMF;

@objc(WMFOnThisDayViewController)
class OnThisDayViewController: ColumnarCollectionViewController, ReadingListHintPresenter {
    fileprivate static let cellReuseIdentifier = "OnThisDayCollectionViewCell"
    fileprivate static let headerReuseIdentifier = "OnThisDayViewControllerHeader"
    fileprivate static let blankHeaderReuseIdentifier = "OnThisDayViewControllerBlankHeader"
    var readingListHintController: ReadingListHintController?
    
    let events: [WMFFeedOnThisDayEvent]
    let dataStore: MWKDataStore
    let midnightUTCDate: Date
    
    @objc(initWithEvents:dataStore:midnightUTCDate:)
    required public init(events: [WMFFeedOnThisDayEvent], dataStore: MWKDataStore, midnightUTCDate: Date) {
        self.events = events
        self.dataStore = dataStore
        self.midnightUTCDate = midnightUTCDate
        self.isDateVisibleInTitle = false
        super.init()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: WMFLocalizedString("back", value:"Back", comment:"Generic 'Back' title for back button\n{{Identical|Back}}"), style: .plain, target:nil, action:nil)
    }
    
    var isDateVisibleInTitle: Bool {
        didSet {
            
            // Work-around for: https://phabricator.wikimedia.org/T169277
            // Presently the event looks to its first article preview when you ask it for the language, so if the event has no previews, no lang!
            let firstEventWithArticlePreviews = events.first(where: {
                guard let previews = $0.articlePreviews, previews.count > 0 else {
                    return false
                }
                return true
            })
            
            guard isDateVisibleInTitle, let language = firstEventWithArticlePreviews?.language else {
                title = WMFLocalizedString("on-this-day-title", value:"On this day", comment:"Title for the 'On this day' feed section")
                return
            }
            title = DateFormatter.wmf_monthNameDayNumberGMTFormatter(for: language).string(from: midnightUTCDate)
        }
    }
    
    override func metrics(withBoundsSize size: CGSize, readableWidth: CGFloat) -> WMFCVLMetrics {
        return WMFCVLMetrics.singleColumnMetrics(withBoundsSize: size, readableWidth: readableWidth)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        register(OnThisDayCollectionViewCell.self, forCellWithReuseIdentifier: OnThisDayViewController.cellReuseIdentifier, addPlaceholder: true)
        register(UINib(nibName: OnThisDayViewController.headerReuseIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: OnThisDayViewController.headerReuseIdentifier, addPlaceholder: false)
        register(OnThisDayViewControllerBlankHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: OnThisDayViewController.blankHeaderReuseIdentifier, addPlaceholder: false)
        readingListHintController = ReadingListHintController(dataStore: dataStore, presenter: self)
    }
}

class OnThisDayViewControllerBlankHeader: UICollectionReusableView {

}

// MARK: - UICollectionViewDataSource/Delegate
extension OnThisDayViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return events.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnThisDayViewController.cellReuseIdentifier, for: indexPath)
        guard let onThisDayCell = cell as? OnThisDayCollectionViewCell else {
            return cell
        }
        let event = events[indexPath.section]
        onThisDayCell.layoutMargins = layout.readableMargins
        onThisDayCell.configure(with: event, dataStore: dataStore, theme: self.theme, layoutOnly: false, shouldAnimateDots: true)
        onThisDayCell.timelineView.extendTimelineAboveTopDot = indexPath.section == 0 ? false : true

        return onThisDayCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            indexPath.section == 0,
            kind == UICollectionElementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OnThisDayViewController.headerReuseIdentifier, for: indexPath) as? OnThisDayViewControllerHeader
        else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: OnThisDayViewController.blankHeaderReuseIdentifier, for: indexPath)
        }
        
        header.configureFor(eventCount: events.count, firstEvent: events.first, lastEvent: events.last, midnightUTCDate: midnightUTCDate)
        header.apply(theme: theme)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? OnThisDayCollectionViewCell else {
            return
        }
        cell.selectionDelegate = self
        cell.pauseDotsAnimation = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? OnThisDayCollectionViewCell else {
            return
        }
        cell.selectionDelegate = nil
        cell.pauseDotsAnimation = true
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard indexPath.section == 0, elementKind == UICollectionElementKindSectionHeader else {
            return
        }
        isDateVisibleInTitle = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard indexPath.section == 0, elementKind == UICollectionElementKindSectionHeader else {
            return
        }
        isDateVisibleInTitle = true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - WMFColumnarCollectionViewLayoutDelegate
extension OnThisDayViewController {
    override func collectionView(_ collectionView: UICollectionView, estimatedHeightForHeaderInSection section: Int, forColumnWidth columnWidth: CGFloat) -> WMFLayoutEstimate {
        return WMFLayoutEstimate(precalculated: false, height: section == 0 ? 150 : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, estimatedHeightForItemAt indexPath: IndexPath, forColumnWidth columnWidth: CGFloat) -> WMFLayoutEstimate {
        var estimate = WMFLayoutEstimate(precalculated: false, height: 350)
        guard let placeholderCell = placeholder(forCellWithReuseIdentifier: OnThisDayViewController.cellReuseIdentifier) as? OnThisDayCollectionViewCell else {
            return estimate
        }
        let event = events[indexPath.section]
        placeholderCell.layoutMargins = layout.readableMargins
        placeholderCell.configure(with: event, dataStore: dataStore, theme: theme, layoutOnly: true, shouldAnimateDots: false)
        estimate.height = placeholderCell.sizeThatFits(CGSize(width: columnWidth, height: UIViewNoIntrinsicMetric), apply: false).height
        estimate.precalculated = true
        return estimate
    }
}

// MARK: - SideScrollingCollectionViewCellDelegate
extension OnThisDayViewController: SideScrollingCollectionViewCellDelegate {
    func sideScrollingCollectionViewCell(_ sideScrollingCollectionViewCell: SideScrollingCollectionViewCell, didSelectArticleWithURL articleURL: URL) {
        wmf_pushArticle(with: articleURL, dataStore: dataStore, theme: self.theme, animated: true)
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension OnThisDayViewController {
    override func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) as? OnThisDayCollectionViewCell else {
            return nil
        }
        
        let pointInCellCoordinates =  collectionView.convert(location, to: cell)
        let index = cell.subItemIndex(at: pointInCellCoordinates)
        guard index != NSNotFound, let view = cell.viewForSubItem(at: index) else {
            return nil
        }
        
        let event = events[indexPath.section]
        guard let previews = event.articlePreviews, index < previews.count else {
            return nil
        }
        
        previewingContext.sourceRect = view.convert(view.bounds, to: collectionView)
        let article = previews[index]
        let vc = WMFArticleViewController(articleURL: article.articleURL, dataStore: dataStore, theme: theme)
        vc.articlePreviewingActionsDelegate = self
        vc.wmf_addPeekableChildViewController(for: article.articleURL, dataStore: dataStore, theme: theme)
        if let themeable = vc as Themeable? {
            themeable.apply(theme: self.theme)
        }
        return vc
    }
    
    override func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewControllerToCommit.wmf_removePeekableChildViewControllers()
        wmf_push(viewControllerToCommit, animated: true)
    }
}
