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

@interface AppDelegate ()<LaunchViewControllerDelegate,LoginViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    LaunchViewController *launchViewController = [[LaunchViewController alloc] init];
    launchViewController.delegate = self;
    UINavigationController *launchNavi = [[UINavigationController alloc] initWithRootViewController:launchViewController];
    _window.rootViewController = launchNavi;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)installContentModules {
    TabBarController *tabBarContr = [[TabBarController alloc] init];
    LeftViewController *left = [[LeftViewController alloc] init];
    left.userInfo = self.userInfo;
    SWRevealViewController *drawer = [[SWRevealViewController alloc] initWithRearViewController:left frontViewController:tabBarContr];
    drawer.rearViewRevealWidth = LEFT_VIEW_WIDTH;
    drawer.bounceBackOnOverdraw = NO;
    drawer.rearViewRevealOverdraw = 0;
    drawer.toggleAnimationType = SWRevealToggleAnimationTypeSpring;
    drawer.springDampingRatio = 0.8;
    self.window.rootViewController = drawer;
}
- (void)LaunchViewControllerJudgeLoginStateSucceed:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
    [self installContentModules];
}

- (void)LoginViewControllerTouristPreview:(LoginViewController *)loginViewController {
    [self installContentModules];
}

// 8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if ([TencentOAuth CanHandleOpenURL:url]) {
       return [TencentOAuth  HandleOpenURL:url];
    }
    return NO;
}
// 9 10
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth  HandleOpenURL:url];
    }
    return NO;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSLog(@"已经结束启动");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"将要失去活跃状态");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"已经进入后台");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"将要进入后台");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"将要变的活跃");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"将要退出");
}


@end
