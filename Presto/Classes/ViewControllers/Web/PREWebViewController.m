//
//  PREWebViewController.m
//  Presto
//
//  Created by JP Simard on 2014-03-27.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREWebViewController.h"
#import "UIView+AutoLayout.h"

@interface PREWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, copy) NSString *javascript;

@end

@implementation PREWebViewController

#pragma mark - Init

+ (instancetype)webVCWithHTML:(NSString *)html javascript:(NSString *)javascript {
    return [[self alloc] initWithHTML:html javascript:javascript];
}

- (instancetype)initWithHTML:(NSString *)html javascript:(NSString *)javascript {
    self = [super init];
    if (self) {
        _html = html.copy;
        _javascript = javascript.copy;
        self.title = @"Payment Confirmation";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
    self.navigationController.navigationBar.tintColor = self.view.tintColor;
}

- (void)setupWebView {
    self.webView = [UIWebView newForAutolayoutAndAddToView:self.view];
    self.webView.delegate = self;
    if (self.html) [self.webView loadHTMLString:self.html baseURL:nil];
    
    // Constraints
    [self.view addConstraints:constraintsEqualSizeAndPosition(self.webView, self.view)];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (self.javascript) [webView stringByEvaluatingJavaScriptFromString:self.javascript];
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
