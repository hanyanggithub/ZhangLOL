//
//  MessgeDetailController.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessgeDetailController.h"
#import <WebKit/WebKit.h>

@interface MessgeDetailController ()<UIGestureRecognizerDelegate>
@property(nonatomic, strong)WKWebView *webView;

@end

@implementation MessgeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubviews];
    [self settingNavigationBar];
}

- (void)createSubviews {
    
    WKWebViewConfiguration *cofig = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.width, self.view.height - 44) configuration:cofig];
    [self.view addSubview:self.webView];
    NSString *urlStr = nil;
    if (self.cellModel) {
        urlStr = self.cellModel.article_url;
    }else if (self.vendorModel) {
        urlStr = self.vendorModel.article_url;
    }else{
        
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self.webView loadRequest:request];
}

- (void)settingNavigationBar {
    
    [self.view insertSubview:self.customNaviBar aboveSubview:self.webView];
    self.customNaviItem.title = @"资讯详情";
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_for_seven"] forBarMetrics:UIBarMetricsDefault];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 22, 40);
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny_normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny__pressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.customNaviItem.leftBarButtonItem = leftItem;
    
    __weak id systemTarget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *popPan = [[UIPanGestureRecognizer alloc] initWithTarget:systemTarget action:NSSelectorFromString(@"handleNavigationTransition:")];
    [self.view addGestureRecognizer:popPan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
- (void)backButtonClicked {
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
