import Foundation
import UIKit

enum WMFWelcomePageType {
    case intro
    case exploration
    case languages
    case analytics
}

public protocol WMFWelcomeNavigationDelegate: class{
    func showNextWelcomePage(_ sender: AnyObject)
}

class WMFWelcomePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, WMFWelcomeNavigationDelegate {

    fileprivate var theme = Theme.standard
    
    @objc var completionBlock: (() -> Void)?
    
    func showNextWelcomePage(_ sender: AnyObject){
        guard let sender = sender as? UIViewController, let index = pageControllers.index(of: sender), index != pageControllers.count - 1 else {
            dismiss(animated: true, completion:completionBlock)
            return
        }
        view.isUserInteractionEnabled = false
        let nextIndex = index + 1
        let direction:UIPageViewControllerNavigationDirection = UIApplication.shared.wmf_isRTL ? .reverse : .forward
        let nextVC = pageControllers[nextIndex]
        hideButtons(for: nextVC)
        setViewControllers([nextVC], direction: direction, animated: true, completion: {(Bool) in
            self.view.isUserInteractionEnabled = true
        })
    }
    /*
    func showPreviousWelcomePage(_ sender: AnyObject){
        guard let sender = sender as? UIViewController, let index = pageControllers.index(of: sender), index > 0 else {
            return
        }
        view.isUserInteractionEnabled = false
        let prevIndex = index - 1
        let direction:UIPageViewControllerNavigationDirection = UIApplication.shared.wmf_isRTL ? .forward : .reverse
        setViewControllers([pageControllers[prevIndex]], direction: direction, animated: true, completion: {(Bool) in
            self.view.isUserInteractionEnabled = true
        })
    }
    */
    fileprivate func containerControllerForWelcomePageType(_ type: WMFWelcomePageType) -> WMFWelcomeContainerViewController {
        let controller = WMFWelcomeContainerViewController.wmf_viewControllerFromWelcomeStoryboard()
        controller.welcomeNavigationDelegate = self
        controller.welcomePageType = type
        return controller
    }
    
    fileprivate lazy var pageControllers: [UIViewController] = {
        var controllers:[UIViewController] = []
        controllers.append(containerControllerForWelcomePageType(.intro))
        controllers.append(containerControllerForWelcomePageType(.exploration))
        controllers.append(containerControllerForWelcomePageType(.languages))
        controllers.append(containerControllerForWelcomePageType(.analytics))
        return controllers
    }()
    
    fileprivate lazy var pageControl: UIPageControl? = {
        return view.wmf_firstSubviewOfType(UIPageControl.self)
    }()

    let nextButton = UIButton()
    let skipButton = UIButton()
    let buttonHeight: CGFloat = 40.0
    let buttonSidePadding: CGFloat = 10.0
    let buttonCenterXOffset: CGFloat = 88.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        let direction:UIPageViewControllerNavigationDirection = UIApplication.shared.wmf_isRTL ? .forward : .reverse
        
        setViewControllers([pageControllers.first!], direction: direction, animated: true, completion: nil)
        
        configureAndAddNextButton()
        configureAndAddSkipButton()
        
