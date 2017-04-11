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
#import "ImageBlur.h"
#import "CacheManager.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,SWRevealViewControllerDelegate,MessageScrollViewDataSource,UINavigationControllerDelegate,UINavigationBarDelegate,UITabBarControllerDelegate>
@property(nonatomic, strong)UIButton *menuButton;
@property(nonatomic, strong)UIButton *searchButton;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)MessageScrollView *messageScrollView;
@property(nonatomic, strong)MessageViewModel *viewModel;
@property(nonatomic, strong)NSArray *channelModels;
@property(nonatomic, strong)ChannelView *channelView;
@property(nonatomic, strong)NSArray *rencommendModels;
@property(nonatomic, strong)RecommendView *recommendView;
@property(nonatomic, strong)RefreshHeaderView *refreshHeader;
@property(nonatomic, strong)UIImageView *barImageView;
@property(nonatomic, strong)UIImage *currentBarImage;
@property(nonatomic, assign)BOOL isVague; // 标记导航栏的虚化状态
@property(nonatomic, assign)CGPoint priorPoint;
@property(nonatomic, assign)BOOL startScroll;
@property(nonatomic, strong)NSMutableDictionary *everyChannelPages;
@property(nonatomic, assign)BOOL isLoadingMore;

@end

@implementation MessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   
    [self settingSWRevealViewController];
    [self layoutNavigationBar];
    [self createSubviews];
    [self requestChannelAndRecommendData];
}

