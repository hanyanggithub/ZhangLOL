//
//  LoginViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LoginViewController.h"
#import "UIImage+animatedGIF.h"

@interface LoginViewController ()<TencentSessionDelegate>

@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIView *originBg;

@property(nonatomic, strong)UIImageView *loginAnimationView;
@property(nonatomic, strong)UIImageView *loginBtnLogo;

@property(nonatomic, strong)UIImageView *touristBtnArrow;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubviews];
}
- (void)createSubviews {
    
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgImageView.userInteractionEnabled = YES;
    self.bgImageView.image = self.bgImage;
    [self.view addSubview:self.bgImageView];
    
    if (self.isOriginImage) {
        self.originBg = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height * 0.75, self.view.width, self.view.height * 0.25)];
        self.originBg.backgroundColor = [ImageBlur getImagePixelColorWithPoint:self.bgImage point:self.originBg.center];
        [self.bgImageView addSubview:self.originBg];
    }
    
    UIControl *loginBtn = [[UIControl alloc] init];
    [loginBtn addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn addTarget:self action:@selector(loginBtnTouchDown) forControlEvents:UIControlEventTouchDown];
    [loginBtn addTarget:self action:@selector(loginBtnTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.bgImageView addSubview:loginBtn];
    
    
    self.loginAnimationView = [[UIImageView alloc] init];
    self.loginAnimationView.backgroundColor = [UIColor clearColor];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"login_quick_btn_normal" ofType:@"gif"];
    UIImage *images = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfFile:path]];
    self.loginAnimationView.image = images;
    self.loginAnimationView.highlightedImage = [UIImage imageNamed:@"login_quick_btn_press"];
    [loginBtn addSubview:self.loginAnimationView];
    
    UIView *containView = [[UIView alloc] init];
    containView.userInteractionEnabled = NO;
    [loginBtn addSubview:containView];
    
    self.loginBtnLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_btn_qq_icon_normal"] highlightedImage:[UIImage imageNamed:@"login_btn_qq_icon_press"]];
    [containView addSubview:self.loginBtnLogo];
    
    UILabel *loginBtnTitle = [[UILabel alloc] init];
    loginBtnTitle.textAlignment = NSTextAlignmentCenter;
    loginBtnTitle.text = @"QQ登录";
    loginBtnTitle.font = [UIFont systemFontOfSize:18];
    CGSize sizeLoginBtnTitle = [loginBtnTitle sizeThatFits:CGSizeZero];
    loginBtnTitle.textColor = MAIN_COLOR;
    [containView addSubview:loginBtnTitle];
    
    
    
    UIControl *touristBtn = [[UIControl alloc] init];
    [touristBtn addTarget:self action:@selector(touristBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [touristBtn addTarget:self action:@selector(touristBtnTouchDown) forControlEvents:UIControlEventTouchDown];
    [touristBtn addTarget:self action:@selector(touristBtnTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.bgImageView addSubview:touristBtn];
    
    UILabel *touristBtnTitle = [[UILabel alloc] init];
    touristBtnTitle.text = @"游客进入";
    touristBtnTitle.font = [UIFont systemFontOfSize:16];
    CGSize sizeTouristBtnTitle = [touristBtnTitle sizeThatFits:CGSizeZero];
    touristBtnTitle.textColor = MAIN_COLOR;
    [touristBtn addSubview:touristBtnTitle];
    
    self.touristBtnArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_tourists_btn_arrow_normal"] highlightedImage:[UIImage imageNamed:@"login_tourists_btn_arrow_press"]];
    [touristBtn addSubview:self.touristBtnArrow];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgImageView).offset(60);
        make.right.equalTo(self.bgImageView).offset(-60);
        make.bottom.equalTo(self.bgImageView).offset(-80);
        make.height.equalTo(@(60));
    }];
    
    [self.loginAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginBtn);
        make.right.equalTo(loginBtn);
        make.bottom.equalTo(loginBtn);
        make.height.equalTo(loginBtn);
    }];
    
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loginBtn);
        make.centerY.equalTo(loginBtn);
        make.height.equalTo(@(sizeLoginBtnTitle.height));
        make.width.equalTo(@(sizeLoginBtnTitle.width+16));
    }];

    [self.loginBtnLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containView);
        make.width.equalTo(@(16));
        make.height.equalTo(@(16));
        make.centerY.equalTo(containView);
    }];

    [loginBtnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginBtnLogo.mas_right);
        make.right.equalTo(containView);
        make.height.equalTo(containView);
        make.centerY.equalTo(containView);
    }];

    [touristBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(loginBtn.mas_bottom).offset(20);
        make.centerX.equalTo(loginBtn);
        make.height.equalTo(@(sizeTouristBtnTitle.height));
        make.width.equalTo(@(sizeTouristBtnTitle.width+5));
    }];
    
    [touristBtnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(touristBtn);
        make.top.equalTo(touristBtn);
        make.height.equalTo(touristBtn);
        make.width.equalTo(@(sizeTouristBtnTitle.width));
    }];
    
    [self.touristBtnArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(touristBtnTitle.mas_right);
        make.height.equalTo(@(8));
        make.width.equalTo(@(5));
        make.centerY.equalTo(touristBtn);
    }];
}
// 游客按钮点击
- (void)touristBtnClicked {
    self.touristBtnArrow.highlighted = NO;
    if ([self.delegate respondsToSelector:@selector(LoginViewControllerTouristPreview:)]) {
        [self.delegate LoginViewControllerTouristPreview:self];
    }
}
// 游客按钮按下
- (void)touristBtnTouchDown{
    self.touristBtnArrow.highlighted = YES;
}
// 游客按钮按下外抬起
- (void)touristBtnTouchUpOutside {
    self.touristBtnArrow.highlighted = NO;
}
// 按下登录按钮
- (void)loginBtnTouchDown {
    self.loginBtnLogo.highlighted = YES;
    self.loginAnimationView.highlighted = YES;
}
// 按钮从外抬起
- (void)loginBtnTouchUpOutside {
    self.loginBtnLogo.highlighted = NO;
    self.loginAnimationView.highlighted = NO;
}
// 点击登录
- (void)loginBtnClicked {
    self.loginBtnLogo.highlighted = NO;
    self.loginAnimationView.highlighted = NO;
    self.oAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
    NSArray *array = @[kOPEN_PERMISSION_GET_USER_INFO,
                       kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                       kOPEN_PERMISSION_GET_INFO,
                       kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                       kOPEN_PERMISSION_GET_VIP_INFO,
                       kOPEN_PERMISSION_GET_OTHER_INFO,
                       kOPEN_PERMISSION_ADD_TOPIC,
                       kOPEN_PERMISSION_ADD_ONE_BLOG,
                       kOPEN_PERMISSION_ADD_ALBUM,
                       kOPEN_PERMISSION_UPLOAD_PIC,
                       kOPEN_PERMISSION_LIST_ALBUM,
                       kOPEN_PERMISSION_ADD_SHARE,
                       kOPEN_PERMISSION_CHECK_PAGE_FANS];
    [self.oAuth authorize:array];
}
#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
    // 登录完成
    [USER_DEFAULTS setObject:self.oAuth.accessToken forKey:QQ_TOKEN_KEY];
    [USER_DEFAULTS setObject:self.oAuth.expirationDate forKey:QQ_TOKEN_EXDATE_KEY];
    [USER_DEFAULTS setObject:self.oAuth.openId forKey:QQ_OPENID_KEY];
    self.oAuth.sessionDelegate = self.navigationController.viewControllers[0];
    // 获取用户信息
    [self.oAuth getUserInfo];
}
- (void)tencentDidNotLogin:(BOOL)cancelled {
    // 用户取消登录
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"登录未完成" message:@"不登录是无法使用一些功能的哦" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)tencentDidNotNetWork {
    // 网络有问题
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"登录失败" message:@"请检查您的网络" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - TencentSessionDelegate
- (void)getUserInfoResponse:(APIResponse*) response {
}



@end
