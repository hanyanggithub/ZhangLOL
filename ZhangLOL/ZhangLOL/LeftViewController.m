//
//  LeftViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LeftViewController.h"

#define LEFT_VIEW_BOTTOM_CELL_TAG   2000

@interface LeftViewController ()

@property(nonatomic, strong)UIImageView *bgImageView;

@property(nonatomic, strong)UIImageView *userIcon;
@property(nonatomic, strong)UILabel *nikeName;
@property(nonatomic, strong)UIImageView *genderIcon;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubviews];
    
}
- (void)createSubviews {
    // bg
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.85, SCREEN_HEIGHT)];
    self.bgImageView.userInteractionEnabled = YES;
    self.bgImageView.image = [UIImage imageNamed:@"left_bg"];
    [self.view addSubview:self.bgImageView];
    
    if (self.userInfo) {
        // user
        UIView *userMessageView = [[UIView alloc] init];
        UITapGestureRecognizer *tapUserPart = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPartCliked)];
        [userMessageView addGestureRecognizer:tapUserPart];
        [self.bgImageView addSubview:userMessageView];
        
        self.userIcon = [[UIImageView alloc] init];
        self.userIcon.layer.borderWidth = 1;
        self.userIcon.layer.borderColor = MAIN_COLOR.CGColor;
        self.userIcon.layer.cornerRadius = 25;
        self.userIcon.layer.masksToBounds = YES;
        [self.userIcon sd_setImageWithURL:[NSURL URLWithString:self.userInfo[@"figureurl_qq_1"]] placeholderImage:[UIImage imageNamed:@"left_nologin"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
        [userMessageView addSubview:self.userIcon];
        
        self.nikeName = [[UILabel alloc] init];
        self.nikeName.textColor = [UIColor whiteColor];
        self.nikeName.text = self.userInfo[@"nickname"];
        self.nikeName.font = [UIFont systemFontOfSize:16];
        CGSize nikeNameSize = [self.nikeName sizeThatFits:CGSizeZero];
        [userMessageView addSubview:self.nikeName];
        
        self.genderIcon = [[UIImageView alloc] init];
        NSString *gender = self.userInfo[@"gender"];
        if ([gender isEqualToString:@"男"]) {
            self.genderIcon.image = [UIImage imageNamed:@"friend_gender_male_mark"];
        }else if ([gender isEqualToString:@"女"]) {
            self.genderIcon.image = [UIImage imageNamed:@"friend_gender_female_mark"];
        }else{
            self.genderIcon.image = [UIImage imageNamed:@""];
        }
        [userMessageView addSubview:self.genderIcon];
        
        [userMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgImageView).offset(20);
            make.top.equalTo(self.bgImageView).offset(60);
            make.height.equalTo(@(80));
            make.width.equalTo(@(80));
        }];
        
        [self.userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(userMessageView);
            make.top.equalTo(userMessageView);
            make.height.equalTo(@(50));
            make.width.equalTo(@(50));
        }];
        [self.nikeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userIcon);
            make.top.equalTo(self.userIcon.mas_bottom).offset(10);
            make.height.equalTo(@(20));
            make.width.equalTo(@(nikeNameSize.width));
        }];
        [self.genderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nikeName.mas_right).offset(5);
            make.centerY.equalTo(self.nikeName);
            make.height.equalTo(@(13));
            make.width.equalTo(@(13));
        }];

        
        // 名片
        UIView *bkContainerView = [[UIView alloc] init];
        UITapGestureRecognizer *tapBk = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bkPartCliked)];
        [bkContainerView addGestureRecognizer:tapBk];
        [self.bgImageView addSubview:bkContainerView];
        
        UIImageView *bkIcon = [[UIImageView alloc] init];
        bkIcon.image = [UIImage imageNamed:@"left_card"];
        bkIcon.highlightedImage = [UIImage imageNamed:@"left_card_hl"];
        [bkContainerView addSubview:bkIcon];
        
        UILabel *bkTitle = [[UILabel alloc] init];
        bkTitle.textColor = [UIColor whiteColor];
        bkTitle.font = [UIFont systemFontOfSize:12];
        bkTitle.textAlignment = NSTextAlignmentCenter;
        bkTitle.text = @"我的名片";
        [bkContainerView addSubview:bkTitle];
        
        [bkContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bgImageView).offset(-60);
            make.centerY.equalTo(self.userIcon);
            make.height.equalTo(@(40));
            make.width.equalTo(@(60));
        }];
        [bkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bkContainerView);
            make.top.equalTo(bkContainerView);
            make.height.equalTo(@(20));
            make.width.equalTo(@(32));
        }];
        [bkTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bkIcon.mas_bottom);
            make.centerX.equalTo(bkContainerView);
            make.height.equalTo(@(20));
            make.width.equalTo(bkContainerView);
        }];
    }else{
        // login
        UIButton *loginButton = [[UIButton alloc] init];
        loginButton.layer.cornerRadius = 10;
        loginButton.layer.borderWidth = 1;
        loginButton.layer.borderColor = MAIN_COLOR.CGColor;
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        loginButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [loginButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView addSubview:loginButton];
        
        UILabel *title = [[UILabel alloc] init];
        title.textColor = [UIColor grayColor];
        title.font = [UIFont systemFontOfSize:13];
        title.text = @"登录可查看完整内容";
        [self.bgImageView addSubview:title];
        
        [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgImageView).offset(20);
            make.top.equalTo(self.bgImageView).offset(100);
            make.height.equalTo(@(40));
            make.width.equalTo(@(100));
        }];
        
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(loginButton);
            make.top.equalTo(loginButton.mas_bottom).offset(5);
            make.height.equalTo(@(20));
            make.width.equalTo(@(150));
        }];
    }
    
    
    // bottom
    NSArray *imageNames = @[@"left_timeline",@"left_download",@"left_subscibe",@"left_collect",@"left_order"];
    NSArray *titles = @[@"我的动态",@"我的下载",@"我的订阅",@"我的收藏",@"我的订单"];
    for (int i = 0; i < 5; i++) {
        UIButton *bgButton = [[UIButton alloc] init];
        [bgButton setBackgroundImage:[UIImage imageNamed:@"progress_bg01"] forState:UIControlStateHighlighted];
        bgButton.tag = LEFT_VIEW_BOTTOM_CELL_TAG + i;
        [bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView addSubview:bgButton];
        
        UIImageView *icon = [[UIImageView alloc] init];
        icon.image = [UIImage imageNamed:imageNames[i]];
        [bgButton addSubview:icon];
        
        UILabel *title = [[UILabel alloc] init];
        title.text = titles[i];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont systemFontOfSize:18];
        [bgButton addSubview:title];
        
        [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImageView).offset(SCREEN_HEIGHT * 0.33 + i * 60);
            make.left.equalTo(self.bgImageView);
            make.right.equalTo(self.bgImageView);
            make.height.equalTo(@(60));
        }];
        
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgButton).offset(20);
            make.centerY.equalTo(bgButton);
            make.height.equalTo(@(20));
            make.width.equalTo(@(20));
        }];
        
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(icon.mas_right).offset(20);
            make.centerY.equalTo(bgButton);
            make.height.equalTo(@(30));
            make.right.equalTo(bgButton);
        }];
    }
    
    // 设置
    UIView *settingContainView = [[UIView alloc] init];
    UITapGestureRecognizer *settingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingClicked)];
    [settingContainView addGestureRecognizer:settingTap];
    [self.bgImageView addSubview:settingContainView];
    
    UIImageView *stIcon = [[UIImageView alloc] init];
    stIcon.image = [UIImage imageNamed:@"left_setting"];
    [settingContainView addSubview:stIcon];
    
    UILabel *stTitle = [[UILabel alloc] init];
    stTitle.textColor = [UIColor grayColor];
    stTitle.text = @"设置";
    stTitle.font = [UIFont systemFontOfSize:17];
    CGSize size = [stTitle sizeThatFits:CGSizeZero];
    [settingContainView addSubview:stTitle];
    
    [settingContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgImageView).offset(-40);
        make.left.equalTo(self.bgImageView);
        make.width.equalTo(@(size.width + 60));
        make.height.equalTo(@(30));
    }];
    [stIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(settingContainView).offset(20);
        make.centerY.equalTo(settingContainView);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
    [stTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stIcon.mas_right).offset(10);
        make.centerY.equalTo(settingContainView);
        make.width.equalTo(@(size.width));
        make.height.equalTo(@(20));
    }];
    
}
- (void)userPartCliked {
    NSLog(@"用户信息");
}
- (void)bkPartCliked {
    NSLog(@"我的名片");
}
- (void)bgButtonClicked:(UIButton *)bgButton {
    NSInteger tag = bgButton.tag;
    if (tag == LEFT_VIEW_BOTTOM_CELL_TAG) {
        // 0
    }else if (tag == LEFT_VIEW_BOTTOM_CELL_TAG + 1) {
        // 1
    }else if (tag == LEFT_VIEW_BOTTOM_CELL_TAG + 2) {
        // 2
    }else if (tag == LEFT_VIEW_BOTTOM_CELL_TAG + 3) {
        // 3
    }else if (tag == LEFT_VIEW_BOTTOM_CELL_TAG + 4) {
        // 4
    }else{
        
    }
    NSLog(@"%ld",tag);
}
- (void)loginButtonClicked {
    NSLog(@"登录");
}
- (void)settingClicked {
    NSLog(@"设置");
}
@end
