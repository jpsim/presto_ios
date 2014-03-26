//
//  PRENavigationViewController.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PRENavigationViewController.h"

@implementation PRENavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
