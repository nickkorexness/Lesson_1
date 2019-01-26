import UIKit

enum SearchBarExtendedViewButtonType {
    case sort
    case cancel
    
    var title: String {
        switch self {
        case .sort:
            return CommonStrings.sortActionTitle
        case .cancel:
            return CommonStrings.cancelActionTitle
        }
    }
}

protocol SearchBarExtendedViewControllerDataSource: class {
    func returnKeyType(for searchBar: UISearchBar) -> UIReturnKeyType
    func placeholder(for searchBar: UISearchBar) -> String?
    func isSeparatorViewHidden(above searchBar: UISearchBar) -> Bool
    func buttonType(for button: UIButton, currentButtonType: SearchBarExtendedViewButtonType?) -> SearchBarExtendedViewButtonType?
    func fontStyle(for button: UIButton) -> (WMFFontFamily, UIFontTextStyle)
}

protocol SearchBarExtendedViewControllerDelegate: class {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    func buttonWasPressed(_ button: UIButton, buttonType: SearchBarExtendedViewButtonType?, searchBar: UISearchBar)
}

class SearchBarExtendedViewController: UIViewController {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var button: UIButton!
    private var buttonType: SearchBarExtendedViewButtonType? {
        didSet {
            button.setTitle(buttonType?.title, for: .normal)
        }
    }
    
    weak var dataSource: SearchBarExtendedViewControllerDataSource?
    weak var delegate: SearchBarExtendedViewControllerDelegate?
    
    private var theme = Theme.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = dataSource?.returnKeyType(for: searchBar) ?? .search
        searchBar.placeholder = dataSource?.placeholder(for: searchBar)
        separatorView.isHidden = dataSource?.isSeparatorViewHidden(above: searchBar) ?? false
        buttonType = dataSource?.buttonType(for: button, currentButtonType: buttonType)
        apply(theme: theme)
    }
    
    @IBAction private func buttonWasPressed(_ sender: UIButton) {
        delegate?.buttonWasPressed(sender, buttonType: buttonType, searchBar: searchBar)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let (fontStyle, textStyle) = dataSource?.fontStyle(for: button) {
            button.titleLabel?.setFont(with: fontStyle, style: textStyle, traitCollection: traitCollection)
        }
    }
}

extension SearchBarExtendedViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarTextDidBeginEditing(searchBar)
        buttonType = dataSource?.buttonType(for: button, currentButtonType: buttonType)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarTextDidEndEditing(searchBar)
        buttonType = dataSource?.buttonType(for: button, currentButtonType: buttonType)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar(searchBar, textDidChange: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarSearchButtonClicked(searchBar)
    }
}

extension SearchBarExtendedViewController: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        view.backgroundColor = theme.colors.paperBackground
        button.titleLabel?.textColor = theme.colors.link
        separatorView.backgroundColor = theme.colors.border
        searchBar.wmf_enumerateSubviewTextFields{ (textField) in
            textField.textColor = theme.colors.primaryText
            textField.keyboardAppearance = theme.keyboardAppearance
        }
    }
}
