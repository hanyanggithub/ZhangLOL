//
//  LaunchViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/16.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"

@class LaunchViewController;
@protocol LaunchViewControllerDelegate <NSObject>

- (void)launchViewControllerJudgeLoginStateSucceed:(LaunchViewController *)launchViewController userInfo:(NSDictionary *)userInfo;

@end

@interface LaunchViewController : BaseViewController
@property(nonatomic, weak)id<LaunchViewControllerDelegate>delegate;
@property(nonatomic, strong)TencentOAuth *oAuth;
@end
