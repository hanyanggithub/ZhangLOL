//
//  BaseViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UINavigationControllerDelegate>
@property(nonatomic, strong)UIButton *menuButton;
@property(nonatomic, strong)UIView *unLoginView;
@property(nonatomic, strong)UILabel *unDevelopLabel;
@property(nonatomic, strong)UIView *errorView;
@property(nonatomic, strong)UIView *shadeView;
@property(nonatomic, weak)UIView *priorVCShadeView;
@property(nonatomic, weak)UIView *tabBarVCShadeView;
@end

@implementation BaseViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:loginSuccessNotificationName object:nil];
        extern NSString * const logoutNotificationName;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:logoutNotificationName object:nil];
    }
    return self;
}
- (void)logoutSuccess {
    self.isLogin = NO;
    if (self.menuButton) {
        [self.menuButton setBackgroundImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] forState:UIControlStateNormal];
    }
    if (([self isKindOfClass:NSClassFromString(@"FriendViewController")] || [self isKindOfClass:NSClassFromString(@"DiscoverViewController")] ||[self isKindOfClass:NSClassFromString(@"MeViewController")])) {
        [self removeUnDevelopView];
        [self showUnloginView];
    }
}
- (void)loginSuccess:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    self.isLogin = YES;
    if (self.menuButton) {
        NSURL *url = [NSURL URLWithString:userInfo[@"figureurl_qq_1"]];
        [self.menuButton sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
    }
    if (([self isKindOfClass:NSClassFromString(@"FriendViewController")] || [self isKindOfClass:NSClassFromString(@"DiscoverViewController")] ||[self isKindOfClass:NSClassFromString(@"MeViewController")])) {
        [self removeUnloginView];
        [self showUnDevelopView];
    }
    
}
- (void)setEnableFullScreenPop:(BOOL)enableFullScreenPop {
    if (enableFullScreenPop) {
        // 全屏滑动返回
        __weak id systemTarget = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer *popPan = [[UIPanGestureRecognizer alloc] initWithTarget:systemTarget action:NSSelectorFromString(@"handleNavigationTransition:")];
        [popPan addTarget:self action:@selector(handlePanGestureRecognizer:)];
        [self.view addGestureRecognizer:popPan];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    CGPoint displacement = [panGesture translationInView:panGesture.view];
    CGFloat offset_x = displacement.x;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        // 手势开始获取栈顶控制器视图的遮罩视图和标签栏遮罩视图
        NSLog(@"%f",[panGesture velocityInView:panGesture.view].x);
        BaseViewController *priorVC = (BaseViewController *)[self.navigationController topViewController];
        self.priorVCShadeView = priorVC.shadeView;
        self.tabBarVCShadeView = [self.tabBarController valueForKey:@"shadeView"];
        if (self.priorVCShadeView) {
            self.priorVCShadeView.hidden = NO;
        }
        if (self.tabBarVCShadeView) {
            self.tabBarVCShadeView.hidden = NO;
        }
    }else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat alpha = 1 - offset_x / self.view.width;
        if (self.priorVCShadeView) {
            self.priorVCShadeView.alpha = alpha;
        }
        if (self.tabBarVCShadeView) {
            self.tabBarVCShadeView.alpha = alpha;
        }
    }else{
        if (offset_x > self.view.width * 0.5) {
            if (self.priorVCShadeView) {
                self.priorVCShadeView.hidden = YES;
            }
            if (self.tabBarVCShadeView) {
                self.tabBarVCShadeView.hidden = YES;
            }
        }else{
            CGFloat velocity_x = [panGesture velocityInView:panGesture.view].x;
            if (velocity_x > 500) {
                if (self.priorVCShadeView) {
                    self.priorVCShadeView.hidden = YES;
                }
                if (self.tabBarVCShadeView) {
                    self.tabBarVCShadeView.hidden = YES;
                }
            }
        }
    }
}
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController != self && self.revealViewController.panGestureRecognizer.enabled) {
        // 禁用侧滑
        self.revealViewController.panGestureRecognizer.enabled = NO;
    }
    // (self.revealViewController.panGestureRecognizer.enabled)添加侧滑
    if (viewController == self && !self.revealViewController.panGestureRecognizer.enabled) {
        // 开启侧滑
        self.revealViewController.panGestureRecognizer.enabled = YES;
    }
    
    if (self.priorVCShadeView) {
        self.priorVCShadeView.hidden = YES;
    }
    if (self.tabBarVCShadeView) {
        self.tabBarVCShadeView.hidden = YES;
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view addSubview:self.shadeView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.shadeView.userInteractionEnabled = NO;
    self.shadeView.hidden = YES;
    // 初始化登录态
    NSDictionary *userInfo = APP_DELEGATE.userInfo;
    if (userInfo) {
        self.isLogin = YES;
    }else{
        self.isLogin = NO;
    }
    
    // 导航栏处理
    if (self.navigationController) {
        // 设置状态栏字体
        self.navigationController.delegate = self;
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        self.navigationController.navigationBar.hidden = YES;
        // 自定义导航栏
        self.customNaviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        [self.view addSubview:self.customNaviBar];
        // 自定义导航item
        self.customNaviItem = [[UINavigationItem alloc] init];
        self.customNaviBar.items = [NSArray arrayWithObject:self.customNaviItem];
        [self.customNaviBar setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_COLOR,NSFontAttributeName:[UIFont systemFontOfSize:NAVI_TITLE_FONT_SIZE]}];
        [self.customNaviBar setShadowImage:[UIImage new]];
    }
}
- (void)setIsLogin:(BOOL)isLogin {
    if (_isLogin != isLogin) {
        _isLogin = isLogin;
    }
}

