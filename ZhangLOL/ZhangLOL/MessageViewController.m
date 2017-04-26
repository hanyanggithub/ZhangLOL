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
#import "NewMessageTipView.h"


@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,MessageScrollViewDataSource>
@property(nonatomic, strong)UIButton *searchButton;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)MessageScrollView *messageScrollView;
@property(nonatomic, strong)MessageViewModel *viewModel;
@property(nonatomic, strong)ChannelView *channelView;
@property(nonatomic, strong)RecommendView *recommendView;
@property(nonatomic, strong)RefreshHeaderView *refreshHeader;
@property(nonatomic, assign)BOOL isVague;                                           // 标记导航栏的虚化状态
@property(nonatomic, assign)CGPoint priorPoint;                                     // 用于判断滑动视图的滑动方向，前一个contentOffset
@property(nonatomic, assign)BOOL isStartScroll;                                     // 标记大表视图是否是滑动状态
@property(nonatomic, strong)NSMutableDictionary *everyChannelPages;                 // 每一频道对应的数据页数一页20个数据
@property(nonatomic, assign)BOOL isLoadingMore;                                     // 表示当前是否为加载更多数据的状态

@end

@implementation MessageViewController

#pragma mark - lazy loading

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

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.haveMenuButton = YES;
    // 下载开机图和启动图
    [ImageBlur downloadLaunchImageIsForce:YES];
    [self.revealViewController tapGestureRecognizer];
    [self createSubviews];
    [self layoutNavigationBar];
    // 设置缓存数
    [CacheManager defaultSettingSDImageCache];
    // 读取本地数据
    BOOL result = [self.viewModel readDataFromDB];
    if (result) {
        // 显示本地数据
        [self showView];
    }
    // 网络可用请求数据
    if ([ZhangLOLNetwork netUsable]) {
        [self requestChannelData];
        [self requestRecommendData];
    }else{
        
    }
    // 开启网络状态监控
    [self monitoring];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.recommendView startAutoScrolling];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recommendView stopAutoScrolling];
}

#pragma mark - layout navigation bar
- (void)layoutNavigationBar {
    [self.view insertSubview:self.customNaviBar aboveSubview:self.tableView];
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"navitransparentbg"] forBarMetrics:UIBarMetricsDefault];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame = CGRectMake(0, 0, 36, 36);
    [self.searchButton setImage:[UIImage imageNamed:@"news_search"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"news_search_hl"] forState:UIControlStateHighlighted];
    [self.searchButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchButton];
    self.customNaviItem.rightBarButtonItem = rightItem;
}

