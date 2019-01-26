import UIKit

extension NewsCollectionViewCell {
    @objc(configureWithStory:dataStore:theme: layoutOnly:)
    public func configure(with story: WMFFeedNewsStory, dataStore: MWKDataStore, theme: Theme, layoutOnly: Bool) {
        let previews = story.articlePreviews ?? []
        descriptionHTML = story.storyHTML
        
        articles = previews.map { (articlePreview) -> CellArticle in
            return CellArticle(articleURL:articlePreview.articleURL, title: articlePreview.displayTitle, description: articlePreview.descriptionOrSnippet, imageURL: articlePreview.thumbnailURL)
        }
        
        let articleLanguage = story.articlePreviews?.first?.articleURL.wmf_language
        descriptionLabel.accessibilityLanguage = articleLanguage
        semanticContentAttributeOverride = MWLanguageInfo.semanticContentAttribute(forWMFLanguage: articleLanguage)
        
        let imageWidthToRequest = traitCollection.wmf_potdImageWidth
        if let articleURL = story.featuredArticlePreview?.articleURL ?? previews.first?.articleURL, let article = dataStore.fetchArticle(with: articleURL), let imageURL = article.imageURL(forWidth: imageWidthToRequest) {
            isImageViewHidden = false
            if !layoutOnly {
                imageView.wmf_setImage(with: imageURL, detectFaces: true, onGPU: true, failure: {(error) in }, success: { })
            }
        } else {
            isImageViewHidden = true
        }
        apply(theme: theme)
        setNeedsLayout()
    }    
}
