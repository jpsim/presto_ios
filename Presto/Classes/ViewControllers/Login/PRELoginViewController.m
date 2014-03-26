//
//  PRELoginViewController.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PRELoginViewController.h"
// View Controllers
#import "PREMainViewController.h"
// Classes
#import "PREAPIClient.h"
#import "SVProgressHUD.h"
// Categories
#import "UIColor+PREAdditions.h"
#import "UIView+AutoLayout.h"
// Models
#import "PREUser.h"
#import "PRECard.h"

@interface PRELoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView        * logoView;
@property (nonatomic, strong) UIView             * topSpacerView;
@property (nonatomic, strong) UIView             * bottomSpacerView;
@property (nonatomic, assign) PRELoginFieldType    loginType;
@property (nonatomic, strong) PRELoginField      * usernameField;
@property (nonatomic, strong) PRELoginField      * passwordField;
@property (nonatomic, strong) PRELoginField      * cardField;
@property (nonatomic, strong) UIButton           * loginButton;
@property (nonatomic, strong) UIButton           * cardLoginButton;

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

#pragma mark - UI

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupView {
    // Background
    self.view.backgroundColor = [UIColor lightGreenColor];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setupTopSpacerView];
    [self setupLogoView];
    if (_loginType == PRELoginFieldTypeCard) {
        [self setupCardField];
    } else {
        [self setupUsernameField];
        [self setupPasswordField];
        [self setupCardLoginButton];
    }
    [self setupLoginButton];
    [self setupBottomSpacerView];
}

- (void)setupTopSpacerView {
    self.topSpacerView = [UIView newForAutolayoutAndAddToView:self.view];
    NSLayoutConstraint *top = constraintEqualAttributes(self.topSpacerView, (UIView *)self.topLayoutGuide, NSLayoutAttributeTop, NSLayoutAttributeTop, 0);
    NSLayoutConstraint *centerX = constraintCenterX(self.topSpacerView, self.view);
    NSLayoutConstraint *width = constraintAbsolute(self.topSpacerView, NSLayoutAttributeWidth, 0);
    [self.view addConstraints:@[top, centerX, width]];
}

- (void)setupLogoView {
    self.logoView = [UIImageView newForAutolayoutAndAddToView:self.view];
    self.logoView.image = [UIImage imageNamed:@"logo"];
    NSLayoutConstraint *logoCenterX = constraintCenterX(self.logoView, self.view);
    NSLayoutConstraint *top = constraintEqualAttributes(self.logoView, self.topSpacerView, NSLayoutAttributeTop, NSLayoutAttributeBottom, 0);
    [self.view addConstraints:@[logoCenterX, top]];
}

- (void)setupCardField {
    self.cardField = [PRELoginField newForAutolayoutAndAddToView:self.view];
    self.cardField.fieldType = PRELoginFieldTypeCard;
    self.cardField.delegate = self;
    NSArray *cardSize = constraintsAbsoluteSize(self.cardField, 252, 44);
    NSLayoutConstraint *cardX = constraintCenterX(self.cardField, self.logoView);
    NSLayoutConstraint *cardTrail = constraintTrailVertically(self.cardField, self.logoView, 24);
    [self.view addConstraints:cardSize];
    [self.view addConstraints:@[cardX, cardTrail]];
}

- (void)setupUsernameField {
    self.usernameField = [PRELoginField newForAutolayoutAndAddToView:self.view];
    self.usernameField.fieldType = PRELoginFieldTypeUsername;
    self.usernameField.delegate = self;
    NSArray *usernameSize = constraintsAbsoluteSize(self.usernameField, 230, 44);
    NSLayoutConstraint *usernameX = constraintCenterX(self.usernameField, self.logoView);
    NSLayoutConstraint *usernameTrail = constraintTrailVertically(self.usernameField, self.logoView, 24);
    [self.view addConstraints:usernameSize];
    [self.view addConstraints:@[usernameX, usernameTrail]];
}

