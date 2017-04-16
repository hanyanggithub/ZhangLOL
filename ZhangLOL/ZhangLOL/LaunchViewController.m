//
//  LaunchViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/16.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LaunchViewController.h"


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
    NSString *path = [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGFloat deviceHeight = 0;
    if (image == nil) {
        // 获取开机图片
        if (IPHONE_4) {
            image = [UIImage imageNamed:@"LaunchImage-700@2x"];
            deviceHeight = IPHONE_4;
        }else if (IPHONE_5) {
            image = [UIImage imageNamed:@"LaunchImage-568h@2x"];
            deviceHeight = IPHONE_5;
        }else if (IPHONE_6) {
            image = [UIImage imageNamed:@"LaunchImage-800-667h@2x"];
            deviceHeight = IPHONE_6;
        }else if (IPHONE_6P) {
            image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h@3x"];
            deviceHeight = IPHONE_6P;
        }else{
            deviceHeight = IPHONE_6;
        }
        self.launchImageInfo = @{@"isOriginImage":@(1),@"image":image};
    }else{
        self.launchImageInfo = @{@"isOriginImage":@(0),@"image":image};
    }
    self.launchImageView.image = image;
    // 远端获取最新开机图
    [self requestNewstLaunchImageWithDeviceHeight:deviceHeight];
}
- (void)requestNewstLaunchImageWithDeviceHeight:(CGFloat)height {
    
}

- (void)judgeLoginState {
    NSString *token = [USER_DEFAULTS stringForKey:QQ_TOKEN_KEY];

    if (token) {
        self.oAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
        self.oAuth.accessToken = token;
        self.oAuth.openId = [USER_DEFAULTS stringForKey:QQ_OPENID_KEY];
        self.oAuth.expirationDate = [USER_DEFAULTS objectForKey:QQ_TOKEN_EXDATE_KEY];
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
    // 获取用户信息的回调
    NSLog(@"%@",response.message);
    //    NSLog(@"%@",response.jsonResponse);
    // 处理信息返回
    if ([self.delegate respondsToSelector:@selector(LaunchViewControllerJudgeLoginStateSucceed:)]) {
        [self.delegate LaunchViewControllerJudgeLoginStateSucceed:response.jsonResponse];
    }
}


@end
