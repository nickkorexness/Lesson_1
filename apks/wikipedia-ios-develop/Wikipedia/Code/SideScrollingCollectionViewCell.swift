import UIKit

internal struct CellArticle {
    let articleURL: URL?
    let title: String?
    let description: String?
    let imageURL: URL?
}

@objc(WMFSideScrollingCollectionViewCellDelegate)
public protocol SideScrollingCollectionViewCellDelegate {
    func sideScrollingCollectionViewCell(_ sideScrollingCollectionViewCell: SideScrollingCollectionViewCell, didSelectArticleWithURL articleURL: URL)
}


@objc(WMFSubCellProtocol)
public protocol SubCellProtocol {
    @objc(deselectSelectedSubItemsAnimated:)
    func deselectSelectedSubItems(animated: Bool)
}

@objc(WMFSideScrollingCollectionViewCell)
public class SideScrollingCollectionViewCell: CollectionViewCell, SubCellProtocol {
    static let articleCellIdentifier = "ArticleRightAlignedImageCollectionViewCell"
    var theme: Theme = Theme.standard
    
    @objc public weak var selectionDelegate: SideScrollingCollectionViewCellDelegate?
    public let imageView = UIImageView()
    public let titleLabel = UILabel()
    public let subTitleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let bottomTitleLabel = UILabel()

    internal var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    internal let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    internal let prototypeCell = ArticleRightAlignedImageCollectionViewCell()
    var semanticContentAttributeOverride: UISemanticContentAttribute = .unspecified {
        didSet {
            titleLabel.semanticContentAttribute = semanticContentAttributeOverride
            subTitleLabel.semanticContentAttribute = semanticContentAttributeOverride
            descriptionLabel.semanticContentAttribute = semanticContentAttributeOverride
            collectionView.semanticContentAttribute = semanticContentAttributeOverride
            bottomTitleLabel.semanticContentAttribute = semanticContentAttributeOverride
        }
    }
    
    internal var articles: [CellArticle] = []
    
    override open func setup() {
        titleLabel.isOpaque = true
        subTitleLabel.isOpaque = true
        descriptionLabel.isOpaque = true
        bottomTitleLabel.isOpaque = true
        imageView.isOpaque = true
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(descriptionLabel)
        addSubview(bottomTitleLabel)
    
        addSubview(imageView)
        addSubview(collectionView)
        addSubview(prototypeCell)
        
        wmf_configureSubviewsForDynamicType()

        //Setup the prototype cell with placeholder content so we can get an accurate height calculation for the collection view that accounts for dynamic type changes
        prototypeCell.configure(with: CellArticle(articleURL: nil, title: "Lorem", description: "Ipsum", imageURL: nil), semanticContentAttribute: .forceLeftToRight, theme: self.theme, layoutOnly: true)

        prototypeCell.isHidden = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        titleLabel.numberOfLines = 1
        bottomTitleLabel.numberOfLines = 1
        subTitleLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 0
        flowLayout?.scrollDirection = .horizontal
        collectionView.register(ArticleRightAlignedImageCollectionViewCell.self, forCellWithReuseIdentifier: SideScrollingCollectionViewCell.articleCellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        super.setup()
    }
    
    override open func reset() {
        super.reset()
        layoutMargins = UIEdgeInsets(top: 0, left: 13, bottom: 15, right: 13)
        imageView.wmf_reset()
    }
    
    public var isImageViewHidden = false {
        didSet {
            imageView.isHidden = isImageViewHidden
            setNeedsLayout()
        }
    }
    
    public let imageViewHeight: CGFloat = 170
    public let spacing: CGFloat = 13
    
    override public func sizeThatFits(_ size: CGSize, apply: Bool) -> CGSize {
        var origin = CGPoint(x: layoutMargins.left, y: layoutMargins.top)
        let widthToFit = size.width - layoutMargins.left - layoutMargins.right
    
        if !isImageViewHidden {
            if (apply) {
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: imageViewHeight)
            }
            origin.y += imageViewHeight
        }

        if titleLabel.wmf_hasAnyText {
            origin.y += spacing
            origin.y += titleLabel.wmf_preferredHeight(at: origin, fitting: widthToFit, alignedBy: semanticContentAttributeOverride, spacing: round(0.4 * spacing), apply: apply)
        }
        
        if subTitleLabel.wmf_hasAnyText {
            origin.y += 0
            origin.y += subTitleLabel.wmf_preferredHeight(at: origin, fitting: widthToFit, alignedBy: semanticContentAttributeOverride, spacing: spacing, apply: apply)
        }
        
        origin.y += spacing
        origin.y += descriptionLabel.wmf_preferredHeight(at: origin, fitting: widthToFit, alignedBy: semanticContentAttributeOverride, spacing: spacing, apply: apply)
        
        let collectionViewSpacing: CGFloat = 10
        var height = prototypeCell.wmf_preferredHeight(at: origin, fitting: widthToFit, alignedBy: semanticContentAttributeOverride, spacing: 2*collectionViewSpacing, apply: false)

        if articles.count == 0 {
            height = 0
        }

        if (apply) {
            flowLayout?.itemSize = CGSize(width: max(250, round(0.45*size.width)), height: height - 2*collectionViewSpacing)
            flowLayout?.minimumInteritemSpacing = collectionViewSpacing
            flowLayout?.sectionInset = UIEdgeInsets(top: collectionViewSpacing, left: collectionViewSpacing, bottom: collectionViewSpacing, right: collectionViewSpacing)
            collectionView.frame = CGRect(x: 0, y: origin.y, width: size.width, height: height)
            if semanticContentAttributeOverride == .forceRightToLeft {
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: layoutMargins.right - collectionViewSpacing)
            } else {
                collectionView.contentInset = UIEdgeInsets(top: 0, left: layoutMargins.left - collectionViewSpacing, bottom: 0, right: 0)
            }
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            resetContentOffset()
            deselectSelectedSubItems(animated: false)
        }

