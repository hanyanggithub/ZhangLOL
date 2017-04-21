//
//  BaseViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.navigationBar) {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        self.navigationController.navigationBar.hidden = YES;
        self.customNaviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        [self.view addSubview:self.customNaviBar];
        self.customNaviItem = [[UINavigationItem alloc] init];
        self.customNaviBar.items = [NSArray arrayWithObject:self.customNaviItem];
        [self.customNaviBar setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_COLOR,NSFontAttributeName:[UIFont systemFontOfSize:NAVI_TITLE_FONT_SIZE]}];
        [self.customNaviBar setShadowImage:[UIImage new]];
    }
}

- (void)pop{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
