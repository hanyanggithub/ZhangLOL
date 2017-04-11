//
//  MessgeDetailController.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessgeDetailController.h"
#import <WebKit/WebKit.h>

@interface MessgeDetailController ()
@property(nonatomic, strong)WKWebView *webView;

@end

@implementation MessgeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingNavigationBar];
    WKWebViewConfiguration *cofig = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:cofig];
    [self.view addSubview:self.webView];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.model.article_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [self.webView loadRequest:request];
    
}

- (void)settingNavigationBar {
    self.navigationItem.title = @"资讯详情";
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 22, 40);
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny_normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny__pressed"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
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
