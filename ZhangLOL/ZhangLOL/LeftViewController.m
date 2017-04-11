//
//  LeftViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UITableView *tableView;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.85, SCREEN_HEIGHT)];
    self.bgImageView.image = [UIImage imageNamed:@"left_bg"];
    [self.view addSubview:self.bgImageView];
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
