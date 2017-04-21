//
//  MessageViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessageViewController.h"
#import "ChannelView.h"
#import "RecommendView.h"
#import "MessageScrollView.h"
#import "RefreshHeaderView.h"
#import "MessageViewModel.h"
#import "ChannelModel.h"
#import "CacheManager.h"
#import "SearchViewController.h"


@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,SWRevealViewControllerDelegate,MessageScrollViewDataSource,UINavigationControllerDelegate,UITabBarControllerDelegate>
@property(nonatomic, strong)UIButton *menuButton;
@property(nonatomic, strong)UIButton *searchButton;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)MessageScrollView *messageScrollView;
@property(nonatomic, strong)MessageViewModel *viewModel;
@property(nonatomic, strong)ChannelView *channelView;
@property(nonatomic, strong)RecommendView *recommendView;
@property(nonatomic, strong)RefreshHeaderView *refreshHeader;
@property(nonatomic, assign)BOOL isVague;       // 标记导航栏的虚化状态
@property(nonatomic, assign)CGPoint priorPoint;
@property(nonatomic, assign)BOOL isStartScroll; // 标记大表视图是否是滑动状态
@property(nonatomic, strong)NSMutableDictionary *everyChannelPages;
@property(nonatomic, assign)BOOL isLoadingMore; // 表示是否是加载更多数据状态

@end

@implementation MessageViewController


- (MessageViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [[MessageViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableDictionary *)everyChannelPages {
    if (_everyChannelPages == nil) {
        _everyChannelPages = [NSMutableDictionary dictionary];
    }
    return _everyChannelPages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingSWRevealViewController];
    [self createSubviews];
    [self layoutNavigationBar];
    [CacheManager defaultSettingSDImageCache];
    [self requestChannelData];
    [self requestRecommendData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.recommendView startAutoScrolling];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recommendView stopAutoScrolling];
}
- (void)settingSWRevealViewController {
    SWRevealViewController *sw = [self revealViewController];
    ;
    sw.frontViewPosition = FrontViewPositionLeftSideMostRemoved;
    sw.delegate = self;
    [sw panGestureRecognizer];
    [sw tapGestureRecognizer];
}
- (void)layoutNavigationBar {
    self.navigationController.delegate = self;
    [self.view insertSubview:self.customNaviBar aboveSubview:self.tableView];
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"navitransparentbg"] forBarMetrics:UIBarMetricsDefault];
    // 添加item
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0, 0, 36, 36);
    self.menuButton.layer.cornerRadius = 18;
    self.menuButton.layer.masksToBounds = YES;
    self.menuButton.layer.borderWidth = 1;
    self.menuButton.layer.borderColor = MAIN_COLOR.CGColor;
    id appDelegate = [UIApplication sharedApplication].delegate;
    NSDictionary *userInfo = [appDelegate valueForKey:@"userInfo"];
    if (userInfo) {
        NSURL *url = [NSURL URLWithString:userInfo[@"figureurl_qq_1"]];
        [self.menuButton sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
    }else{
        [self.menuButton setBackgroundImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] forState:UIControlStateNormal];
    }
    [self.menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.customNaviItem.leftBarButtonItem = leftItem;
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame = CGRectMake(0, 0, 36, 36);
    [self.searchButton setImage:[UIImage imageNamed:@"news_search"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"news_search_hl"] forState:UIControlStateHighlighted];
    [self.searchButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchButton];
    self.customNaviItem.rightBarButtonItem = rightItem;
    
}
- (void)menuButtonClicked {
    SWRevealViewController *sw = [self revealViewController];
    if (sw.frontViewPosition == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = NO;
    }
    [sw revealToggleAnimated:YES];
}
- (void)searchButtonClicked {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    searchViewController.viewModel = self.viewModel;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)createSubviews {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SCREEN_HEIGHT - TABBAR_HEIGHT) style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = SCREEN_HEIGHT - TABBAR_HEIGHT - CHANNELBAR_HEIGHT - NAVI_STATUS_BAR_HEIGHT;
    [self.view addSubview:self.tableView];
    
    self.channelView = [[ChannelView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, CHANNELBAR_HEIGHT)];
    
    self.messageScrollView = [[MessageScrollView alloc] initWithFrame:CGRectMake(0, 0,self.tableView.width, self.tableView.rowHeight)];
    
    self.channelView.delegate = (id<ChannelViewDelegate>)self.messageScrollView;
    self.messageScrollView.scrollDelegate = (id<MessageScrollViewDelegate>)self.channelView;
    self.messageScrollView.dataSource = self;
    self.messageScrollView.viewModel = self.viewModel;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.refreshHeader = [[RefreshHeaderView alloc] initWithScrollView:self.tableView location:RefreshHeaderViewLocationBottomEqualToScrollViewTop];
    __weak typeof(self) weakSelf = self;
    [self.refreshHeader refreshHeaderViewStatusChangedBlock:^(RefreshHeaderViewStatus status) {
        if (status == RefreshHeaderViewStatusRefreshing){
            [weakSelf requestRecommendData];
            [weakSelf refreshDataForCurrentChannel];
        }
    }];

    self.recommendView = [[RecommendView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, RECOMMEND_VIEW_HEIGHT)];
    self.tableView.tableHeaderView = self.recommendView;
}

