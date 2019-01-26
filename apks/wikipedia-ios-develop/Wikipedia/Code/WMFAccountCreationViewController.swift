
import UIKit

class WMFAccountCreationViewController: WMFScrollViewController, WMFCaptchaViewControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, Themeable {
    @IBOutlet fileprivate var usernameField: ThemeableTextField!
    @IBOutlet fileprivate var passwordRepeatField: ThemeableTextField!
    @IBOutlet fileprivate var emailField: ThemeableTextField!
    @IBOutlet fileprivate var passwordField: ThemeableTextField!
    
    @IBOutlet fileprivate var usernameAlertLabel: UILabel!

    @IBOutlet fileprivate var usernameTitleLabel: UILabel!
    @IBOutlet fileprivate var passwordTitleLabel: UILabel!
    @IBOutlet fileprivate var passwordRepeatTitleLabel: UILabel!
    @IBOutlet fileprivate var passwordRepeatAlertLabel: UILabel!
    @IBOutlet fileprivate var emailTitleLabel: UILabel!
    @IBOutlet fileprivate var captchaContainer: UIView!
    @IBOutlet fileprivate var loginButton: WMFAuthLinkLabel!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var stackView: UIStackView!
    @IBOutlet fileprivate var createAccountButton: WMFAuthButton!

    @IBOutlet fileprivate weak var scrollContainer: UIView!
    
    let accountCreationInfoFetcher = WMFAuthAccountCreationInfoFetcher()
    let tokenFetcher = WMFAuthTokenFetcher()
    let accountCreator = WMFAccountCreator()
    
    fileprivate var theme = Theme.standard
    
    public var funnel: CreateAccountFunnel?
    fileprivate lazy var captchaViewController: WMFCaptchaViewController? = WMFCaptchaViewController.wmf_initialViewControllerFromClassStoryboard()
    
