//
//  LoginViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"
@class LoginViewController;
@protocol LoginViewControllerDelegate <NSObject>

- (void)LoginViewControllerTouristPreview:(LoginViewController *)loginViewController;

@end


@interface LoginViewController : BaseViewController

@property(nonatomic, strong)TencentOAuth *oAuth;
@property(nonatomic, assign)BOOL isOriginImage;
@property(nonatomic, strong)UIImage *bgImage;
@property(nonatomic, weak)id<LoginViewControllerDelegate>delegate;

@end
