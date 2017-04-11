//
//  TabBarController.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "TabBarController.h"
#import "BaseNavigationController.h"
#import "MessageViewController.h"
#import "FriendViewController.h"
#import "DiscoverViewController.h"
#import "MeViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    BaseNavigationController *messgeNavi = [[BaseNavigationController alloc] initWithRootViewController:[[MessageViewController alloc] init]];
    messgeNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"资讯" image:[[UIImage imageNamed:@"tab_icon_news_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_news_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    BaseNavigationController *friendNavi = [[BaseNavigationController alloc] initWithRootViewController:[[FriendViewController alloc] init]];
    friendNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好友" image:[[UIImage imageNamed:@"tab_icon_friend_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_friend_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    BaseNavigationController *discoverNavi = [[BaseNavigationController alloc] initWithRootViewController:[[DiscoverViewController alloc] init]];
    discoverNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[[UIImage imageNamed:@"tab_icon_quiz_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_quiz_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    BaseNavigationController *meNavi = [[BaseNavigationController alloc] initWithRootViewController:[[MeViewController alloc] init]];
    meNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:[[UIImage imageNamed:@"tab_icon_more_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_more_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.viewControllers = @[messgeNavi,friendNavi,discoverNavi,meNavi];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_COLOR} forState:UIControlStateSelected];
    self.tabBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