    @objc func closeButtonPushed(_ : UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction fileprivate func createAccountButtonTapped(withSender sender: UIButton) {
        save()
    }

    @objc func loginButtonPushed(_ recognizer: UITapGestureRecognizer) {
        guard
            recognizer.state == .ended,
            let presenter = presentingViewController,
            let loginVC = WMFLoginViewController.wmf_initialViewControllerFromClassStoryboard()
        else {
                assertionFailure("Expected view controller(s) not found")
                return
        }
        dismiss(animated: true, completion: {
            loginVC.apply(theme: self.theme)
            presenter.present(WMFThemeableNavigationController(rootViewController: loginVC, theme: self.theme), animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"close"), style: .plain, target:self, action:#selector(closeButtonPushed(_:)))

        createAccountButton.setTitle(WMFLocalizedString("account-creation-create-account", value:"Create your account", comment:"Text for create account button"), for: .normal)
        
        scrollView.delegate = self
        
        usernameField.placeholder = WMFLocalizedString("field-username-placeholder", value:"enter username", comment:"Placeholder text shown inside username field until user taps on it")
        passwordField.placeholder = WMFLocalizedString("field-password-placeholder", value:"enter password", comment:"Placeholder text shown inside password field until user taps on it")
        passwordRepeatField.placeholder = WMFLocalizedString("field-password-confirm-placeholder", value:"re-enter password", comment:"Placeholder text shown inside confirm password field until user taps on it")
        emailField.placeholder = WMFLocalizedString("field-email-placeholder", value:"example@example.org", comment:"Placeholder text shown inside email address field until user taps on it")
        usernameTitleLabel.text = WMFLocalizedString("field-username-title", value:"Username", comment:"Title for username field\n{{Identical|Username}}")
        passwordTitleLabel.text = WMFLocalizedString("field-password-title", value:"Password", comment:"Title for password field\n{{Identical|Password}}")
        passwordRepeatTitleLabel.text = WMFLocalizedString("field-password-confirm-title", value:"Confirm password", comment:"Title for confirm password field")
        emailTitleLabel.text = WMFLocalizedString("field-email-title-optional", value:"Email (optional)", comment:"Noun. Title for optional email address field.")
        passwordRepeatAlertLabel.text = WMFLocalizedString("field-alert-password-confirm-mismatch", value:"Passwords do not match", comment:"Alert shown if password confirmation did not match password")

        loginButton.strings = WMFAuthLinkLabelStrings(dollarSignString: WMFLocalizedString("account-creation-have-account", value:"Already have an account? %1$@", comment:"Text for button which shows login interface. %1$@ is the message {{msg-wikimedia|account-creation-log-in}}"), substitutionString: WMFLocalizedString("account-creation-log-in", value:"Log in.", comment:"Log in text to be used as part of a log in button\n{{Identical|Log in}}"))
        
        loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginButtonPushed(_:))))
        titleLabel.text = WMFLocalizedString("account-creation-title", value:"Create a new account", comment:"Title for account creation interface")
       
        view.wmf_configureSubviewsForDynamicType()
        
        captchaViewController?.captchaDelegate = self
        wmf_add(childController:captchaViewController, andConstrainToEdgesOfContainerView: captchaContainer)
        
        apply(theme: theme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if captcha is required right away. Things could be configured so captcha is required at all times.
        getCaptcha()
        
        updateEmailFieldReturnKeyType()
        enableProgressiveButtonIfNecessary()
    }
    
    fileprivate func getCaptcha() {
        let failure: WMFErrorHandler = {error in }
        let siteURL = MWKLanguageLinkController.sharedInstance().appLanguage?.siteURL()
        accountCreationInfoFetcher.fetchAccountCreationInfoForSiteURL(siteURL!, success: { info in
            self.captchaViewController?.captcha = info.captcha
            if info.captcha != nil {
                self.funnel?.logCaptchaShown()
            }
            self.updateEmailFieldReturnKeyType()
            self.enableProgressiveButtonIfNecessary()
        }, failure:failure)
        enableProgressiveButtonIfNecessary()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        enableProgressiveButtonIfNecessary()
    }

    fileprivate func hasUserEnteredCaptchaText() -> Bool {
        guard let text = captchaViewController?.solution else {
            return false
        }
        return (text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordRepeatField.becomeFirstResponder()
        case passwordRepeatField:
            emailField.becomeFirstResponder()
        case emailField:
            if captchaIsVisible() {
                captchaViewController?.captchaTextFieldBecomeFirstResponder()
            }else{
                save()
            }
        default:
            assertionFailure("Unhandled text field")
        }
        return true
    }

    func captchaKeyboardReturnKeyTapped() {
        save()
    }

    fileprivate func enableProgressiveButtonIfNecessary() {
        createAccountButton.isEnabled = shouldProgressiveButtonBeEnabled()
    }

    fileprivate func shouldProgressiveButtonBeEnabled() -> Bool {
        var shouldEnable = areRequiredFieldsPopulated()
        if captchaIsVisible() && shouldEnable {
            shouldEnable = hasUserEnteredCaptchaText()
        }
        return shouldEnable
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WMFAlertManager.sharedInstance.dismissAlert()
        super.viewWillDisappear(animated)
    }
    
    fileprivate func captchaIsVisible() -> Bool {
        return captchaViewController?.captcha != nil
    }
    
    fileprivate func updateEmailFieldReturnKeyType() {
        emailField.returnKeyType = captchaIsVisible() ? .next : .done
        // Resign and become first responder so keyboard return key updates right away.
        if emailField.isFirstResponder {
            emailField.resignFirstResponder()
            emailField.becomeFirstResponder()
        }
    }
    
    func captchaReloadPushed(_ sender: AnyObject) {
        enableProgressiveButtonIfNecessary()
    }
    
    func captchaSolutionChanged(_ sender: AnyObject, solutionText: String?) {
        enableProgressiveButtonIfNecessary()
    }
    
    public func captchaSiteURL() -> URL {
        return (MWKLanguageLinkController.sharedInstance().appLanguage?.siteURL())!
    }
    
    public func captchaHideSubtitle() -> Bool {
        return false
    }

    fileprivate func login() {
        WMFAlertManager.sharedInstance.showAlert(WMFLocalizedString("account-creation-logging-in", value:"Logging in...", comment:"Alert shown after account successfully created and the user is being logged in automatically.\n{{Identical|Logging in}}"), sticky: true, canBeDismissedByUser: false, dismissPreviousAlerts: true, tapCallBack: nil)
        WMFAuthenticationManager.sharedInstance.login(
            username: usernameField.text ?? "",
            password: passwordField.text ?? "",
            retypePassword: nil,
            oathToken: nil,
            captchaID: nil,
            captchaWord: nil,
            success: { _ in
                let loggedInMessage = String.localizedStringWithFormat(WMFLocalizedString("main-menu-account-title-logged-in", value:"Logged in as %1$@", comment:"Header text used when account is logged in. %1$@ will be replaced with current username."), self.usernameField.text ?? "")
                WMFAlertManager.sharedInstance.showSuccessAlert(loggedInMessage, sticky: false, dismissPreviousAlerts: true, tapCallBack: nil)
                let presenter = self.presentingViewController
                self.dismiss(animated: true, completion: {
                    presenter?.wmf_showEnableReadingListSyncPanel(theme: self.theme, oncePerLogin: true)
                })
        }, failure: { error in
            self.setViewControllerUserInteraction(enabled: true)
            self.enableProgressiveButtonIfNecessary()
            WMFAlertManager.sharedInstance.showErrorAlert(error as NSError, sticky: true, dismissPreviousAlerts: true, tapCallBack: nil)
        })
    }
    
    fileprivate func requiredInputFields() -> [UITextField] {
        assert(isViewLoaded, "This method is only intended to be called when view is loaded, since they'll all be nil otherwise")
        return [usernameField, passwordField, passwordRepeatField]
    }

    fileprivate func passwordFieldsMatch() -> Bool {
        return passwordField.text == passwordRepeatField.text
    }
    
    fileprivate func areRequiredFieldsPopulated() -> Bool {
        return requiredInputFields().wmf_allFieldsFilled()
    }
    
    fileprivate func save() {
        
        usernameAlertLabel.isHidden = true
        passwordRepeatAlertLabel.isHidden = true
        
        guard areRequiredFieldsPopulated() else {
            WMFAlertManager.sharedInstance.showErrorAlertWithMessage(WMFLocalizedString("account-creation-missing-fields", value:"You must enter a username, password, and password confirmation to create an account.", comment:"Error shown when one of the required fields for account creation (username, password, and password confirmation) is empty."), sticky: true, dismissPreviousAlerts: true, tapCallBack: nil)
            return
        }

        guard passwordFieldsMatch() else {
            self.passwordRepeatField.textColor = theme.colors.warning
            self.passwordRepeatField.keyboardAppearance = theme.keyboardAppearance
            self.passwordRepeatAlertLabel.isHidden = false
            self.scrollView.scrollSubView(toTop: self.passwordTitleLabel, offset: 6, animated: true)
            WMFAlertManager.sharedInstance.showErrorAlertWithMessage(WMFLocalizedString("account-creation-passwords-mismatched", value:"Password fields do not match.", comment:"Alert shown if the user doesn't enter the same password in both password boxes"), sticky: false, dismissPreviousAlerts: true, tapCallBack: nil)
            return
        }
        wmf_hideKeyboard()
        createAccount()
    }
    
    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case usernameField:
            usernameAlertLabel.isHidden = true
            usernameField.textColor = theme.colors.primaryText
            usernameField.keyboardAppearance = theme.keyboardAppearance
        case passwordRepeatField:
            passwordRepeatAlertLabel.isHidden = true
            passwordRepeatField.textColor = theme.colors.primaryText
            passwordRepeatField.keyboardAppearance = theme.keyboardAppearance
        default: break
        }
    }

    fileprivate func createAccount() {
        WMFAlertManager.sharedInstance.showAlert(WMFLocalizedString("account-creation-saving", value:"Saving...", comment:"Alert shown when user saves account creation form.\n{{Identical|Saving}}"), sticky: true, canBeDismissedByUser: false, dismissPreviousAlerts: true, tapCallBack: nil)
        
        let creationFailure: WMFErrorHandler = {error in
            
            self.setViewControllerUserInteraction(enabled: true)
            
            // Captcha's appear to be one-time, so always try to get a new one on failure.
            self.getCaptcha()
            
            if let error = error as? WMFAccountCreatorError {
                switch error {
                case .usernameUnavailable:
                    self.usernameAlertLabel.text = error.localizedDescription
                    self.usernameAlertLabel.isHidden = false
                    self.usernameField.textColor = self.theme.colors.error
                    self.usernameField.keyboardAppearance = self.theme.keyboardAppearance
                    self.funnel?.logError(error.localizedDescription)
                    WMFAlertManager.sharedInstance.dismissAlert()
                    return
                case .wrongCaptcha:
                    self.captchaViewController?.captchaTextFieldBecomeFirstResponder()
                default: break
                }
            }
            
            self.funnel?.logError(error.localizedDescription)
            self.enableProgressiveButtonIfNecessary()
            WMFAlertManager.sharedInstance.showErrorAlert(error as NSError, sticky: true, dismissPreviousAlerts: true, tapCallBack: nil)
        }
        
        self.setViewControllerUserInteraction(enabled: false)
        
        let siteURL = MWKLanguageLinkController.sharedInstance().appLanguage?.siteURL()
            tokenFetcher.fetchToken(ofType: .createAccount, siteURL: siteURL!, success: { token in
                self.accountCreator.createAccount(username: self.usernameField.text!, password: self.passwordField.text!, retypePassword: self.passwordRepeatField.text!, email: self.emailField.text!, captchaID:self.captchaViewController?.captcha?.captchaID, captchaWord: self.captchaViewController?.solution, token: token.token, siteURL: siteURL!, success: {_ in
                    self.login()
                }, failure: creationFailure)
            }, failure: creationFailure)
    }
    
    func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        
        titleLabel.textColor = theme.colors.primaryText
        for label in [usernameTitleLabel, passwordTitleLabel, passwordRepeatTitleLabel, emailTitleLabel] {
            label?.textColor = theme.colors.secondaryText
        }
        usernameAlertLabel.textColor = theme.colors.error
        passwordRepeatAlertLabel.textColor = theme.colors.warning
        for field in [usernameField, passwordRepeatField, emailField, passwordField] {
            field?.apply(theme: theme)
        }
        scrollContainer.backgroundColor = theme.colors.paperBackground
        view.backgroundColor = theme.colors.paperBackground
        view.tintColor = theme.colors.link
        loginButton.apply(theme: theme)
        createAccountButton.apply(theme: theme)
        captchaContainer.backgroundColor = theme.colors.paperBackground
        captchaViewController?.apply(theme: theme)
    }
}
