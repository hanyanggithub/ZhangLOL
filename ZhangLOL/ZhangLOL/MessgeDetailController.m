//
//  MessgeDetailController.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessgeDetailController.h"
#import "SmallCellModel.h"
#import "RencommendModel.h"
#import <WebKit/WebKit.h>

@interface MessgeDetailController ()<WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic, strong)WKWebView *webView;
@property(nonatomic, strong)UIProgressView *progressView;
@property(nonatomic, copy)NSString *movieUrl;
@end

@implementation MessgeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableFullScreenPop = YES;
    self.haveBackButton = YES;
    [self createSubviews];
    [self settingNavigationBar];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    MYLog(@"%@",message.body);
    if ([message.name isEqualToString:@"jsFunction"]) {
        return ;
    }
    if ([message.name isEqualToString:@"playMovie"]) {
        // 播放
//        NSString *playCode= @"LOL_QT_Video.openUrl('http://qt.qq.com/?reqApp=&type=VIDEO_PLAY&vData=\"videoObj.msg.vid\"&vType=VOD&dType=VOD&ivideoid=\"LOL_QT_Video.VideoId\"&time=\"videoObj.msg.time');";
        
//        NSString *jsCode = @" $('#todoPlay').attr('href',\"javascript:LOL_QT_Video.LOL_Play_Video(\"+LOL_QT_Video.VideoId+\",'\"+videoObj.msg.vid+\"','//qt.qq.com/?reqApp=|type=VIDEO_PLAY|vData=\"+videoObj.msg.vid+\"|vType=VOD|dType=VOD|ivideoid=\"+self.VideoId+\"|time=\"+videoObj.msg.time+\"')\"); var iframe = document.getElementById('todoPlay');window.webkit.messageHandlers.jsFunction.postMessage(iframe.href);";
////        NSString *jsCode = @"window.webkit.messageHandlers.playMovie.postMessage(window.location.href);";
//        [self.webView evaluateJavaScript:playCode completionHandler:^(id _Nullable res, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"%@",error);
//            }
//        }];
        
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.hidden = NO;
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    NSString *sizeJs = @"";
//    [webView evaluateJavaScript:sizeJs completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        
//    }];
    self.progressView.hidden = YES;
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"http://v.qq.com/iframe/txp/player.html?"]) {
        // 截获视频地址
        self.movieUrl = navigationAction.request.URL.absoluteString;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)createSubviews {
    
    WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
    configuretion.preferences = [[WKPreferences alloc]init];
    configuretion.preferences.minimumFontSize = 10;
    
    configuretion.processPool = [[WKProcessPool alloc]init];
    configuretion.userContentController = [[WKUserContentController alloc] init];
    // 添加js调用原生的接口 //js端代码 window.webkit.messageHandlers.<CustomName>.postMessage(<如果有参数传递在这里添加>)
    [configuretion.userContentController addScriptMessageHandler:self name:@"playMovie"];
    [configuretion.userContentController addScriptMessageHandler:self name:@"jsFunction"];
    // 注入js代码
    NSString *jsCode = @"var obj = document.getElementById('video_container'); obj.onclick = function(){ window.webkit.messageHandlers.playMovie.postMessage('play');};";
    WKUserScript *js = [[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [configuretion.userContentController addUserScript:js];
    
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.width, self.view.height - 44) configuration:configuretion];
    self.webView.navigationDelegate = self;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 0)];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor whiteColor];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];
    
    
    NSString *urlStr = nil;
    if (self.cellModel) {
        urlStr = self.cellModel.article_url;
    }else if (self.vendorModel) {
        urlStr = self.vendorModel.article_url;
    }else{
        urlStr = self.cellModel.article_url;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self.webView loadRequest:request];
}

- (void)settingNavigationBar {
    [self.view insertSubview:self.customNaviBar aboveSubview:self.webView];
    self.customNaviItem.title = @"资讯详情";
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_for_seven"] forBarMetrics:UIBarMetricsDefault];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    // 移除js对自身的强引用解除循环引用
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"playMovie"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"jsFunction"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSNumber *pro = change[NSKeyValueChangeNewKey];
        [self.progressView setProgress:pro.floatValue animated:YES];
    }
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