- (void)setupPasswordField {
    self.passwordField = [PRELoginField newForAutolayoutAndAddToView:self.view];
    self.passwordField.fieldType = PRELoginFieldTypePassword;
    self.passwordField.delegate = self;
    NSArray *passwordSize = constraintsEqualSize(self.passwordField, self.usernameField, 0, 0);
    NSLayoutConstraint *passwordX = constraintCenterX(self.passwordField, self.usernameField);
    NSLayoutConstraint *passwordTrail = constraintTrailVertically(self.passwordField, self.usernameField, 24);
    [self.view addConstraints:passwordSize];
    [self.view addConstraints:@[passwordX, passwordTrail]];
}

- (void)setupLoginButton {
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    [self.loginButton prepareForAutolayoutAndAddToView:self.view];
    BOOL isCardLogin = (_loginType == PRELoginFieldTypeCard);
    NSArray *loginButtonSize = constraintsEqualSize(self.loginButton, isCardLogin ? self.cardField : self.passwordField, 0, 0);
    NSLayoutConstraint *loginButtonX = constraintCenterX(self.loginButton, isCardLogin ? self.cardField : self.passwordField);
    NSLayoutConstraint *loginButtonTrail = constraintTrailVertically(self.loginButton, isCardLogin ? self.cardField : self.passwordField, 0);
    [self.view addConstraints:loginButtonSize];
    [self.view addConstraints:@[loginButtonX, loginButtonTrail]];
}

- (void)setupBottomSpacerView {
    self.bottomSpacerView = [UIView newForAutolayoutAndAddToView:self.view];
    NSLayoutConstraint *top = constraintEqualAttributes(self.bottomSpacerView, self.loginButton, NSLayoutAttributeTop, NSLayoutAttributeBottom, 0);
    NSLayoutConstraint *centerX = constraintCenterX(self.bottomSpacerView, self.view);
    NSLayoutConstraint *width = constraintAbsolute(self.bottomSpacerView, NSLayoutAttributeWidth, 0);
    NSLayoutConstraint *bottom = constraintEqual(self.bottomSpacerView, (UIView *)self.keyboardLayoutGuide, NSLayoutAttributeBottom, 0);
    bottom.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *height = constraintEqual(self.topSpacerView, self.bottomSpacerView, NSLayoutAttributeHeight, 0);
    [self.view addConstraints:@[top, centerX, width, bottom, height]];
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
    PREAPIResponseBlock completion = ^(id responseObject, NSURLResponse *response, NSError *error){
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            PRECard *card = [PRECard instanceWithPrimaryKey:responseObject[@"number"]];
            card.status = responseObject[@"status"];
            card.balance = responseObject[@"balance"];
            [card save];
            [PREUser saveNewUserWithUsername:self.usernameField.text
                                    password:self.passwordField.text
                                        card:card];
            [self launchMainApp];
        }
    };
    if (_loginType == PRELoginFieldTypeCard) {
        [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeBlack];
        [PREAPIClient getCardStatusWithCardNumber:self.cardField.text completion:completion];
    } else {
        if (self.usernameField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"No username"];
        } else {
            [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeBlack];
            [PREAPIClient getCardStatusWithUsername:self.usernameField.text password:self.passwordField.text completion:completion];
            [PREAPIClient getUserWithUsername:self.usernameField.text password:self.passwordField.text completion:^(id responseObject, NSURLResponse *response, NSError *error) {
                PREUser *user = [PREUser instanceWithPrimaryKey:responseObject[@"card_number"]];
                [user updateWithAPIResponseDict:responseObject];
                [user save];
            }];
        }
    }
}

- (void)launchMainApp {
    [SVProgressHUD dismiss];
    [self presentViewController:[[PREMainViewController alloc] init] animated:NO completion:nil];
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

#pragma mark - Keyboard

- (void)dismissKeyboard {
    [self.cardField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
