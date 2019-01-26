@objc public protocol WMFReadingListsAlertControllerDelegate: NSObjectProtocol {
    func readingListsAlertController(_ readingListsAlertController: ReadingListsAlertController, didSelectUnsaveForArticle: WMFArticle)
}

public enum ReadingListsAlertActionType {
    case delete, unsave, cancel
    
    public func action(with handler: (() -> Void)? = nil) -> UIAlertAction {
        let title: String
        let style: UIAlertActionStyle
        switch self {
        case .delete:
            title = CommonStrings.deleteActionTitle
            style = .destructive
        case .unsave:
            title = CommonStrings.shortUnsaveTitle
            style = .destructive
        case .cancel:
            title = CommonStrings.cancelActionTitle
            style = .cancel
        }
        return UIAlertAction(title: title, style: style) { (_) in
            handler?()
        }
    }
}

@objc (WMFReadingListsAlertController)
public class ReadingListsAlertController: NSObject {
    @objc public weak var delegate: WMFReadingListsAlertControllerDelegate?
    
    // MARK: UIAlertController presentation
    
    @objc func showAlert(presenter: UIViewController & WMFReadingListsAlertControllerDelegate, article: WMFArticle) {
        delegate = presenter
        let unsave = ReadingListsAlertActionType.unsave.action {
            self.delegate?.readingListsAlertController(self, didSelectUnsaveForArticle: article)
        }
        let title = CommonStrings.unsaveArticleAndRemoveFromListsTitle(articleCount: 1)
        let message = CommonStrings.unsaveArticleAndRemoveFromListsMessage(articleCount: 1)
        presenter.present(alert(with: title, message: message, actions: [ReadingListsAlertActionType.cancel.action(), unsave]), animated: true)
    }
    
    func showAlert(presenter: UIViewController, for articles: [WMFArticle], with actions: [UIAlertAction], completion: (() -> Void)? = nil, failure: () -> Bool) -> Bool {
        let articlesCount = articles.count
        guard articles.filter ({ $0.isOnlyInDefaultList }).count != articlesCount else {
            return failure()
        }
        let title = CommonStrings.unsaveArticleAndRemoveFromListsTitle(articleCount: articlesCount)
        let message = CommonStrings.unsaveArticleAndRemoveFromListsMessage(articleCount: articlesCount)
        presenter.present(alert(with: title, message: message, actions: actions), animated: true, completion: completion)
        return true
    }
    
    func showAlert(presenter: UIViewController, for readingLists: [ReadingList], with actions: [UIAlertAction], completion: (() -> Void)? = nil, failure: () -> Bool) -> Bool {
        let readingListsCount = readingLists.count
        guard Int(readingLists.flatMap({ $0.countOfEntries }).reduce(0, +)) > 0 else {
            return failure()
        }
        let title = String.localizedStringWithFormat(WMFLocalizedString("reading-lists-delete-reading-list-alert-title", value: "Delete {{PLURAL:%1$d|list|lists}}?", comment: "Title of the alert shown before deleting selected reading lists. %1$d is replaced with number of lists to be deleted. %1$d will be replaced with the appropriate plural for the number of lists being deleted"), readingListsCount)
        let message =  String.localizedStringWithFormat(WMFLocalizedString("reading-lists-delete-reading-list-alert-message", value: "This action cannot be undone. Any articles saved only to {{PLURAL:%1$d|this list|these lists}} will be unsaved.", comment: "Title of the altert shown before deleting selected reading lists. %1$d will be replaced with the appropriate plural for the number of lists being deleted"), readingListsCount)
        presenter.present(alert(with: title, message: message, actions: actions), animated: true, completion: completion)
        return true
    }
    
    private func alert(with title: String, message: String?, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        return alert
    }
    
    // MARK: - ScrollableEducationPanelViewController presentation
    
    @objc func showLimitHitForDefaultListPanelIfNecessary(presenter: UIViewController, dataStore: MWKDataStore, readingList: ReadingList, theme: Theme) {
        guard Thread.isMainThread else {
            return
        }
        guard !UserDefaults.wmf_userDefaults().wmf_didShowLimitHitForUnsortedArticlesPanel() else {
            return
        }
        guard readingList.isDefault else {
            return
        }
        let primaryButtonHandler: ScrollableEducationPanelButtonTapHandler = { _ in
            presenter.presentedViewController?.dismiss(animated: true)
            let readingListDetailViewController = ReadingListDetailViewController(for: readingList, with: dataStore, displayType: .modal)
            readingListDetailViewController.apply(theme: theme)
            let navigationController = WMFThemeableNavigationController(rootViewController: readingListDetailViewController, theme: theme)
            presenter.present(navigationController, animated: true)
        }
        presenter.wmf_showLimitHitForUnsortedArticlesPanelViewController(theme: theme, primaryButtonTapHandler: primaryButtonHandler) {
            UserDefaults.wmf_userDefaults().wmf_setDidShowLimitHitForUnsortedArticlesPanel(true)
        }
    }
}
