import UIKit

class NewsCollectionViewHeader: UICollectionReusableView, Themeable {
    @IBOutlet weak var label: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        wmf_configureSubviewsForDynamicType()
    }
    
    func apply(theme: Theme) {
        backgroundColor = theme.colors.paperBackground
        label.textColor = theme.colors.secondaryText
    }
}