#pragma mark - search button handle
- (void)searchButtonClicked {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    searchViewController.viewModel = self.viewModel;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark -
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
    
    self.refreshHeader = [[RefreshHeaderView alloc] initWithScrollView:self.tableView location:RefreshHeaderViewLocationTopEqualToScrollViewTop];
    __weak typeof(self) weakSelf = self;
    [self.refreshHeader refreshHeaderViewStatusChangedBlock:^(RefreshHeaderViewStatus status) {
        if (status == RefreshHeaderViewStatusRefreshing){
            if (![ZhangLOLNetwork netUsable]) {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
                [SVProgressHUD setForegroundColor:MAIN_COLOR];
                [SVProgressHUD showErrorWithStatus:@"请检测网络状态"];
                [SVProgressHUD dismissWithDelay:4];
                [weakSelf.refreshHeader stopRefreshing];
            }else{
                [weakSelf requestRecommendData];
                [weakSelf refreshDataForCurrentChannel];
            }
        }
    }];

    self.recommendView = [[RecommendView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, RECOMMEND_VIEW_HEIGHT)];
    self.tableView.tableHeaderView = self.recommendView;
}
- (void)showView {
    // channel
    NSMutableArray *channelData = [NSMutableArray arrayWithArray:self.viewModel.channelModels];
    [channelData removeObjectAtIndex:2];
    [channelData removeObjectAtIndex:2];
    [self.channelView updateWithChannelModels:channelData];
    self.messageScrollView.allChannelCount = [self.channelView channelCount];
    
    // recommed
    [self.recommendView updateWithModels:self.viewModel.rencommendModels];
    
    // newet
    ChannelModel *channelModel = [self.viewModel.channelModels firstObject];
    NSArray *newestModels = self.viewModel.allChannelsModelDic[channelModel.channel_id];
    [self.messageScrollView updateTableViewsWithModels:newestModels index:self.messageScrollView.currentIndex info:nil];
    [self.everyChannelPages setObject:@"0" forKey:channelModel.channel_id];
    
    
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
        self.customNaviBar.hidden = YES;
    }else{
        self.customNaviBar.hidden = NO;
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

- (void)monitoring {
    [ZhangLOLNetwork setReachabilityStatusChangeBlock:^(ZhangLOLReachabilityStatus status) {
        ZhangLOLReachabilityStatus priorNetStatus = [ZhangLOLNetwork priorNetStatus];
        if (status == ZhangLOLReachabilityStatusNotReachable) {
           // show a net error view
        }
        if (status != ZhangLOLReachabilityStatusNotReachable) {
            // if error view showed remove
        }
        if (status != ZhangLOLReachabilityStatusNotReachable && priorNetStatus != ZhangLOLReachabilityStatusNotReachable) {
            // return
            
        }
        if (status != ZhangLOLReachabilityStatusNotReachable && priorNetStatus == ZhangLOLReachabilityStatusNotReachable) {
            [self requestChannelData];
            [self requestRecommendData];
        }
    }];
}

#pragma mark - request data
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
        // TODO handle error
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
        // TODO handle error
        [weakSelf.refreshHeader stopRefreshing];
    }];
    
}
- (void)requestNewestData {
    // 加载资讯页最新频道数据
    __weak typeof(self) weakSelf = self;
    ChannelModel *model = self.viewModel.channelModels[0];
    [self.viewModel requestDataWithChannelModel:model page:@"0" success:^(ChannelModel *channelModel, NSArray *models) {
        if (weakSelf.viewModel.shouldShowNewMessageView) {
            [NewMessageTipView showMessage:[NSString stringWithFormat:@"有%d条最新资讯",weakSelf.viewModel.newMessageCount]];
            weakSelf.viewModel.shouldShowNewMessageView = NO;
            weakSelf.viewModel.newMessageCount = 0;
        }
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:weakSelf.messageScrollView.currentIndex info:nil];
        [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        // TODO handle error
    }];
}

- (void)requestOtherChannelData {
    
    __weak typeof(self) weakSelf = self;
    for (int i = 1; i < self.viewModel.channelModels.count; i++) {
        ChannelModel *model = self.viewModel.channelModels[i];
        [self.viewModel requestDataWithChannelModel:model page:@"0" success:^(ChannelModel *channelModel, NSArray *models) {
            // 设置初始数据页数
            [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@",error);
            // TODO handle error
        }];
    }
}


- (void)refreshDataForCurrentChannel {
    // 刷新资讯页当前显示的频道数据
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestDataWithChannelModel:self.viewModel.channelModels[self.messageScrollView.currentIndex] page:@"0" success:^(ChannelModel *channelModel, NSArray *models) {
        if (weakSelf.viewModel.shouldShowNewMessageView) {
            [NewMessageTipView showMessage:[NSString stringWithFormat:@"有%d条最新资讯",weakSelf.viewModel.newMessageCount]];
            weakSelf.viewModel.shouldShowNewMessageView = NO;
            weakSelf.viewModel.newMessageCount = 0;
        }
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:weakSelf.messageScrollView.currentIndex info:nil];
        [weakSelf.refreshHeader stopRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        // TODO handle error
        [weakSelf.refreshHeader stopRefreshing];
    }];
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
//    [self settingAutoScrollingWithContentOffsetY:scrollView.contentOffset.y];
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
    
    if (![ZhangLOLNetwork netUsable]) {
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        [SVProgressHUD showErrorWithStatus:@"请检测网络状态"];
        [SVProgressHUD dismissWithDelay:4 completion:^{
          self.isLoadingMore = NO;
        }];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageScrollView.refreshFooterView startRefreshing];
    [self.viewModel requestDataWithChannelModel:model page:page success:^(ChannelModel *channelModel, NSArray *models) {
        if (model) {
            [weakSelf.messageScrollView updateTableViewsWithModels:models index:index info:nil];
            [weakSelf.everyChannelPages setObject:page forKey:model.channel_id];
        }
        weakSelf.isLoadingMore = NO;
        [weakSelf.messageScrollView.refreshFooterView stopRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.isLoadingMore = NO;
        [weakSelf.messageScrollView.refreshFooterView stopRefreshing];
    }];
}


@end
