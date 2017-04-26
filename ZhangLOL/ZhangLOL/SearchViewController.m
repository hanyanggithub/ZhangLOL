//
//  SearchViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/20.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SearchViewController.h"
#import "NewestTableView.h"
#import "SmallCellModel.h"
#import "MessageViewModel.h"
#import "ImageBrowserController.h"
#import "MessgeDetailController.h"
#import "RefreshHeaderView.h"
#import "RefreshFooterView.h"

@interface SearchViewController ()<UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic, strong)NewestTableView *contentView;
@property(nonatomic, strong)RefreshHeaderView *refreshHeaderView;
@property(nonatomic, strong)RefreshFooterView *refreshFooterView;
@property(nonatomic, strong)UITableView *historyView;
@property(nonatomic, strong)UIButton *historyCleanButton;
@property(nonatomic, strong)UIView *contianerView;
@property(nonatomic, strong)UIImageView *iconImageView;
@property(nonatomic, strong)UITextField *inputView;
@property(nonatomic, strong)UIButton *cancelButton;
@property(nonatomic, strong)NSMutableArray *models;
@property(nonatomic, assign)int totalNum;
@property(nonatomic, assign)int page;
@property(nonatomic, copy)NSString *currentKeyword;
@property(nonatomic, assign)BOOL isFirstEnter;
@end

@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableFullScreenPop = YES;
    [self createSubviews];
    [self settingNaviBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIButton *clearButton = [self.inputView valueForKey:@"_clearButton"];
    [clearButton setImage:[UIImage imageNamed:@"businesscard_close"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"businesscard_close_hl"] forState:UIControlStateHighlighted];
    if (!self.isFirstEnter) {
        [self.inputView becomeFirstResponder];
        self.isFirstEnter = !self.isFirstEnter;
    }
}
- (void)settingNaviBar {

    [self.view insertSubview:self.customNaviBar aboveSubview:self.contentView];
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_for_seven"] forBarMetrics:UIBarMetricsDefault];
    self.customNaviBar.userInteractionEnabled = YES;
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.cancelButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [self.customNaviBar addSubview:self.cancelButton];
    

    self.contianerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contianerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    self.contianerView.layer.cornerRadius = 5;
    [self.customNaviBar addSubview:self.contianerView];
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.image = [UIImage imageNamed:@"nav_search"];
    [self.contianerView addSubview:self.iconImageView];
    
    self.inputView = [[UITextField alloc] init];
    self.inputView.delegate = self;
    self.inputView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索你想了解的资讯" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]}];
    self.inputView.font = [UIFont systemFontOfSize:14];
    self.inputView.textColor = MAIN_COLOR;
    self.inputView.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contianerView addSubview:self.inputView];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customNaviBar).offset(-10.0);
        make.width.equalTo(@(40));
        make.height.equalTo(@(20));
        make.bottom.equalTo(self.customNaviBar).offset(-11.0);
    }];
    [self.contianerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNaviBar).offset(10.0);
        make.right.equalTo(self.cancelButton.mas_left).offset(-20.0);
        make.height.equalTo(@(30));
        make.bottom.equalTo(self.customNaviBar).offset(-7.0);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contianerView).offset(5.0);
        make.width.equalTo(@(15));
        make.height.equalTo(@(15));
        make.centerY.equalTo(self.contianerView);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(2.0);
        make.right.equalTo(self.contianerView);
        make.height.equalTo(self.contianerView);
        make.centerY.equalTo(self.contianerView);
    }];

}
- (void)pop {
    if (self.inputView.editing) {
        [self.inputView resignFirstResponder];;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super pop];
        });
    }else{
        [super pop];
    }
    
}
- (void)createSubviews {
    self.contentView = [[NewestTableView alloc] initWithFrame:CGRectMake(0, NAVI_STATUS_BAR_HEIGHT, self.view.width, self.view.height - NAVI_STATUS_BAR_HEIGHT) style:UITableViewStylePlain];
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];
    
    self.refreshHeaderView = [[RefreshHeaderView alloc] initWithScrollView:self.contentView location:RefreshHeaderViewLocationBottomEqualToScrollViewTop];
    __weak typeof(self) weakSelf = self;
    [self.refreshHeaderView refreshHeaderViewStatusChangedBlock:^(RefreshHeaderViewStatus status) {
        if (status == RefreshHeaderViewStatusRefreshing) {
            [weakSelf searchAction];
        }
    }];
    
    self.refreshFooterView = [[RefreshFooterView alloc] initWithScrollView:self.contentView];
    [self.refreshFooterView refreshFooterViewStatusChangedBlock:^(RefreshFooterViewStatus status) {
        if (status == RefreshFooterViewStatusRefreshing) {
            [weakSelf loadMore];
        }
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.inputView isFirstResponder]) {
        [self.inputView resignFirstResponder];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.inputView endEditing:YES];
    SmallCellModel *model = [[tableView cellForRowAtIndexPath:indexPath] valueForKey:@"model"];
    
    [self.viewModel saveModelTag:model];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([model.newstype isEqualToString:@"图集"]) {
        ImageBrowserController *imageBroser = [[ImageBrowserController alloc] init];
        imageBroser.cellModel = model;
        [self.navigationController pushViewController:imageBroser animated:YES];
    }else{
        MessgeDetailController *detail = [[MessgeDetailController alloc] init];
        detail.cellModel = model;
        [self.navigationController pushViewController:detail animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewestTableView *newestTable = (NewestTableView *)tableView;
    SmallCellModel *model = newestTable.models[indexPath.row];
    if ([model.newstype isEqualToString:@"图集"]) {
        return ATLAS_CELL_HEIGHT;
    }
    return ORDINARY_CELL_HEIGHT;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchAction];
    [textField endEditing:YES];
    return YES;
}

