//
//  PRELoginViewController.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PRELoginViewController.h"
// Classes
#import "PREAPIClient.h"
#import "SVProgressHUD.h"
// Categories
#import "UIColor+PREAdditions.h"
#import "UIView+AutoLayout.h"

@interface PRELoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView             * containerView;
@property (nonatomic, strong) UIImageView        * logoView;
@property (nonatomic, assign) PRELoginFieldType    loginType;
@property (nonatomic, strong) PRELoginField      * usernameField;
@property (nonatomic, strong) PRELoginField      * passwordField;
@property (nonatomic, strong) PRELoginField      * cardField;
@property (nonatomic, strong) UIButton           * loginButton;
@property (nonatomic, strong) UIButton           * cardLoginButton;
@property (nonatomic, strong) NSLayoutConstraint * containerBottom;

@end

@implementation PRELoginViewController

#pragma mark - Init

- (instancetype)initWithLoginType:(PRELoginFieldType)type {
    self = [super init];
    if (self) {
        _loginType = type;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    // Layout views without animating, otherwise views animate from {0,0,0,0}
    [UIView performWithoutAnimation:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self observeKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupView {
    // Background
    self.view.backgroundColor = [UIColor lightGreenColor];
    
    [self setupContainerView];
    [self setupLogoView];
    if (_loginType == PRELoginFieldTypeCard) {
        [self setupCardField];
    } else {
        [self setupUsernameField];
        [self setupPasswordField];
        [self setupCardLoginButton];
    }
    [self setupLoginButton];
}

- (void)setupContainerView {
    self.containerView = [UIView newForAutolayoutAndAddToView:self.view];
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    NSLayoutConstraint *containerTop = constraintEqual(self.containerView, self.view, NSLayoutAttributeTop, 0);
    NSLayoutConstraint *containerLeft = constraintEqual(self.containerView, self.view, NSLayoutAttributeLeft, 0);
    NSLayoutConstraint *containerRight = constraintEqual(self.containerView, self.view, NSLayoutAttributeRight, 0);
    self.containerBottom = constraintEqual(self.containerView, self.view, NSLayoutAttributeBottom, 0);
    [self.view addConstraints:@[containerTop, containerLeft, containerRight, self.containerBottom]];
}

- (void)setupLogoView {
    self.logoView = [UIImageView newForAutolayoutAndAddToView:self.containerView];
    self.logoView.image = [UIImage imageNamed:@"logo"];
    CGFloat offset = (_loginType == PRELoginFieldTypeCard) ? -30 : -76;
    NSArray *logoCenter = constraintsCenterWithOffset(self.logoView, self.containerView, 0, offset);
    [self.containerView addConstraints:logoCenter];
}

- (void)setupCardField {
    self.cardField = [PRELoginField newForAutolayoutAndAddToView:self.containerView];
    self.cardField.fieldType = PRELoginFieldTypeCard;
    self.cardField.delegate = self;
    NSArray *cardSize = constraintsAbsoluteSize(self.cardField, 252, 44);
    NSLayoutConstraint *cardX = constraintCenterX(self.cardField, self.logoView);
    NSLayoutConstraint *cardTrail = constraintTrailVertically(self.cardField, self.logoView, 24);
    [self.containerView addConstraints:cardSize];
    [self.containerView addConstraints:@[cardX, cardTrail]];
}

- (void)setupUsernameField {
    self.usernameField = [PRELoginField newForAutolayoutAndAddToView:self.containerView];
    self.usernameField.fieldType = PRELoginFieldTypeUsername;
    self.usernameField.delegate = self;
    NSArray *usernameSize = constraintsAbsoluteSize(self.usernameField, 230, 44);
    NSLayoutConstraint *usernameX = constraintCenterX(self.usernameField, self.logoView);
    NSLayoutConstraint *usernameTrail = constraintTrailVertically(self.usernameField, self.logoView, 24);
    [self.containerView addConstraints:usernameSize];
    [self.containerView addConstraints:@[usernameX, usernameTrail]];
}

- (void)setupPasswordField {
    self.passwordField = [PRELoginField newForAutolayoutAndAddToView:self.containerView];
    self.passwordField.fieldType = PRELoginFieldTypePassword;
    self.passwordField.delegate = self;
    NSArray *passwordSize = constraintsEqualSize(self.passwordField, self.usernameField, 0, 0);
    NSLayoutConstraint *passwordX = constraintCenterX(self.passwordField, self.usernameField);
    NSLayoutConstraint *passwordTrail = constraintTrailVertically(self.passwordField, self.usernameField, 24);
    [self.containerView addConstraints:passwordSize];
    [self.containerView addConstraints:@[passwordX, passwordTrail]];
}

- (void)setupLoginButton {
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    [self.loginButton prepareForAutolayoutAndAddToView:self.containerView];
    BOOL isCardLogin = (_loginType == PRELoginFieldTypeCard);
    NSArray *loginButtonSize = constraintsEqualSize(self.loginButton, isCardLogin ? self.cardField : self.passwordField, 0, 0);
    NSLayoutConstraint *loginButtonX = constraintCenterX(self.loginButton, isCardLogin ? self.cardField : self.passwordField);
    NSLayoutConstraint *loginButtonTrail = constraintTrailVertically(self.loginButton, isCardLogin ? self.cardField : self.passwordField, 0);
    [self.containerView addConstraints:loginButtonSize];
    [self.containerView addConstraints:@[loginButtonX, loginButtonTrail]];
}

- (void)setupCardLoginButton {
    self.cardLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cardLoginButton addTarget:self action:@selector(cardLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.cardLoginButton setTitle:@"Log in with an unregistered card" forState:UIControlStateNormal];
    [self.cardLoginButton prepareForAutolayoutAndAddToView:self.view];
    NSLayoutConstraint *cardLoginButtonX = constraintCenterX(self.cardLoginButton, self.view);
    NSLayoutConstraint *cardLoginButtonBottom = constraintBottom(self.cardLoginButton, self.view, -10.0f);
    [self.view addConstraints:@[cardLoginButtonX, cardLoginButtonBottom]];
}

#pragma mark - Actions

- (void)login {
    [self dismissKeyboard];
    if (_loginType == PRELoginFieldTypeCard) {
        [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeBlack];
        [PREAPIClient getCardStatusWithCardNumber:self.cardField.text completion:^(id responseObject, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Balance: %@", responseObject[@"balance"]]];
            }
            [self launchMainApp];
        }];
    } else {
        if (self.usernameField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"No username"];
        } else {
            [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeBlack];
            [PREAPIClient getCardStatusWithUsername:self.usernameField.text password:self.passwordField.text completion:^(id responseObject, NSError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Balance: %@", responseObject[@"balance"]]];
                }
                [self launchMainApp];
            }];
        }
    }
}

- (void)launchMainApp {
}

- (void)cardLogin {
    [self.navigationController pushViewController:[[PRELoginViewController alloc] initWithLoginType:PRELoginFieldTypeCard] animated:YES];
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_loginType == PRELoginFieldTypeCard) {
        self.loginButton.enabled = updatedString.length > 0;
    } else {
        BOOL user = (textField == self.usernameField);
        NSString *usernameString = user ? updatedString : self.usernameField.text;
        NSString *passwordString = user ? self.passwordField.text : updatedString;
        self.loginButton.enabled = usernameString.length > 0 && passwordString.length > 0;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.loginButton.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_loginType == PRELoginFieldTypeCard) {
        [self login];
    } else if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self login];
    }
    return YES;
}

#pragma mark - Keyboard Methods

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dismissKeyboard {
    [self.cardField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSValue *kbFrame = info[UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = kbFrame.CGRectValue;
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    
    self.containerBottom.constant = -height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.containerBottom.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

@end
