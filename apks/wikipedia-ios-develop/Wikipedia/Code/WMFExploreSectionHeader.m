#import "WMFExploreSectionHeader.h"
#import "Wikipedia-Swift.h"

@interface WMFExploreSectionHeader ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightButtonWidthConstraint;
@property (assign, nonatomic) CGFloat rightButtonWidthConstraintConstant;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UIView *iconContainerView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation WMFExploreSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    [self reset];
    self.titleLabel.isAccessibilityElement = NO;
    self.subTitleLabel.isAccessibilityElement = NO;
    self.containerView.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitHeader;
    self.rightButtonWidthConstraintConstant = self.rightButtonWidthConstraint.constant;
    self.rightButton.hidden = YES;
    self.rightButton.isAccessibilityElement = YES;
    self.rightButton.accessibilityTraits = UIAccessibilityTraitButton;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self wmf_configureSubviewsForDynamicType];
    [self addGestureRecognizer:tapGR];
}

- (void)handleTapGesture:(UIGestureRecognizer *)tapGR {
    if (tapGR.state != UIGestureRecognizerStateRecognized) {
        return;
    }
    if (self.whenTapped) {
        self.whenTapped();
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    self.subTitleLabel.font = [UIFont wmf_preferredFontForFontFamily:WMFFontFamilySystemSemiBold
                                                       withTextStyle:UIFontTextStyleSubheadline
                                       compatibleWithTraitCollection:self.traitCollection];
}

- (void)setImage:(UIImage *)image {
    self.icon.image = image;
}

- (void)setImageTintColor:(UIColor *)imageTintColor {
    self.icon.tintColor = imageTintColor;
}

- (void)setImageBackgroundColor:(UIColor *)imageBackgroundColor {
    self.iconContainerView.backgroundColor = imageBackgroundColor;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self updateAccessibilityLabel];
}

- (void)setSubTitle:(NSString *)subTitle {
    self.subTitleLabel.text = subTitle;
    [self updateAccessibilityLabel];
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
}

- (void)setSubTitleColor:(UIColor *)subTitleColor {
    self.subTitleLabel.textColor = subTitleColor;
}

- (void)updateAccessibilityLabel {
    NSString *title = self.titleLabel.text;
    NSString *subtitle = self.subTitleLabel.text;
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:2];
    if (title) {
        [components addObject:title];
    }
    if (subtitle) {
        [components addObject:subtitle];
    }
    self.containerView.accessibilityLabel = [components componentsJoinedByString:@" "];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self reset];
}

- (void)reset {
    self.titleLabel.text = @"";
    self.subTitleLabel.text = @"";
    self.rightButtonEnabled = NO;
}

- (void)setRightButtonEnabled:(BOOL)rightButtonEnabled {
    if (_rightButtonEnabled == rightButtonEnabled) {
        return;
    }
    _rightButtonEnabled = rightButtonEnabled;
    self.rightButton.hidden = !self.rightButtonEnabled;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints {
    if (self.rightButtonEnabled) {
        self.rightButtonWidthConstraint.constant = self.rightButtonWidthConstraintConstant;
    } else {
        self.rightButtonWidthConstraint.constant = 0;
    }
    [super updateConstraints];
}

- (void)applyTheme:(WMFTheme *)theme {
    self.containerView.backgroundColor = theme.colors.paperBackground;
    self.titleLabel.textColor = theme.colors.secondaryText;
    self.titleLabel.backgroundColor = theme.colors.paperBackground;
    self.subTitleLabel.textColor = theme.colors.secondaryText;
    self.subTitleLabel.backgroundColor = theme.colors.paperBackground;
    self.rightButton.backgroundColor = theme.colors.paperBackground;
    self.backgroundColor = theme.colors.paperBackground;

    if (theme.colors.iconBackground != nil) {
        self.iconContainerView.backgroundColor = theme.colors.iconBackground;
    }
    if (theme.colors.icon != nil) {
        self.icon.tintColor = theme.colors.icon;
    }
}

@end