- (void)controllNaviBarStatusWithContentOffsetY:(CGFloat)contentOffsetY {
    
    if (contentOffsetY > RECOMMEND_VIEW_HEIGHT - 64 && self.isVague == NO) {
        // 超过导航栏
        UIImage *image = [self.recommendView getCurrentShowImage];
        [self.customNaviBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        self.customNaviItem.title = @"英雄联盟";
        self.isVague = YES;
        
    }else if(contentOffsetY < RECOMMEND_VIEW_HEIGHT - 64 && self.isVague == YES && self.isStartScroll){
        // 没超过
        [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"navitransparentbg"] forBarMetrics:UIBarMetricsDefault];
        self.customNaviItem.title = @"";
        self.isVague = NO;
    }else{
        
    }
}

- (void)controllNaviBarButtonHiddenWithContentOffsetY:(CGFloat)contentOffsetY {
    if (contentOffsetY < -20) {
        self.menuButton.hidden = YES;
        self.searchButton.hidden = YES;
    }else{
        self.menuButton.hidden = NO;
        self.searchButton.hidden = NO;
    }
}

- (void)settingAutoScrollingWithContentOffsetY:(CGFloat)contentOffsetY {
    if (contentOffsetY < 0) {
        [self.recommendView stopAutoScrolling];
    }else{
        [self.recommendView startAutoScrolling];
    }
}

- (void)scrollInteractionWithScrollView:(UIScrollView *)scrollView {
    // 1.判断滑动的方向
    CGPoint currentPoint = scrollView.contentOffset;
    CGFloat H = currentPoint.x - self.priorPoint.x;
    CGFloat V = currentPoint.y - self.priorPoint.y;
    self.priorPoint = currentPoint;
    UIScrollViewScrollDirection scrollDirection = 0;
    if (H > 0) {
        scrollDirection = UIScrollViewScrollDirectionLeft;
    }else if (H < 0){
        scrollDirection = UIScrollViewScrollDirectionRight;
    }else{
        // 没动
    }
    if (V > 0) {
        scrollDirection = UIScrollViewScrollDirectionUp;
    }else if (V < 0){
        scrollDirection = UIScrollViewScrollDirectionDown;
    }else{
        // 没动
    }
    
    // 2.1向上滑动
    if (scrollDirection == UIScrollViewScrollDirectionUp) {
        if (scrollView.contentOffset.y > RECOMMEND_VIEW_HEIGHT - 64) {
            scrollView.contentOffset = CGPointMake(0, RECOMMEND_VIEW_HEIGHT - 64);
            self.isStartScroll = NO;
        }else{
            self.isStartScroll = YES;
        }
    }
    // 2.2向下滑动
    if (scrollDirection == UIScrollViewScrollDirectionDown) {
        UITableView *tableView = [self.messageScrollView currentTableView];
        if (tableView.contentOffset.y > 0) {
            scrollView.contentOffset = CGPointMake(0, RECOMMEND_VIEW_HEIGHT - 64);
            self.isStartScroll = NO;
        }else{
            self.isStartScroll = YES;
        }
    }
}



