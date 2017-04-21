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
#import <ZFPlayer.h>

@interface MessgeDetailController ()<UIGestureRecognizerDelegate,ZFPlayerDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic, strong)WKWebView *webView;
@property(nonatomic, strong)ZFPlayerView *playerView;
@property(nonatomic, copy)NSString *movieUrl;
@end

@implementation MessgeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubviews];
    [self settingNavigationBar];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",message.body);
    if ([message.name isEqualToString:@"jsFunction"]) {
        return ;
    }
    
    if ([message.name isEqualToString:@"playMovie"]) {
        // 播放
//        NSString *playCode= @"LOL_QT_Video.openUrl('http://qt.qq.com/?reqApp=&type=VIDEO_PLAY&vData=\"videoObj.msg.vid\"&vType=VOD&dType=VOD&ivideoid=\"LOL_QT_Video.VideoId\"&time=\"videoObj.msg.time');";
//        
//  
//        NSString *jsCode = @" $('#todoPlay').attr('href',\"javascript:LOL_QT_Video.LOL_Play_Video(\"+LOL_QT_Video.VideoId+\",'\"+videoObj.msg.vid+\"','//qt.qq.com/?reqApp=|type=VIDEO_PLAY|vData=\"+videoObj.msg.vid+\"|vType=VOD|dType=VOD|ivideoid=\"+self.VideoId+\"|time=\"+videoObj.msg.time+\"')\"); var iframe = document.getElementById('todoPlay');window.webkit.messageHandlers.jsFunction.postMessage(iframe.href);";
////        NSString *jsCode = @"window.webkit.messageHandlers.playMovie.postMessage(window.location.href);";
//        [self.webView evaluateJavaScript:playCode completionHandler:^(id _Nullable res, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"%@",error);
//            }
//        }];
        
        
//        ZFPlayerModel *playerModel = [[ZFPlayerModel alloc]init];
//        playerModel.fatherView = self.view;
//        playerModel.videoURL = [NSURL URLWithString:self.movieUrl];
//        playerModel.videoURL = [NSURL URLWithString:@"http://124.14.18.208/vhot2.qqvideo.tc.qq.com/x0394ou5zj0.p712.1.mp4?vkey=0539E668D6E43F28747A9FB7AD442E9FCC5A38201E42ECB06E457DEFFE30836A46DD1F50A324403DAE06FB8CE77CB07BCAB4A1CE2F7D63AC4EC8B23DBF3442819BB5A2B4FA4721F10946AFB0A3F8D5C747C35830554ABEFE&sha=&level=3&br=200&fmt=hd&sdtfrom=v3030&platform=280403&guid=79bcf3c73adb1035968380fbd48ad00a&locid=4682abb3-5d41-4674-8526-d5cbcf525ab6&size=12446414&ocid=2370966956"];
//        playerModel.videoURL = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14571455324031.mp4"];
//        playerModel.title = @"无标题";
//        [self.playerView playerControlView:nil playerModel:playerModel];
//        [self.playerView autoPlayTheVideo];
//        NSLog(@"点击iframe区域,but获取不到视频的源地址");
        
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"http://v.qq.com/iframe/txp/player.html?"]) {
        // 截获视频地址
        self.movieUrl = navigationAction.request.URL.absoluteString;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (ZFPlayerView *)playerView {
    if (_playerView == nil) {
        _playerView = [[ZFPlayerView alloc] init];
        [self.view addSubview:_playerView];
        
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.left.right.equalTo(self.view);
            // Here a 16:9 aspect ratio, can customize the video aspect ratio
            make.height.equalTo(_playerView.mas_width).multipliedBy(9.0f/16.0f);
        }];
        // delegate
        _playerView.delegate = self;
    }
    return _playerView;
}
/** 返回按钮事件 */
- (void)zf_playerBackAction {
    NSLog(@"返回");
    [self.playerView resetPlayer];
}
/** 下载视频 */
- (void)zf_playerDownload:(NSString *)url {
    NSLog(@"下载");
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
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];
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
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 22, 40);
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny_normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny__pressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.customNaviItem.leftBarButtonItem = leftItem;
    
    // 全屏滑动返回
    __weak id systemTarget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *popPan = [[UIPanGestureRecognizer alloc] initWithTarget:systemTarget action:NSSelectorFromString(@"handleNavigationTransition:")];
    [self.view addGestureRecognizer:popPan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
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

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}





@end