        origin.y += height

        if bottomTitleLabel.wmf_hasAnyText {
            origin.y += spacing
            origin.y += bottomTitleLabel.wmf_preferredHeight(at: origin, fitting: widthToFit, alignedBy: semanticContentAttributeOverride, spacing: spacing, apply: apply)
        }else{
            origin.y += layoutMargins.bottom
        }
        
        return CGSize(width: size.width, height: origin.y)
    }

    public func resetContentOffset() {
        let x: CGFloat = semanticContentAttributeOverride == .forceRightToLeft ? collectionView.contentSize.width - collectionView.bounds.size.width + collectionView.contentInset.right : -collectionView.contentInset.left
        collectionView.contentOffset = CGPoint(x: x, y: 0)
    }

    public func deselectSelectedSubItems(animated: Bool) {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        for indexPath in selectedIndexPaths {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }

    override public func updateBackgroundColorOfLabels() {
        super.updateBackgroundColorOfLabels()
        titleLabel.backgroundColor = labelBackgroundColor
        subTitleLabel.backgroundColor = labelBackgroundColor
        descriptionLabel.backgroundColor = labelBackgroundColor
        bottomTitleLabel.backgroundColor = labelBackgroundColor
    }
}

extension SideScrollingCollectionViewCell: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedArticle = articles[indexPath.item]
        guard let articleURL = selectedArticle.articleURL else {
            return
        }
        selectionDelegate?.sideScrollingCollectionViewCell(self, didSelectArticleWithURL:articleURL)
    }
}

extension SideScrollingCollectionViewCell: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  SideScrollingCollectionViewCell.articleCellIdentifier, for: indexPath)
        guard let articleCell = cell as? ArticleRightAlignedImageCollectionViewCell else {
            return cell
        }
        let articleForCell = articles[indexPath.item]
        articleCell.configure(with: articleForCell, semanticContentAttribute: semanticContentAttributeOverride, theme: self.theme, layoutOnly: false)
        return articleCell
    }
}

fileprivate extension ArticleRightAlignedImageCollectionViewCell {
    func configure(with cellArticle: CellArticle, semanticContentAttribute: UISemanticContentAttribute, theme: Theme, layoutOnly: Bool) {
        apply(theme: theme)
        backgroundColor = .clear
        setBackgroundColors(theme.colors.subCellBackground, selected: theme.colors.midBackground)
        backgroundView?.layer.cornerRadius = 5
        backgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 5
        selectedBackgroundView?.layer.masksToBounds = true
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2
        layer.shadowColor = theme.colors.shadow.cgColor
        layer.masksToBounds = false
        titleLabel.backgroundColor = backgroundView?.backgroundColor
        descriptionLabel.backgroundColor = backgroundView?.backgroundColor
        titleTextStyle = .subheadline
        descriptionTextStyle = .footnote
        imageViewDimension = 40
        isSaveButtonHidden = true
        layoutMargins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        isImageViewHidden = layoutOnly || cellArticle.imageURL == nil
        titleLabel.text = cellArticle.title
        descriptionLabel.text = cellArticle.description
        articleSemanticContentAttribute = semanticContentAttribute
        
        if let imageURL = cellArticle.imageURL {
            isImageViewHidden = false
            if !layoutOnly {
                imageView.wmf_setImage(with: imageURL, detectFaces: true, onGPU: true, failure: { (error) in }, success: { })
            }
        } else {
            isImageViewHidden = true
        }
        
        updateFonts(with: traitCollection)
        setNeedsLayout()
    }
}

extension SideScrollingCollectionViewCell {
    @objc(subItemIndexAtPoint:)
    public func subItemIndex(at point: CGPoint) -> Int { // NSNotFound for not found
        let collectionViewFrame = collectionView.frame
        guard collectionViewFrame.contains(point) else {
            return NSNotFound
        }
        let pointInCollectionViewCoordinates = convert(point, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: pointInCollectionViewCoordinates) else {
            return NSNotFound
        }
        
        return indexPath.item
    }
    
    @objc(viewForSubItemAtIndex:)
    public func viewForSubItem(at index: Int) -> UIView? {
        guard index != NSNotFound, index >= 0, index < collectionView.numberOfItems(inSection: 0) else {
            return nil
        }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else {
            return nil
        }
        return cell
    }
}

extension SideScrollingCollectionViewCell: Themeable {
    public func apply(theme: Theme) {
        self.theme = theme
        imageView.alpha = theme.imageOpacity
        setBackgroundColors(theme.colors.paperBackground, selected: theme.colors.midBackground)
        titleLabel.textColor = theme.colors.primaryText
        subTitleLabel.textColor = theme.colors.secondaryText
        descriptionLabel.textColor = theme.colors.primaryText
        collectionView.backgroundColor = theme.colors.paperBackground
        descriptionLabel.textColor = theme.colors.primaryText
        updateSelectedOrHighlighted()
        collectionView.reloadData()
        if #available(iOSApplicationExtension 11.0, *) {
            imageView.accessibilityIgnoresInvertColors = true
        }
    }
}
