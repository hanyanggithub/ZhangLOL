//
//  LoginViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property(nonatomic, strong)UIControl *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginBtn = [[UIControl alloc] init];
    [self.loginBtn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClicked {
    NSLog(@"登录");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
