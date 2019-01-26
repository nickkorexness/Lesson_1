import WebKit

@objc public enum WMFWKScriptMessage: Int {
    case unknown
    case javascriptConsoleLog
    case linkClicked
    case imageClicked
    case referenceClicked
    case editClicked
    case articleState
    case findInPageMatchesFound
    case footerReadMoreSaveClicked
    case footerReadMoreTitlesShown
    case footerMenuItemClicked
    case footerLegalLicenseLinkClicked
    case footerBrowserLinkClicked
    case footerContainerAdded
}

extension WKScriptMessage {

    @objc public class func wmf_typeForMessageName(_ name: String) -> WMFWKScriptMessage {
        switch name {
        case "linkClicked":
            return .linkClicked
        case "imageClicked":
            return .imageClicked
        case "referenceClicked":
            return .referenceClicked
        case "editClicked":
            return .editClicked
        case "articleState":
            return .articleState
        case "javascriptConsoleLog":
            return .javascriptConsoleLog
        case "findInPageMatchesFound":
            return .findInPageMatchesFound
        case "footerReadMoreSaveClicked":
            return .footerReadMoreSaveClicked
        case "footerReadMoreTitlesShown":
            return .footerReadMoreTitlesShown
        case "footerMenuItemClicked":
            return .footerMenuItemClicked
        case "footerLegalLicenseLinkClicked":
            return .footerLegalLicenseLinkClicked
        case "footerBrowserLinkClicked":
            return .footerBrowserLinkClicked
        case "footerContainerAdded":
            return .footerContainerAdded
        default:
            return .unknown
        }
    }

    @objc public func wmf_safeMessageBodyForType(_ type: WMFWKScriptMessage) -> Any? {
        switch type {
        case .linkClicked,
             .imageClicked,
             .referenceClicked,
             .editClicked,
             .javascriptConsoleLog,
             .footerReadMoreSaveClicked:
            if body is Dictionary<String, Any>{
                return (body as! NSDictionary).wmf_dictionaryByRemovingNullObjects()
            }
        case .articleState,
             .footerLegalLicenseLinkClicked,
             .footerBrowserLinkClicked,
             .footerContainerAdded:
            if body is String {
                return body
            }
        case .findInPageMatchesFound,
             .footerReadMoreTitlesShown:
            if body is Array<Any>{
                return body
            }
        case .footerMenuItemClicked:
            if
                let body = body as? Dictionary<String, Any>,
                let safeBody = (body as NSDictionary).wmf_dictionaryByRemovingNullObjects(),
                let selection = safeBody["selection"] as? String,
                let payload = safeBody["payload"] as? [String]
            {
                if selection == "disambiguation" {
                    // WKScriptMessage's body doesn't auto-convert url strings to URL, so manually do so for
                    // the disambiguation payload.
                    return ["selection": selection, "payload": payload.flatMap{URL(string: $0)}]
                }else{
                    return safeBody
                }
            }
        case .unknown:
            if body is NSNull{
                return body
            }
        }
        assertionFailure("Unexpected script message body kind of class!")
        return nil
    }
}
