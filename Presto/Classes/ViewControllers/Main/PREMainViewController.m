//
//  PREMainViewController.m
//  Presto
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREMainViewController.h"
// Categories
#import "UIColor+PREAdditions.h"
#import "UIView+AutoLayout.h"
// Model
#import "PREUser.h"
#import "PRECard.h"
#import "PRECreditCard.h"
// API
#import "PREAPIClient.h"

@interface PREMainViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) PRECard *card;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PREMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.card = (PRECard *)[[PRECard allInstances] lastObject];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
}

#pragma mark - UI

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor lightGreenColor];
    
    [self setupScrollView];
    [self setupRefreshControl];
    [self setupBalanceLabel];
    [self setupLogoutButton];
}

- (void)setupScrollView {
    self.scrollView = [UIScrollView newForAutolayoutAndAddToView:self.view];
    self.scrollView.alwaysBounceVertical = YES;
    
    // Constraints
    NSArray *constraints = constraintsEqualSizeAndPosition(self.scrollView, self.view);
    [self.view addConstraints:constraints];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
}

- (void)setupBalanceLabel {
    self.balanceLabel = [UILabel newForAutolayoutAndAddToView:self.scrollView];
    self.balanceLabel.textAlignment = NSTextAlignmentCenter;
    self.balanceLabel.textColor = [UIColor whiteColor];
    
    self.balanceLabel.font = [UIFont boldSystemFontOfSize:36.0f];
    
    // Constraints
    NSArray *center = constraintsCenter(self.balanceLabel, self.scrollView);
    [self.scrollView addConstraints:center];
}

- (void)setupLogoutButton {
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [logoutButton prepareForAutolayoutAndAddToView:self.view];
    [logoutButton setImage:[[UIImage imageNamed:@"logout"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [logoutButton invalidateIntrinsicContentSize];
    [logoutButton addTarget:self action:@selector(promptForLogout) forControlEvents:UIControlEventTouchUpInside];
    
    // Constraints
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:logoutButton
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0f
                                                             constant:15.0f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:logoutButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:-15.0f];
    [self.view addConstraints:@[left, bottom]];
}

- (void)refreshLabel {
    self.balanceLabel.text = self.card.balance;
}

#pragma mark - Refresh Control

- (void)refresh {
    NSAttributedString *previousRefreshTitle = self.refreshControl.attributedTitle;
    self.refreshControl.attributedTitle = [PREMainViewController refreshingDataAttributedString];
    [PREAPIClient getCardStatusForCurrentUserWithCompletion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error) {
            self.refreshControl.attributedTitle = previousRefreshTitle;
        } else {
            self.refreshControl.attributedTitle = [PREMainViewController currentTimeAttributedString];
            PRECard *card = [PRECard instanceWithPrimaryKey:responseObject[@"number"]];
            card.status = responseObject[@"status"];
            card.balance = responseObject[@"balance"];
            [card save];
            [self refreshLabel];
        }
        [self.refreshControl endRefreshing];
    }];
}

+ (NSAttributedString *)refreshingDataAttributedString {
    return [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

+ (NSAttributedString *)currentTimeAttributedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    
    return [[NSAttributedString alloc] initWithString:lastUpdate  attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

#pragma mark - Actions

- (void)promptForLogout {
    [[[UIAlertView alloc] initWithTitle:@"Logout"
                               message:@"Are you sure you want to log out?"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Log Out", nil] show];
}

- (void)logout {
    [PREUser executeUpdateQuery:@"DELETE FROM $T"];
    [PRECard executeUpdateQuery:@"DELETE FROM $T"];
    [PRECreditCard executeUpdateQuery:@"DELETE FROM $T"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) [self logout];
}

@end
