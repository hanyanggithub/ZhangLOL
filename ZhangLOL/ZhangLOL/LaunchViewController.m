//
//  LaunchViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/16.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LaunchViewController.h"

NSString * const userInfoTableName = @"userInfoTableName";

@interface LaunchViewController ()<TencentSessionDelegate>
@property(nonatomic, strong)UIImageView *launchImageView;
@property(nonatomic, strong)NSDictionary *launchImageInfo;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.launchImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.launchImageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.launchImageView];
    [self getLaunchImage];
    [self judgeLoginState];
}
- (void)getLaunchImage {
    // 沙盒中获取图片
    NSString *pathLaunch = [NSString stringWithFormat:@"%@/Documents/launch.png",NSHomeDirectory()];
    NSString *pathLogin = [NSString stringWithFormat:@"%@/Documents/login.png",NSHomeDirectory()];
    UIImage *imageLaunch = [UIImage imageWithContentsOfFile:pathLaunch];
    UIImage *imageLogin = [UIImage imageWithContentsOfFile:pathLogin];
    if (imageLaunch == nil) {
        // 获取开机图片
        if (IPHONE_4) {
            imageLaunch = [UIImage imageNamed:@"LaunchImage-700@2x"];
    
        }else if (IPHONE_5) {
            imageLaunch = [UIImage imageNamed:@"LaunchImage-700-568h@2x"];
    
        }else if (IPHONE_6) {
            imageLaunch = [UIImage imageNamed:@"LaunchImage-800-667h@2x"];
    
        }else if (IPHONE_6P) {
            imageLaunch = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h@3x"];
    
        }else{
            imageLaunch = [UIImage imageNamed:@"LaunchImage-800-667h@2x"];
        }
        self.launchImageInfo = @{@"isOriginImage":@(1),@"image":imageLaunch};
    }else{
        if (imageLogin) {
            self.launchImageInfo = @{@"isOriginImage":@(0),@"image":imageLogin};
        }
    }
    self.launchImageView.image = imageLaunch;
}

- (void)judgeLoginState {
    NSString *token = [USER_DEFAULTS stringForKey:QQ_TOKEN_KEY];

    if (token) {
        self.oAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
        self.oAuth.accessToken = token;
        self.oAuth.openId = [USER_DEFAULTS stringForKey:QQ_OPENID_KEY];
        self.oAuth.expirationDate = [USER_DEFAULTS objectForKey:QQ_TOKEN_EXDATE_KEY];
        NSDictionary *userInfo = [USER_DEFAULTS objectForKey:QQ_USERINFO_KEY];;
        if (userInfo) {
            if ([self.delegate respondsToSelector:@selector(launchViewControllerJudgeLoginStateSucceed:userInfo:)]) {
                [self.delegate launchViewControllerJudgeLoginStateSucceed:self userInfo:userInfo];
            }
        }else{
            [SVProgressHUD show];
        }
        // 获取用户信息
        [self.oAuth getUserInfo];
    }else{
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        loginViewController.isOriginImage = [self.launchImageInfo[@"isOriginImage"] boolValue];
        loginViewController.bgImage = self.launchImageInfo[@"image"];
        loginViewController.delegate = (id<LoginViewControllerDelegate>)self.delegate;
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
}
#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
}
- (void)tencentDidNotLogin:(BOOL)cancelled {
}
- (void)tencentDidNotNetWork {
}
#pragma mark - TencentSessionDelegate
- (void)getUserInfoResponse:(APIResponse *)response {
    // 处理信息返回
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismissWithDelay:0.5];
    }
    if ([self.delegate respondsToSelector:@selector(launchViewControllerJudgeLoginStateSucceed:userInfo:)]) {
        [USER_DEFAULTS setObject:response.jsonResponse forKey:QQ_USERINFO_KEY];
        [self.delegate launchViewControllerJudgeLoginStateSucceed:self userInfo:response.jsonResponse];
    }
}


@end
