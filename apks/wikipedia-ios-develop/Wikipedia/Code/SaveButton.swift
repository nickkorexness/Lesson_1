import UIKit

@objc(WMFSaveButtonDelegate) public protocol SaveButtonDelegate {
    func saveButtonDidReceiveLongPress(_ saveButton: SaveButton)
    func saveButtonDidReceiveAddToReadingListAction(_ saveButton: SaveButton) -> Bool
}

@objc(WMFSaveButton) public class SaveButton: AlignedImageButton, AnalyticsContextProviding, AnalyticsContentTypeProviding {
    @objc(WMFSaveButtonState)
    public enum State: Int {
        case shortSaved
        case longSaved
        case shortSave
        case longSave
    }

    static let saveImage = UIImage(named: "unsaved", in: Bundle.wmf, compatibleWith:nil)
    static let savedImage = UIImage(named: "saved", in: Bundle.wmf, compatibleWith:nil)
    
    public var analyticsContext = "unknown"
    public var analyticsContentType = "unknown"
    
    public var saveButtonState: SaveButton.State = .shortSave {
        didSet {
            let saveTitle: String
            let saveImage: UIImage?
            switch saveButtonState {
            case .longSaved:
                saveTitle = CommonStrings.savedTitle
                saveImage = SaveButton.savedImage
                accessibilityLabel = CommonStrings.accessibilitySavedTitle
            case .longSave:
                saveTitle = CommonStrings.saveTitle
                saveImage = SaveButton.saveImage
                accessibilityLabel = CommonStrings.saveTitle
            case .shortSaved:
                saveTitle = CommonStrings.shortSavedTitle
                saveImage = SaveButton.savedImage
                accessibilityLabel = CommonStrings.accessibilitySavedTitle
            case .shortSave:
                fallthrough
            default:
                saveTitle = CommonStrings.shortSaveTitle
                saveImage = SaveButton.saveImage
                accessibilityLabel = CommonStrings.saveTitle
            }
            let addToReadingListAction = UIAccessibilityCustomAction(name: CommonStrings.addToReadingListActionTitle, target: self, selector: #selector(addToReadingList(_:)))
            accessibilityCustomActions = [addToReadingListAction]
            setTitle(saveTitle, for: .normal)
            setImage(saveImage, for: .normal)
            layoutIfNeeded()
        }
    }

    override open func layoutSubviews() {
        UIView.performWithoutAnimation {
            super.layoutSubviews()
        }
    }
    
    @objc func addToReadingList(_ sender: UIControl) -> Bool {
        return saveButtonDelegate?.saveButtonDidReceiveAddToReadingListAction(self) ?? false
    }
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    public weak var saveButtonDelegate: SaveButtonDelegate?  {
        didSet {
            if let lpgr = longPressGestureRecognizer, saveButtonDelegate == nil {
                removeGestureRecognizer(lpgr)
            } else if saveButtonDelegate != nil && longPressGestureRecognizer == nil {
                let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
                addGestureRecognizer(lpgr)
                longPressGestureRecognizer = lpgr
            }
        }
    }
    
    @objc public func handleLongPressGestureRecognizer(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else {
            return
        }
        saveButtonDelegate?.saveButtonDidReceiveLongPress(self)
    }
}