- (void)settingSWRevealViewController {
    SWRevealViewController *sw = [self revealViewController];
    ;
    sw.frontViewPosition = FrontViewPositionLeftSideMostRemoved;
    sw.delegate = self;
    [sw panGestureRecognizer];
    [sw tapGestureRecognizer];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 消失之后重新改变子视图层级关系
    [self.navigationController.navigationBar insertSubview:self.barImageView atIndex:0];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 将要消失保存当前图片
    self.currentBarImage = self.barImageView.image;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 将要出现 设置
    self.barImageView.contentMode = UIViewContentModeBottom;
    self.barImageView.image = self.currentBarImage;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 出现之后重新改变子视图层级关系
    [self.navigationController.navigationBar insertSubview:self.barImageView atIndex:0];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 将要突出详细页
    if ([viewController isKindOfClass:NSClassFromString(@"MessgeDetailController")]) {
        viewController.navigationItem.hidesBackButton = YES;
        self.hidesBottomBarWhenPushed = NO;
        self.barImageView.contentMode = UIViewContentModeScaleToFill;
        self.barImageView.image = [UIImage imageNamed:@"nav_bar_bg_for_seven"];
    }
}

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
- (void)layoutNavigationBar {
 
    self.automaticallyAdjustsScrollViewInsets = NO;
    // navigationBar中的背景视图
    UIView *barBgView = self.navigationController.navigationBar.subviews[0];
    barBgView.hidden = YES;
    self.navigationController.delegate = self;
    self.barImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 64)];
    self.barImageView.contentMode = UIViewContentModeBottom;
    // title
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_COLOR}];
    // 添加item
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0, 0, 36, 36);
    self.menuButton.layer.cornerRadius = 18;
    self.menuButton.layer.masksToBounds = YES;
    self.menuButton.layer.borderWidth = 1;
    self.menuButton.layer.borderColor = MAIN_COLOR.CGColor;
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"chat_room_push_news_default_header"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame = CGRectMake(0, 0, 36, 36);
    [self.searchButton setImage:[UIImage imageNamed:@"news_search"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"news_search_hl"] forState:UIControlStateHighlighted];
    [self.searchButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
- (void)menuButtonClicked {
    SWRevealViewController *sw = [self revealViewController];
    [sw revealToggleAnimated:YES];
}
- (void)searchButtonClicked {
    NSLog(@"搜索");
    
}

- (void)controllNaviBarStatusWithContentOffsetY:(CGFloat)contentOffsetY {
    
    if (contentOffsetY > RECOMMEND_VIEW_HEIGHT - 64 && self.isVague == NO) {
        // 超过导航栏
        UIImage *image = [self.recommendView getCurrentShowImage];
        self.barImageView.image = [ImageBlur gaussBlurWithLevel:0.8 image:image];
        [self.barImageView.subviews firstObject].hidden = NO;
        self.navigationItem.title = @"英雄联盟";
        self.isVague = YES;
        
    }else if(contentOffsetY < RECOMMEND_VIEW_HEIGHT - 64 && self.isVague == YES && self.startScroll){
        // 没超过
        self.barImageView.image = nil;
        [self.barImageView.subviews firstObject].hidden = YES;
        self.navigationItem.title = @"";
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

- (void)createSubviews {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SCREEN_HEIGHT - TABBAR_HEIGHT) style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = SCREEN_HEIGHT - TABBAR_HEIGHT - CHANNELBAR_HEIGHT - NAVIBAR_HEIGHT;
    [self.view addSubview:self.tableView];
    
    self.channelView = [[ChannelView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, CHANNELBAR_HEIGHT)];
    
    self.messageScrollView = [[MessageScrollView alloc] initWithFrame:CGRectMake(0, 0,self.tableView.width, self.tableView.rowHeight)];
    
    self.channelView.delegate = (id<ChannelViewDelegate>)self.messageScrollView;
    self.messageScrollView.scrollDelegate = (id<MessageScrollViewDelegate>)self.channelView;
    self.messageScrollView.dataSource = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.refreshHeader = [[RefreshHeaderView alloc] initWithScrollView:self.tableView];
    __weak typeof(self) weakSelf = self;
    [self.refreshHeader refreshHeaderViewStatusChangedBlock:^(RefreshHeaderViewStatus status) {
        if (status == RefreshHeaderViewStatusWaitScroll) {
//            NSLog(@"等待刷新");//do something
        }else if (status == RefreshHeaderViewStatusScrolling) {
//            NSLog(@"向下滑动中。。。。");//do something
        }else if (status == RefreshHeaderViewStatusWaitLoosen) {
//            NSLog(@"释放开始刷新");//do something
        }else{
            [CacheManager cleanAllImageCacheFromMemory];
            [weakSelf requestChannelAndRecommendData];
        }
    }];

    self.recommendView = [[RecommendView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, RECOMMEND_VIEW_HEIGHT)];
    self.tableView.tableHeaderView = self.recommendView;
}

- (void)requestNewestAndSpecialData {
    // 加载资讯页最新频道数据
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestDataWithChannelModel:self.channelModels[0] page:@"0" automaticMerge:NO success:^(ChannelModel *channelModel, NSArray *models) {
        [weakSelf.messageScrollView updateTableViewsWithModels:models index:self.messageScrollView.currentIndex info:nil];
        ChannelModel *model = self.channelModels[0];
        [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
    // 加载资讯页专栏频道数据
    [self.viewModel requestDataWithChannelModel:self.channelModels[1] page:@"0" automaticMerge:NO success:^(ChannelModel *channelModel, NSArray *models) {
        [weakSelf.messageScrollView updateTableViewsWithModels:nil index:1 info:[NSDictionary dictionaryWithObject:models forKey:@"data"]];
        ChannelModel *model = self.channelModels[0];
        [weakSelf.everyChannelPages setObject:@"0" forKey:model.channel_id];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (void)requestChannelAndRecommendData {
    // 频道
    [CacheManager defaultSettingSDImageCache];
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestChannelData:CHANNEL_URL success:^(NSURLSessionDataTask *task, NSArray *models) {
        // 显示频道信息
        weakSelf.channelModels = models;
        [weakSelf.channelView updateWithChannelModels:models];
        // 加载最新和专题
        [weakSelf requestNewestAndSpecialData];
        // 如果是下拉刷新触发的结束刷新
        if (weakSelf.refreshHeader.currentStatus == RefreshHeaderViewStatusRefreshing) {
            [weakSelf.refreshHeader stopRefreshing];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
  

    // 顶部vendor
    [self.viewModel requestRecommendData:RENCOMMEND_URL success:^(NSURLSessionDataTask *task, NSArray *models) {
        // 显示频道信息
        weakSelf.rencommendModels = models;
        [weakSelf.recommendView updateWithModels:models];
        // 如果是下拉刷新触发的结束刷新
        if (weakSelf.refreshHeader.currentStatus == RefreshHeaderViewStatusRefreshing) {
            [weakSelf.refreshHeader stopRefreshing];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
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
            self.startScroll = NO;
        }else{
            self.startScroll = YES;
        }
    }
    // 2.2向下滑动
    if (scrollDirection == UIScrollViewScrollDirectionDown) {
        UITableView *tableView = [self.messageScrollView currentTableView];
        if (tableView.contentOffset.y > 0) {
            scrollView.contentOffset = CGPointMake(0, RECOMMEND_VIEW_HEIGHT - 64);
            self.startScroll = NO;
        }else{
            self.startScroll = YES;
        }
    }
    
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        // 开启滑动交互
        self.view.userInteractionEnabled = YES;
        revealController.springDampingRatio = 0.8;
    }
    if (position == FrontViewPositionRight) {
        // 关闭滑动交互
        self.view.userInteractionEnabled = NO;
        revealController.springDampingRatio = 1.0;
    }
}

#pragma mark - MessageScrollViewDataSource
- (void)messageScrollViewSubTableViewShouldLoadMoreDataWithIndex:(NSInteger)index {
    self.isLoadingMore = YES;
    // 获取当前页数
    ChannelModel *model = self.channelModels[index];
    NSString *currentPage = [self.everyChannelPages objectForKey:model.channel_id];
    NSString *page = [NSString stringWithFormat:@"%ld",currentPage.integerValue + 1];
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestDataWithChannelModel:model page:page automaticMerge:YES success:^(ChannelModel *channelModel, NSArray *models) {
        if ([model.chnl_type isEqualToString:@"col"]) {
            [weakSelf.messageScrollView updateTableViewsWithModels:nil index:index info:@{@"data":models}];
        }else{
            [weakSelf.messageScrollView updateTableViewsWithModels:models index:index info:nil];
        }
        [weakSelf.everyChannelPages setObject:page forKey:model.channel_id];
        weakSelf.isLoadingMore = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.isLoadingMore = NO;
    }];
}


@end
