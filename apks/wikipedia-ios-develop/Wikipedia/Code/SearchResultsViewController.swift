import UIKit
import WMF

@objc(WMFSearchResultsViewController)
class SearchResultsViewController: ArticleCollectionViewController {
    @objc var resultsInfo: WMFSearchResults? = nil // don't use resultsInfo.results, it mutates
    @objc var results: [MWKSearchResult] = [] {
        didSet {
            assert(Thread.isMainThread)
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(articleWasUpdated(_:)), name: NSNotification.Name.WMFArticleUpdated, object: nil)
        collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func articleWasUpdated(_ notification: Notification) {
        updateVisibleCellActions()
    }
    
    @objc var searchSiteURL: URL? = nil
    
    @objc(isDisplayingResultsForSearchTerm:fromSiteURL:)
    func isDisplaying(resultsFor searchTerm: String, from siteURL: URL) -> Bool {
        guard let searchResults = resultsInfo, let searchSiteURL = searchSiteURL else {
            return false
        }
        return results.count > 0 && (searchSiteURL as NSURL).wmf_isEqual(toIgnoringScheme: siteURL) && searchResults.searchTerm == searchTerm
    }
    
    override var analyticsName: String {
        return "Search"
    }
    
    override func articleURL(at indexPath: IndexPath) -> URL? {
        return results[indexPath.item].articleURL(forSiteURL: searchSiteURL)
    }
    
    override func article(at indexPath: IndexPath) -> WMFArticle? {
        guard let articleURL = articleURL(at: indexPath) else {
            return nil
        }
        let article = dataStore.fetchOrCreateArticle(with: articleURL)
        let result = results[indexPath.item]
        article?.update(with: result)
        return article
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }

    func redirectMappingForSearchResult(_ result: MWKSearchResult) -> MWKSearchRedirectMapping? {
        return resultsInfo?.redirectMappings?.filter({ (mapping) -> Bool in
            return result.displayTitle == mapping.redirectToTitle
        }).first
    }
    func descriptionForSearchResult(_ result: MWKSearchResult) -> String? {
        let capitalizedWikidataDescription = (result.wikidataDescription as NSString?)?.wmf_stringByCapitalizingFirstCharacter(usingWikipediaLanguage: searchSiteURL?.wmf_language)
        let mapping = redirectMappingForSearchResult(result)
        guard let redirectFromTitle = mapping?.redirectFromTitle else {
            return capitalizedWikidataDescription
        }
        
        let redirectFormat = WMFLocalizedString("search-result-redirected-from", value: "Redirected from: %1$@", comment: "Text for search result letting user know if a result is a redirect from another article. Parameters:\n* %1$@ - article title the current search result redirected from")
        let redirectMessage = String.localizedStringWithFormat(redirectFormat, redirectFromTitle)
        
        guard let description = capitalizedWikidataDescription else {
            return redirectMessage
        }
        
        return String.localizedStringWithFormat("%@\n%@", redirectMessage, description)
    }
    
    override func configure(cell: ArticleRightAlignedImageCollectionViewCell, forItemAt indexPath: IndexPath, layoutOnly: Bool) {
        guard indexPath.item < results.count else {
            return
        }
        let result = results[indexPath.item]
        guard let articleURL = articleURL(at: indexPath),
            let language = searchSiteURL?.wmf_language else {
            return
        }
        let locale = NSLocale.wmf_locale(for: language)
        cell.configureForCompactList(at: indexPath.item)
        cell.set(titleTextToAttribute: articleURL.wmf_title, highlightingText: resultsInfo?.searchTerm, locale: locale)
        cell.articleSemanticContentAttribute = MWLanguageInfo.semanticContentAttribute(forWMFLanguage: language)
        cell.titleLabel.accessibilityLanguage = language
        cell.descriptionLabel.text = descriptionForSearchResult(result)
        cell.descriptionLabel.accessibilityLanguage = language
        if layoutOnly {
            cell.isImageViewHidden = result.thumbnailURL != nil
        } else {
            cell.imageURL = result.thumbnailURL
        } 
        cell.apply(theme: theme)
        cell.actions = availableActions(at: indexPath)
    }

}