- (void)setHaveMenuButton:(BOOL)haveMenuButton {
    if (haveMenuButton) {
        [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_for_seven"] forBarMetrics:UIBarMetricsDefault];
        // 添加item
        self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.menuButton.frame = CGRectMake(0, 0, 36, 36);
        self.menuButton.layer.cornerRadius = 18;
        self.menuButton.layer.masksToBounds = YES;
        self.menuButton.layer.borderWidth = 1;
        self.menuButton.layer.borderColor = MAIN_COLOR.CGColor;
        NSDictionary *userInfo = APP_DELEGATE.userInfo;
        if (userInfo) {
            NSURL *url = [NSURL URLWithString:userInfo[@"figureurl_qq_1"]];
            [self.menuButton sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
        }else{
            [self.menuButton setBackgroundImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] forState:UIControlStateNormal];
        }
        [self.menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        self.customNaviItem.leftBarButtonItem = leftItem;
    }else{
        [self.menuButton removeFromSuperview];
    }
}

- (void)menuButtonClicked {
    SWRevealViewController *sw = [self revealViewController];
    [sw revealToggleAnimated:YES];
}

- (void)setHaveBackButton:(BOOL)haveBackButton {
    if (haveBackButton) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 22, 40);
        [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny_normal"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny__pressed"] forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.customNaviItem.leftBarButtonItem = leftItem;
    }else{
        [self.customNaviItem.leftBarButtonItem.customView removeFromSuperview];
    }
}
- (void)pop {
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    BaseViewController *priorVC = [self.navigationController.viewControllers objectAtIndex:index - 1];
    if (!priorVC.shadeView.hidden) {
        priorVC.shadeView.hidden = YES;
    }
    UIView *tabShadeView = [self.tabBarController valueForKey:@"shadeView"];
    if (!tabShadeView.hidden) {
        tabShadeView.hidden = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToLogin {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored"-Warc-performSelector-leaks"
    [APP_DELEGATE performSelector:NSSelectorFromString(@"installLaunchModules") withObject:nil];
    #pragma clang diagnostic pop
}
- (void)showUnloginView {
    if (self.unLoginView == nil) {
        self.unLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVI_STATUS_BAR_HEIGHT, self.view.width, SCREEN_HEIGHT - NAVI_STATUS_BAR_HEIGHT - TABBAR_HEIGHT)];
        [self.view addSubview:self.unLoginView];
        
        UIImageView * imageView = [[UIImageView alloc] init];
        [self.unLoginView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16];
        if ([self isMemberOfClass:NSClassFromString(@"FriendViewController")]) {
            imageView.image = [UIImage imageNamed:@"tourists_friend"];
            label.text = @"登录后，可以看到你的游戏好友以及他们的游戏在线状态，还可以和Ta聊天哦！";
        }else if ([self isMemberOfClass:NSClassFromString(@"DiscoverViewController")]) {
            imageView.image = [UIImage imageNamed:@"tourists_location"];
            label.text = @"登录后，可以看到英雄资料以及你所拥有的英雄，还可以参与趣味问答哦！";
        }else if ([self isMemberOfClass:NSClassFromString(@"MeViewController")]) {
            imageView.image = [UIImage imageNamed:@"tourists_person"];
            label.text = @"登录后，可以看到自己的战绩、游戏资料以能力模型哦！";
        }
        [self.unLoginView addSubview:label];
        CGSize labelSize = [label sizeThatFits:CGSizeMake(self.unLoginView.width * 0.6, 0)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button setTintColor:[UIColor whiteColor]];
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        UIImage *colorImage = [UIImage imageNamed:@"update_yes_pressed"];
        UIColor *color = [ImageBlur getImagePixelColorWithPoint:colorImage point:CGPointMake(10, 5)];
        button.backgroundColor = color;
        [button addTarget:self action:@selector(goToLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.unLoginView addSubview:button];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.unLoginView).offset(20);
            make.width.equalTo(@(self.unLoginView.width * 0.6));
            make.centerX.equalTo(self.unLoginView);
            make.height.equalTo(@(self.unLoginView.width * 0.6 * 490/450));
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom);
            make.width.equalTo(@(labelSize.width));
            make.centerX.equalTo(imageView);
            make.height.equalTo(@(labelSize.height));
        }];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(10);
            make.width.equalTo(@(labelSize.width));
            make.centerX.equalTo(label);
            make.height.equalTo(@(40));
        }];
    }
}
- (void)removeUnloginView {
    if (self.unLoginView) {
        [self.unLoginView removeFromSuperview];
        self.unLoginView = nil;
    }
}
- (void)showUnDevelopView {
    if (self.unDevelopLabel == nil) {
        self.unDevelopLabel = [[UILabel alloc] init];
        self.unDevelopLabel.text = @"当前模块暂未开发";
        self.unDevelopLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.unDevelopLabel];
        
        [self.unDevelopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.height.equalTo(@(20));
        }];
    }
}
- (void)removeUnDevelopView {
    if (self.unDevelopLabel) {
        [self.unDevelopLabel removeFromSuperview];
        self.unDevelopLabel = nil;
    }
}
- (void)showErrorViewWithMessage:(NSString *)errorMessage {
    if (self.errorView == nil) {
        self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVI_STATUS_BAR_HEIGHT, self.view.width, SCREEN_HEIGHT - NAVI_STATUS_BAR_HEIGHT - TABBAR_HEIGHT)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorViewTapAction)];
        [self.errorView addGestureRecognizer:tap];
        [self.view addSubview:self.errorView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_empty"]];
        [self.errorView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        label.text = errorMessage;
        [self.errorView addSubview:label];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.errorView);
            make.width.equalTo(@(self.errorView.width * 0.25));
            make.centerX.equalTo(self.errorView);
            make.height.equalTo(@(self.errorView.height * 0.25));
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom);
            make.width.equalTo(self.errorView);
            make.centerX.equalTo(imageView);
            make.height.equalTo(@(20));
        }];
    }
}
- (void)removeErrorView {
    if (self.errorView) {
        [self.errorView removeFromSuperview];
        self.errorView = nil;
    }
}
- (void)errorViewTapAction {
    
}

@end