- (void)requestNewestData {
    // 加载资讯页最新频道数据
    __weak typeof(self) weakSelf = self;
    
    ChannelModel *model = self.viewModel.channelModels[0];
    
    [self.viewModel requestDataWithChannelModel:model page:@"0" automaticMerge:YES success:^(ChannelModel *channelModel, NSArray *models) {
        
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:self.messageScrollView.currentIndex info:nil];
        [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

- (void)requestOtherChannelData {
    
    __weak typeof(self) weakSelf = self;
    
    for (int i = 1; i < self.viewModel.channelModels.count; i++) {
        
        ChannelModel *model = self.viewModel.channelModels[i];
        
        [self.viewModel requestDataWithChannelModel:model page:@"0" automaticMerge:YES success:^(ChannelModel *channelModel, NSArray *models) {
            // 设置初始数据页数
            [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)requestChannelData {
    // 频道
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestChannelData:CHANNEL_URL success:^(NSURLSessionDataTask *task, NSArray *models) {
        
        NSMutableArray *channelData = [NSMutableArray arrayWithArray:weakSelf.viewModel.channelModels];
        // 移除赛事和视频
        [channelData removeObjectAtIndex:2];
        [channelData removeObjectAtIndex:2];
        // 显示频道信息
        [weakSelf.channelView updateWithChannelModels:channelData];
        // 设置messageScrollView最大频道数
        weakSelf.messageScrollView.allChannelCount = [weakSelf.channelView channelCount];
        // 请求资讯页最新频道数据
        [weakSelf requestNewestData];
        // 请求资讯页其他频道数据
        [weakSelf requestOtherChannelData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];

}

- (void)requestRecommendData {
    // 顶部vendor
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestRecommendData:RENCOMMEND_URL success:^(NSURLSessionDataTask *task, NSArray *models) {
        // 显示轮播图
        [weakSelf.recommendView updateWithModels:models];
        // 如果是下拉刷新触发的结束刷新
        [weakSelf.refreshHeader stopRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        [weakSelf.refreshHeader stopRefreshing];
    }];

}

- (void)refreshDataForCurrentChannel {
    // 刷新资讯页当前显示的频道数据
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestDataWithChannelModel:self.viewModel.channelModels[self.messageScrollView.currentIndex] page:@"0" automaticMerge:YES success:^(ChannelModel *channelModel, NSArray *models) {
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:self.messageScrollView.currentIndex info:nil];
        [weakSelf.refreshHeader stopRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        [weakSelf.refreshHeader stopRefreshing];
    }];
}


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController != self && self.revealViewController.panGestureRecognizer.enabled) {
        // 禁用侧滑
        self.revealViewController.panGestureRecognizer.enabled = NO;
    }
    if (viewController == self && !self.revealViewController.panGestureRecognizer.enabled) {
        // 开启侧滑
        self.revealViewController.panGestureRecognizer.enabled = YES;
    }
    
//    if ([viewController isMemberOfClass:[SearchViewController class]]) {
//        // .m扩展中的属性居然可以直接引用(目测是因为有这个系统属性所以可以)，xcode——bug
//        [viewController.inputView becomeFirstResponder];
//    }
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.channelView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CHANNELBAR_HEIGHT;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.messageScrollView];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 设置导航栏的是否显示模糊效果
    [self controllNaviBarStatusWithContentOffsetY:scrollView.contentOffset.y];
    // 设置滑过状态栏隐藏导航栏按钮
    [self controllNaviBarButtonHiddenWithContentOffsetY:scrollView.contentOffset.y];
    // 设置大表视图和小表视图的相对滑动逻辑
    [self scrollInteractionWithScrollView:scrollView];
    // 设置当大表视图处于下拉状态停止vendor的轮播
    [self settingAutoScrollingWithContentOffsetY:scrollView.contentOffset.y];
}

#pragma mark - SWRevealViewControllerDelegate

- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController {
    // 关闭滑动交互
    self.view.userInteractionEnabled = NO;
    revealController.springDampingRatio = 0.8;
}
- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController {
    if (revealController.frontViewPosition != FrontViewPositionRight) {
        self.view.userInteractionEnabled = YES;
    }
    
}
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        // 开启滑动交互
        self.view.userInteractionEnabled = YES;
        revealController.springDampingRatio = 1.0;
    }else if (position == FrontViewPositionRight) {
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - MessageScrollViewDataSource
- (void)messageScrollViewWillShowTableViewWithIndex:(NSInteger)index {
    ChannelModel *model = nil;
    if (index <= 1) {
        model = self.viewModel.channelModels[index];
        
    }else if (index > 1) {
        // 跳过视频和赛事模型
        model = self.viewModel.channelModels[index+2];
    }
    // 获取数据
    NSArray *models = self.viewModel.allChannelsModelDic[model.channel_id];
    // 刷新表视图
    [self.messageScrollView updateTableViewsWithModels:models index:index info:nil];
}

- (void)messageScrollViewSubTableViewShouldLoadMoreDataWithIndex:(NSInteger)index {
    self.isLoadingMore = YES;
    // 获取当前页数
    ChannelModel *model = nil;
    if (index <= 1) {
        model = self.viewModel.channelModels[index];
    }else{
        model = self.viewModel.channelModels[index + 2];
    }
    
    NSString *currentPage = [self.everyChannelPages objectForKey:model.channel_id];
    NSString *page = [NSString stringWithFormat:@"%d",currentPage.intValue + 1];
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestDataWithChannelModel:model page:page automaticMerge:YES success:^(ChannelModel *channelModel, NSArray *models) {
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:index info:nil];
        [weakSelf.everyChannelPages setObject:page forKey:model.channel_id];
        weakSelf.isLoadingMore = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.isLoadingMore = NO;
    }];
}


@end
