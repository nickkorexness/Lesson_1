
struct WMFAuthLinkLabelStrings {
    /// String containing "%1$@" substring.
    var dollarSignString: String
    
    /// String which will replace "%1$@" in "dollarSignString".
    var substitutionString: String
}

class WMFAuthLinkLabel: UILabel, Themeable {
    fileprivate var theme = Theme.standard
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        textColor = theme.colors.link
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        textAlignment = .natural
    }

    /// Some auth labels display a string from two localized strings, each styled differently.
    public var strings: WMFAuthLinkLabelStrings?

    fileprivate var boldSubheadlineFont: UIFont? {
        get {
            return UIFont.wmf_preferredFontForFontFamily(WMFFontFamily.systemSemiBold, withTextStyle: .subheadline, compatibleWithTraitCollection: self.traitCollection)
        }
    }

    fileprivate var subheadlineFont: UIFont? {
        get {
            return UIFont.wmf_preferredFontForFontFamily(WMFFontFamily.system, withTextStyle: .subheadline, compatibleWithTraitCollection: self.traitCollection)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        update()
    }
    
    fileprivate func update() {
        guard let strings = strings else {
            if let boldSubheadlineFont = boldSubheadlineFont {
                font = boldSubheadlineFont
            }
            return
        }
        attributedText = combinedAttributedString(from: strings)
    }
    
    fileprivate func combinedAttributedString(from strings: WMFAuthLinkLabelStrings) -> NSAttributedString {
        // Combine and style 'dollarSignString' and 'substitutionString': https://github.com/wikimedia/wikipedia-ios/pull/1216#discussion_r104224511
        
        var dollarSignStringAttributes: [NSAttributedStringKey:Any] = [NSAttributedStringKey.foregroundColor : theme.colors.secondaryText]
        if let subheadlineFont = subheadlineFont {
            dollarSignStringAttributes[NSAttributedStringKey.font] = subheadlineFont
        }

        var substitutionStringAttributes: [NSAttributedStringKey:Any] = [NSAttributedStringKey.foregroundColor : theme.colors.link]
        if let boldSubheadlineFont = boldSubheadlineFont {
            substitutionStringAttributes[NSAttributedStringKey.font] = boldSubheadlineFont
        }
        
        assert(strings.dollarSignString.contains("%1$@"), "Expected dollar sign substitution placeholder not found")
        
        return strings.dollarSignString.attributedString(attributes: dollarSignStringAttributes, substitutionStrings: [strings.substitutionString], substitutionAttributes: [substitutionStringAttributes])
    }
    
    func apply(theme: Theme) {
        self.theme = theme
        update()
    }
}