        if let scrollView = view.wmf_firstSubviewOfType(UIScrollView.self) {
            scrollView.clipsToBounds = false
        }
    }
    
    fileprivate func configureAndAddNextButton(){
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.isUserInteractionEnabled = true
        nextButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        nextButton.titleLabel?.numberOfLines = 1
        nextButton.setTitle(CommonStrings.nextTitle, for: .normal)
        nextButton.setTitleColor(theme.colors.link, for: .normal)
        nextButton.setTitleColor(theme.colors.disabledText, for: .disabled)
        nextButton.setTitleColor(theme.colors.link, for: .highlighted)
        view.addSubview(nextButton)
        nextButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        view.addConstraint(NSLayoutConstraint(item: nextButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        let leading = NSLayoutConstraint(item: nextButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: buttonCenterXOffset)
        leading.priority = .defaultHigh
        let trailing = NSLayoutConstraint(item: nextButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: buttonSidePadding)
        trailing.priority = .required
        view.addConstraints([leading, trailing])
    }

    fileprivate func configureAndAddSkipButton(){
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        skipButton.isUserInteractionEnabled = true
        skipButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        skipButton.titleLabel?.numberOfLines = 1
        skipButton.setTitle(CommonStrings.skipTitle, for: .normal)
        skipButton.setTitleColor(UIColor(0xA2A9B1), for: .normal)
        view.addSubview(skipButton)
        skipButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        view.addConstraint(NSLayoutConstraint(item: skipButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

        let leading = NSLayoutConstraint(item: skipButton, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: buttonSidePadding)
        leading.priority = .required
        let trailing = NSLayoutConstraint(item: skipButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: -buttonCenterXOffset)
        trailing.priority = .defaultHigh
        view.addConstraints([leading, trailing])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        skipButton.titleLabel?.font = UIFont.wmf_preferredFontForFontFamily(.systemSemiBold, withTextStyle: .footnote, compatibleWithTraitCollection: traitCollection)
        nextButton.titleLabel?.font = UIFont.wmf_preferredFontForFontFamily(.systemSemiBold, withTextStyle: .footnote, compatibleWithTraitCollection: traitCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let pageControl = pageControl {
            pageControl.isUserInteractionEnabled = false
            pageControl.pageIndicatorTintColor = theme.colors.disabledLink
            pageControl.currentPageIndicatorTintColor = theme.colors.link
        }
    }

    @objc func nextButtonTapped(_ sender: UIButton) {
        if let currentVC = viewControllers?.first {
            showNextWelcomePage(currentVC)
        }
    }
    
    @objc func skipButtonTapped(_ sender: UIButton) {
        /*
         if let currentVC = viewControllers?.first {
             showPreviousWelcomePage(currentVC)
         }
         */
        dismiss(animated: true, completion:completionBlock)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let viewControllers = viewControllers, let currentVC = viewControllers.first, let presentationIndex = pageControllers.index(of: currentVC) else {
            return 0
        }
        return presentationIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.index(of: viewController) else {
            return nil
        }
        return index >= pageControllers.count - 1 ? nil : pageControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.index(of: viewController) else {
            return nil
        }
        return index == 0 ? nil : pageControllers[index - 1]
    }
    
    // MARK: - iOS 9 RTL swiping hack
    // When *swiping* side-to-side to move between panels on RTL with iOS 9 the dots get out of sync... not sure why. 
    // This hack sets the correct dot, but first fades the dots out so you don't see it flicker to the wrong dot then the right one.
    
    fileprivate func isRTLiOS9() -> Bool {
        return UIApplication.shared.wmf_isRTL && ProcessInfo().wmf_isOperatingSystemMajorVersionLessThan(10)
    }
    
    func animateIfRightToLeftAndiOS9(_ animations: @escaping () -> Void) {
        if isRTLiOS9() {
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveEaseOut, animations:animations, completion:nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        animateIfRightToLeftAndiOS9({
            if let pageControl = self.pageControl {
                pageControl.alpha = 0.0
            }
        })
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if completed {
            hideButtons(for: pageControllers[presentationIndex(for: pageViewController)])
        }
        animateIfRightToLeftAndiOS9({
            if let pageControl = self.pageControl {
                pageControl.currentPage = self.presentationIndex(for: pageViewController)
                pageControl.alpha = 1.0
            }
        })
    }

    func hideButtons(for vc: UIViewController){
        let isLastPage = pageControllers.index(of: vc) == pageControllers.count - 1
        let newAlpha:CGFloat = isLastPage ? 0.0 : 1.0
        let alphaChanged = pageControl?.alpha != newAlpha
        nextButton.isEnabled = !isLastPage // Gray out the next button when transitioning to last page (per design)
        guard alphaChanged else { return }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
            self.nextButton.alpha = newAlpha
            self.skipButton.alpha = newAlpha
            self.pageControl?.alpha = newAlpha
        }, completion: nil)
    }
}
