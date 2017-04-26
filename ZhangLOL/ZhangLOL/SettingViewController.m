//
//  SettingViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "AppDelegate.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,TencentSessionDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)TencentOAuth *oAuth;
@end

NSString * const logoutNotificationName = @"LogoutNotificationName";

@implementation SettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.haveBackButton = YES;
    self.enableFullScreenPop = YES;
    self.customNaviItem.title = @"设置";
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_for_seven"] forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *cacheData = [NSMutableDictionary dictionaryWithObjects:@[@"清空缓存",@"20MB",@"1"] forKeys:@[@"leftTitle",@"rightTitle",@"isArrow"]];
    NSArray *section1 = @[@{@"leftTitle":@"省流量",@"rightTitle":@"资讯图片自动下载设置",@"isArrow":@"1"},cacheData];
    NSArray *section2 = @[@{@"leftTitle":@"关于掌盟",@"rightTip":@"1",@"isArrow":@"1"},@{@"leftTitle":@"意见反馈",@"rightTitle":@"官方反馈QQ群:385410609",@"isArrow":@"1"}];
    self.dataList = @[section1,section2];
    [self createSubviews];
    // 计算图片缓存
    [CacheManager calculateDiskCacheSizeWithCompletionBlock:^(NSUInteger imageCount, NSUInteger size) {
        NSString *cacheText = [NSString stringWithFormat:@"%.2fM",(CGFloat)(size / 1024 / 1024)];
        [cacheData setObject:cacheText forKey:@"rightTitle"];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)createSubviews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVI_STATUS_BAR_HEIGHT, self.view.width, self.view.height - NAVI_STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 100)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTintColor:[UIColor whiteColor]];
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    UIImage *colorImage = [UIImage imageNamed:@"update_yes_pressed"];
    UIColor *color = [ImageBlur getImagePixelColorWithPoint:colorImage point:CGPointMake(10, 5)];
    button.backgroundColor = color;
    [button addTarget:self action:@selector(goToLogin) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    self.tableView.tableFooterView = footerView;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.6);
        make.height.equalTo(@(40));
        make.centerY.equalTo(footerView);
        make.centerX.equalTo(footerView);
    }];
    if (!self.isLogin) {
        [button setTitle:@"登录" forState:UIControlStateNormal];
    }else{
        [button setTitle:@"注销登录" forState:UIControlStateNormal];
    }
    
}
- (void)goToLogin {
    if (!self.isLogin) {
        [self.navigationController popViewControllerAnimated:NO];
        [super goToLogin];
    }else{
        // alert
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定注销登录" message:@"注销登录状态是无法使用一些功能的哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *token = [USER_DEFAULTS stringForKey:QQ_TOKEN_KEY];
            if (token) {
                self.oAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
                self.oAuth.accessToken = token;
                self.oAuth.openId = [USER_DEFAULTS stringForKey:QQ_OPENID_KEY];
                self.oAuth.expirationDate = [USER_DEFAULTS objectForKey:QQ_TOKEN_EXDATE_KEY];
                // 注销
                [self.oAuth logout:self];
            }
            [alertVC dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
        [alertVC addAction:confirm];
        [alertVC addAction:cancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"settingCellId"];
    if (cell == nil) {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCellId"];
    }
    NSDictionary *dataDic = self.dataList[indexPath.section][indexPath.row];
    cell.leftTitle = dataDic[@"leftTitle"];
    NSString *rightTitle = dataDic[@"rightTitle"];
    NSString *rightTip = dataDic[@"rightTip"];
    NSString *isArrow = dataDic[@"isArrow"];
    if (isArrow.boolValue) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (rightTitle) {
        cell.rightViewStyle = SettingTableViewCellRightViewStyleLabel;
        cell.rightTitle = rightTitle;
    }else if (rightTip) {
        cell.rightViewStyle = SettingTableViewCellRightViewStyleNewMessageTipView;
    }else{
        cell.rightViewStyle = SettingTableViewCellRightViewStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        [CacheManager cleanAllImageCacheFromDiskWithCompletion:^{
            NSArray *array2d = [self.dataList firstObject];
            NSMutableDictionary *dic = [array2d lastObject];
            [dic setObject:@"0M" forKey:@"rightTitle"];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [SVProgressHUD showSuccessWithStatus:@"清除成功"];
        }];
    }
    
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
}
- (void)tencentDidNotLogin:(BOOL)cancelled {
}
- (void)tencentDidNotNetWork {
}
#pragma mark - TencentSessionDelegate
- (void)tencentDidLogout {
    [USER_DEFAULTS removeObjectForKey:QQ_TOKEN_KEY];
    [USER_DEFAULTS removeObjectForKey:QQ_OPENID_KEY];
    [USER_DEFAULTS removeObjectForKey:QQ_TOKEN_EXDATE_KEY];
    APP_DELEGATE.userInfo = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotificationName object:nil];
    [self goToLogin];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
