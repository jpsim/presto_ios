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

@interface PREMainViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *balanceLabel;

@end

@implementation PREMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
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
    self.balanceLabel.text = @"$1.24";
    self.balanceLabel.textAlignment = NSTextAlignmentCenter;
    self.balanceLabel.textColor = [UIColor whiteColor];
    
    self.balanceLabel.font = [UIFont boldSystemFontOfSize:36.0f];
    
    // Constraints
    NSArray *center = constraintsCenter(self.balanceLabel, self.scrollView);
    [self.scrollView addConstraints:center];
}

#pragma mark - Refresh Control

- (void)refresh:(UIRefreshControl *)refreshControl {
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
        
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate  attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        [refreshControl endRefreshing];
    });
}

@end
