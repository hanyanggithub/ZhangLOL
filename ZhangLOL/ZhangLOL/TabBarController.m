//
//  TabBarController.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "TabBarController.h"
#import "MessageViewController.h"
#import "FriendViewController.h"
#import "DiscoverViewController.h"
#import "MeViewController.h"

@interface TabBarController ()<SWRevealViewControllerDelegate>

@property(nonatomic, strong)UIView *shadeView;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    MessageViewController *message = [[MessageViewController alloc] init];
    message.hidesBottomBarWhenPushed = NO;
    UINavigationController *messgeNavi = [[UINavigationController alloc] initWithRootViewController:message];
    messgeNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"资讯" image:[[UIImage imageNamed:@"tab_icon_news_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_news_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    FriendViewController *friend = [[FriendViewController alloc] init];
    friend.hidesBottomBarWhenPushed = NO;
    UINavigationController *friendNavi = [[UINavigationController alloc] initWithRootViewController:friend];
    friendNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好友" image:[[UIImage imageNamed:@"tab_icon_friend_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_friend_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    DiscoverViewController *discover = [[DiscoverViewController alloc] init];
    discover.hidesBottomBarWhenPushed = NO;
    UINavigationController *discoverNavi = [[UINavigationController alloc] initWithRootViewController:discover];
    discoverNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[[UIImage imageNamed:@"tab_icon_quiz_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_quiz_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    MeViewController *me = [[MeViewController alloc] init];
    me.hidesBottomBarWhenPushed = NO;
    UINavigationController *meNavi = [[UINavigationController alloc] initWithRootViewController:me];
    meNavi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:[[UIImage imageNamed:@"tab_icon_more_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_icon_more_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.viewControllers = @[messgeNavi,friendNavi,discoverNavi,meNavi];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_COLOR} forState:UIControlStateSelected];
    self.tabBar.translucent = NO;
    
    self.shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tabBar.height)];
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.shadeView.hidden = YES;
    self.shadeView.userInteractionEnabled = NO;
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tabBar addSubview:self.shadeView];
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        // 开启滑动交互
        self.view.userInteractionEnabled = YES;
    }else if (position == FrontViewPositionRight) {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        revealController.toggleAnimationType = SWRevealToggleAnimationTypeSpring;
    }
    if (position == FrontViewPositionRight) {
        revealController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
    }
    
}
@end
