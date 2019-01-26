
class WMFWelcomeAnalyticsViewController: UIViewController {
    fileprivate var theme = Theme.standard

    @IBOutlet fileprivate var toggleLabel:UILabel!
    @IBOutlet fileprivate var toggleSubtitleLabel:UILabel!
    @IBOutlet fileprivate var toggle:UISwitch!

    @IBOutlet fileprivate var descriptionLabel:UILabel!
    @IBOutlet fileprivate var learnMoreButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        toggle.onTintColor = theme.colors.accent
        
        descriptionLabel.text = WMFLocalizedString("welcome-send-data-sub-title", value:"Help improve the app by letting the Wikimedia Foundation know how you use it. Data collected is anonymous.", comment:"Sub-title explaining how sending usage reports can help improve the app")
        
        learnMoreButton.setTitle(WMFLocalizedString("welcome-send-data-learn-more", value:"Learn more about data collected", comment:"Text for link for learning more about opting-in to anonymous data collection"), for: .normal)
        
        learnMoreButton.setTitleColor(theme.colors.link, for: .normal)
        
        toggleSubtitleLabel.text = WMFLocalizedString("welcome-volunteer-send-usage-reports", value:"Send usage reports", comment:"Text for switch allowing user to choose whether to send usage reports")
        
        updateToggleLabelTitleForUsageReportsIsOn(false)
        
        //Set state of the toggle. Also make sure crash manager setting is in sync with this setting - likely to happen on first launch or for previous users.
        if (UserDefaults.wmf_userDefaults().wmf_sendUsageReports()) {
            toggle.isOn = true
            BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        } else {
            toggle.isOn = false
            BITHockeyManager.shared().crashManager.crashManagerStatus = .alwaysAsk
        }
        view.wmf_configureSubviewsForDynamicType()
    }
    
    fileprivate func updateToggleLabelTitleForUsageReportsIsOn(_ isOn: Bool) {
        //Hide accessibility of label because switch will become the label by default.
        toggleLabel.isAccessibilityElement = false
        
        toggleLabel.isHidden = !isOn
        toggle.accessibilityLabel = WMFLocalizedString("welcome-volunteer-send-usage-reports", value:"Send usage reports", comment:"Text for switch allowing user to choose whether to send usage reports")
    }
    
    @IBAction func toggleAnalytics(withSender sender: UISwitch){
        if(sender.isOn){
            BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
            UserDefaults.wmf_userDefaults().wmf_setSendUsageReports(true)
        }else{
            BITHockeyManager.shared().crashManager.crashManagerStatus = .alwaysAsk
            UserDefaults.wmf_userDefaults().wmf_setSendUsageReports(false)
        }
        updateToggleLabelTitleForUsageReportsIsOn(sender.isOn)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        learnMoreButton.titleLabel?.font = UIFont.wmf_preferredFontForFontFamily(.systemSemiBold, withTextStyle: .footnote, compatibleWithTraitCollection: traitCollection)
    }

    @IBAction func showPrivacyAlert(withSender sender: AnyObject) {
        guard let url = URL.init(string: CommonStrings.privacyPolicyURLString) else {
            assertionFailure("Expected URL")
            return
        }
        wmf_openExternalUrl(url)
    }
}
