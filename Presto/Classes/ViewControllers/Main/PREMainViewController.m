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
// API
#import "PREAPIClient.h"

@interface PREMainViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) PRECard *card;

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

#pragma mark - UI

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor lightGreenColor];
    
    [self setupScrollView];
    [self setupRefreshControl];
    [self setupBalanceLabel];
}

- (void)setupScrollView {
    self.scrollView = [UIScrollView newForAutolayoutAndAddToView:self.view];
    self.scrollView.alwaysBounceVertical = YES;
    
    // Constraints
    NSArray *constraints = constraintsEqualSizeAndPosition(self.scrollView, self.view);
    [self.view addConstraints:constraints];
}

- (void)setupRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];
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

- (void)refreshLabel {
    self.balanceLabel.text = self.card.balance;
}

#pragma mark - Refresh Control

- (void)refresh:(UIRefreshControl *)refreshControl {
    NSAttributedString *previousRefreshTitle = refreshControl.attributedTitle;
    refreshControl.attributedTitle = [PREMainViewController refreshingDataAttributedString];
    [PREAPIClient getCardStatusForCurrentUserWithCompletion:^(id responseObject, NSURLResponse *response, NSError *error) {
        if (error) {
            refreshControl.attributedTitle = previousRefreshTitle;
        } else {
            refreshControl.attributedTitle = [PREMainViewController currentTimeAttributedString];
            PRECard *card = [PRECard instanceWithPrimaryKey:responseObject[@"number"]];
            card.status = responseObject[@"status"];
            card.balance = responseObject[@"balance"];
            [card save];
            [self refreshLabel];
        }
        [refreshControl endRefreshing];
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

@end
