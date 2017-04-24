//
//  AppDelegate.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "TabBarController.h"
#import "LaunchViewController.h"

#define LEFT_VIEW_WIDTH (SCREEN_WIDTH * 0.8)
NSString * const loginSuccessNotificationName = @"LoginSuccessNotificationName";

@interface AppDelegate ()<LaunchViewControllerDelegate,LoginViewControllerDelegate,LeftViewControllerDelegate>

@property(nonatomic, strong)SWRevealViewController *drawer;
@property(nonatomic, strong)UINavigationController *launchNavi;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 开启网络状态监控
    [ZhangLOLNetwork startMonitoring];
    // 下载开机图和启动图
    [ImageBlur downloadLaunchImageIsForce:NO];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [self installLaunchModules];
    [_window makeKeyAndVisible];
    return YES;
}

- (void)installLaunchModules {
    if (self.launchNavi == nil) {
        LaunchViewController *launchViewController = [[LaunchViewController alloc] init];
        launchViewController.delegate = self;
        self.launchNavi = [[UINavigationController alloc] initWithRootViewController:launchViewController];
    }
    self.window.rootViewController = self.launchNavi;
}

- (void)installContentModules {
    if (self.drawer == nil) {
        TabBarController *tabBarContr = [[TabBarController alloc] init];
        LeftViewController *left = [[LeftViewController alloc] init];
        left.delegate = self;
        left.userInfo = self.userInfo;
        self.drawer = [[SWRevealViewController alloc] initWithRearViewController:left frontViewController:tabBarContr];
        self.drawer.rearViewRevealWidth = LEFT_VIEW_WIDTH;
        self.drawer.bounceBackOnOverdraw = NO;
        self.drawer.bounceBackOnLeftOverdraw = NO;
        self.drawer.rearViewRevealOverdraw = 0;
        self.drawer.springDampingRatio = 0.8;
        self.drawer.delegate = (id<SWRevealViewControllerDelegate>)tabBarContr;
    }
    if (self.drawer.frontViewPosition == FrontViewPositionRight) {
        [self.drawer revealToggleAnimated:NO];
    }
    self.window.rootViewController = self.drawer;
    self.launchNavi = nil;
}
- (void)launchViewControllerJudgeLoginStateSucceed:(LaunchViewController *)launchViewController userInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
    // 发送登录成功的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNotificationName object:nil userInfo:self.userInfo];
    // 显示内容模块
    [self installContentModules];
}

- (void)loginViewControllerTouristPreview:(LoginViewController *)loginViewController {
    // 显示内容模块
    [self installContentModules];
}

- (void)leftViewControllerLoginBtnClicked {
    // 显示启动登录模块
    [self installLaunchModules];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if ([TencentOAuth CanHandleOpenURL:url]) {
       return [TencentOAuth  HandleOpenURL:url];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth  HandleOpenURL:url];
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