- (void)loadMore {
    if (self.totalNum > self.models.count) {
        NSMutableDictionary *searchParameters = [NSMutableDictionary dictionary];
        [searchParameters setObject:@(self.page + 1) forKey:@"page"];
        [searchParameters setObject:@"10" forKey:@"num"];
        [searchParameters setObject:@"ios" forKey:@"plat"];
        [searchParameters setObject:@"3" forKey:@"version"];
        [searchParameters setObject:self.currentKeyword forKey:@"keyword"];
        [ZhangLOLNetwork GET:SEARCH_PATH parameters:searchParameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            self.totalNum = [responseObject[@"total_num"] intValue];
            self.page = [responseObject[@"page"] intValue];
            NSArray *array = responseObject[@"list"];
            for (NSDictionary *dic in array) {
                SmallCellModel *model = [[SmallCellModel alloc] initWithDic:dic];
                [self.models addObject:model];
            }
            self.contentView.models = self.models;
            [self.contentView reloadData];
            [self.refreshFooterView stopRefreshing];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.refreshFooterView stopRefreshing];
        }];
    }
}
- (void)searchAction {

    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionary];
    [searchParameters setObject:@"0" forKey:@"page"];
    [searchParameters setObject:@"10" forKey:@"num"];
    [searchParameters setObject:@"ios" forKey:@"plat"];
    [searchParameters setObject:@"3" forKey:@"version"];
    NSString *keyWord = [self.inputView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (keyWord.length > 0) {
        [searchParameters setObject:keyWord forKey:@"keyword"];
        self.currentKeyword = keyWord;
        [ZhangLOLNetwork GET:SEARCH_PATH parameters:searchParameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (responseObject) {
                self.totalNum = [responseObject[@"total_num"] intValue];
                self.page = [responseObject[@"page"] intValue];
                NSArray *array = responseObject[@"list"];
                NSMutableArray *arrays = [NSMutableArray array];
                for (NSDictionary *dic in array) {
                    SmallCellModel *model = [[SmallCellModel alloc] initWithDic:dic];
                    [arrays addObject:model];
                }
                self.models = arrays;
                self.contentView.models = self.models;
                
                if (self.models.count > 0) {
                    [self removeErrorView];
                }else{
                    [self showErrorViewWithMessage:@"没有找到搜索对象"];
                }
                [self.contentView reloadData];
            }
            [self.refreshHeaderView stopRefreshing];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.refreshHeaderView stopRefreshing];
        }];
    }
}


@end
