//
//  BaseViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property(nonatomic, strong)UINavigationBar *customNaviBar;
@property(nonatomic, strong)UINavigationItem *customNaviItem;
@property(nonatomic, assign)BOOL haveMenuButton;       // 有无menu按钮
@property(nonatomic, assign)BOOL haveBackButton;       // 有无返回按钮
@property(nonatomic, assign)BOOL enableFullScreenPop; // 开启全屏滑动pop
@property(nonatomic, readonly)BOOL isLogin;            // 登录状态
// 转向登录模块
- (void)goToLogin;

// for LeftViewController
- (void)loginSuccess:(NSNotification *)notification;
- (void)logoutSuccess;

// 未登录视图
- (void)showUnloginView;
// 移除未登录视图
- (void)removeUnloginView;

- (void)showUnDevelopView;
- (void)removeUnDevelopView;


// 显示出错视图
- (void)showErrorViewWithMessage:(NSString *)errorMessage;
// 移除出错视图
- (void)removeErrorView;
// subMethod
- (void)errorViewTapAction;

@end
