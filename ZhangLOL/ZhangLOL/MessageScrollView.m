//
//  MessageScrollView.m
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessageScrollView.h"
#import "NewestTableView.h"
#import "SpecialTableView.h"
#import "MessgeDetailController.h"
#import "ImageBrowserController.h"
#import "ChannelView.h"
#import "CacheManager.h"
#import "HoverView.h"
#import "MessageViewModel.h"
#import "SmallCellModel.h"

@interface MessageScrollView ()<UITableViewDelegate,ChannelViewDelegate> {
    NSMutableArray * _reusableTables;
}
@property(nonatomic, strong)NSArray *classArray;
@property(nonatomic, strong)NSMutableArray *tableViews;     // 所有的子视图
@property(nonatomic, strong)HoverView *suspendView;
@property(nonatomic, assign)CGPoint priorPoint;
@property(nonatomic, assign)BOOL isScrolling;
@end

@implementation MessageScrollView

- (HoverView *)suspendView {
    if (_suspendView == nil) {
        _suspendView = [[HoverView alloc] initWithFrame:CGRectMake(0, 0, self.width, HOVER_VIEW_HEIGHT)];
        NSArray *array = [NSArray arrayWithObjects:self.viewModel.channelModels[2],self.viewModel.channelModels[3], nil];
        [_suspendView updateWithModels:array];
        _suspendView.hidden = YES;
        [self addSubview:_suspendView];
    }
    return _suspendView;
}

- (NSMutableArray *)reusableTables {
    if (_reusableTables == nil) {
        _reusableTables = [NSMutableArray array];
    }
    return _reusableTables;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createFirstTwoTableViews];
        self.currentIndex = 0;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
    }
    return self;
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
    }
}
- (NSArray *)classArray {
    if (_classArray == nil) {
        _classArray = [NSArray arrayWithObjects:[NewestTableView class],[SpecialTableView class], nil];
    }
    return _classArray;
}
- (NSMutableArray *)tableViews {
    if (_tableViews == nil) {
        _tableViews = [NSMutableArray array];
    }
    return _tableViews;
}
- (UITableView *)currentTableView {
    if (self.currentIndex < self.tableViews.count) {
        return self.tableViews[self.currentIndex];
    }else{
        return nil;
    }
}

- (void)createFirstTwoTableViews {
    self.contentSize = CGSizeMake(self.width * 2, self.height);
    for (int i = 0; i < self.classArray.count; i++) {
        Class class = self.classArray[i];
        BaseTableView *tableView = nil;
        if (i == 1) {
            tableView = [[class alloc] initWithFrame:CGRectMake(self.width * i, 0, self.width, self.height) style:UITableViewStyleGrouped];
        }else{
            tableView = [[class alloc] initWithFrame:CGRectMake(self.width * i, 0, self.width, self.height) style:UITableViewStylePlain];
        }
        tableView.showsVerticalScrollIndicator = NO;
        tableView.delegate = self;
        [self addSubview:tableView];
        [self.tableViews addObject:tableView];
    }
}


- (void)updateTableViewsWithModels:(NSArray *)models index:(NSInteger)index info:(NSDictionary *)info {
    if (index < self.tableViews.count) {
        BaseTableView *tableView = self.tableViews[index];
        [tableView updateWithDataModels:models dataInfo:info];
        if (index == 0) {
            HoverView *hoverView = [[HoverView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, HOVER_VIEW_HEIGHT)];
            NSArray *array = [NSArray arrayWithObjects:self.viewModel.channelModels[2],self.viewModel.channelModels[3], nil];
            [hoverView updateWithModels:array];
            tableView.tableHeaderView = hoverView;
        }
        
        
    }else{
        // 判断是否有
    }
    
}


#pragma mark - 嵌套表视图的滑动逻辑
- (void)scrollInteractionWithScrollView:(UIScrollView *)scrollView {
    // 1.判断滑动的方向
    UIScrollViewScrollDirection scrollDirection = [self scrollDirectionWithCurrentPoint:scrollView.contentOffset];
    // 2.1 向上滑
    if (scrollDirection == UIScrollViewScrollDirectionUp) {
        UITableView *messageTableView = (UITableView *)self.superview.superview.superview.superview;
        if (messageTableView.contentOffset.y < RECOMMEND_VIEW_HEIGHT - 64) {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
        
        // 隐藏
        if (!self.suspendView.isHidden) {
            self.suspendView.hidden = YES;
        }
    }
    // 2.2 向下滑
    if (scrollDirection == UIScrollViewScrollDirectionDown) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
        // 显示
        if (scrollView.contentOffset.y > 64) {
            if (self.suspendView.isHidden) {
               self.suspendView.hidden = NO;
            }
        }
        
    }
}

#pragma mark - 加载更多数据的逻辑
- (void)loadMoreInteractionWithScrollView:(UIScrollView *)scrollView {
    UITableView *tableView = [self currentTableView];
    if (tableView == scrollView) {
        // 每当滑动到距离最下1.5倍tableView.height时静默加载更多
//        NSLog(@"%f,%f",tableView.contentOffset.y,tableView.contentSize.height);
        NSNumber *isLoadingMore = [self.viewController valueForKey:@"isLoadingMore"];
        BOOL isLoading =  isLoadingMore.boolValue;
        if (tableView.contentSize.height - tableView.contentOffset.y <= tableView.height * 1.5 && !isLoading) {
            if ([self.dataSource respondsToSelector:@selector(messageScrollViewSubTableViewShouldLoadMoreDataWithIndex:)]) {
                [self.dataSource messageScrollViewSubTableViewShouldLoadMoreDataWithIndex:self.currentIndex];
            }
        }

    }
    
}
#pragma mark - 根据当前表视图显示和滑动方向清除内存缓存逻辑
- (void)disposeCleanMemoryImageWithScrollView:(UIScrollView *)scrollView {
    UIScrollViewScrollDirection scrollDirection = [self scrollDirectionWithCurrentPoint:scrollView.contentOffset];
    if ([scrollView isKindOfClass:[NewestTableView class]]) {
        if (scrollDirection == UIScrollViewScrollDirectionUp) {
            
        }
        if (scrollDirection == UIScrollViewScrollDirectionDown) {
            
        }
    }
}

#pragma mark - 滑动视图滑动时禁止子视图的表视图滑动逻辑
- (void)subTableInteraction{
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        for (UITableView *tableView in self.tableViews) {
            if (tableView.scrollEnabled) {
                tableView.scrollEnabled = NO;
            }
        }
    }
    if (self.panGestureRecognizer.state == UIGestureRecognizerStatePossible) {
        for (UITableView *tableView in self.tableViews) {
            if (!tableView.scrollEnabled) {
                tableView.scrollEnabled = YES;
            }
        }
    }
}

#pragma mark - 根据当前点判断当前滑动视图的滑动方向
- (UIScrollViewScrollDirection)scrollDirectionWithCurrentPoint:(CGPoint)point {
    // 1.判断滑动的方向
    CGFloat H = point.x - self.priorPoint.x;
    CGFloat V = point.y - self.priorPoint.y;
    self.priorPoint = point;
    UIScrollViewScrollDirection scrollDirectionV = UIScrollViewScrollDirectionNone;
    UIScrollViewScrollDirection scrollDirectionH = UIScrollViewScrollDirectionNone;
    if (H > 0) {
        scrollDirectionH = UIScrollViewScrollDirectionLeft;
    }else if (H < 0){
        scrollDirectionH = UIScrollViewScrollDirectionRight;
    }else{
        // 没动
    }
    if (V > 0) {
        scrollDirectionV = UIScrollViewScrollDirectionUp;
    }else if (V < 0){
        scrollDirectionV = UIScrollViewScrollDirectionDown;
    }else{
        // 没动
    }
    return scrollDirectionH | scrollDirectionV;
}


- (void)subTableShowJudge {
    UIScrollViewScrollDirection scrollDirection = [self scrollDirectionWithCurrentPoint:self.contentOffset];
    if (!self.isScrolling && scrollDirection == UIScrollViewScrollDirectionRight) {
        self.isScrolling = YES;
        if (self.currentIndex > 0) {
            [self willShowTableViewWithIndex:self.currentIndex - 1];
        }
    }
    if (!self.isScrolling && scrollDirection == UIScrollViewScrollDirectionLeft) {
        self.isScrolling = YES;
        if (self.allChannelCount > self.currentIndex + 1) {
            [self willShowTableViewWithIndex:self.currentIndex + 1];
        }
    }
}

- (void)stopDrawerGesture {
    SWRevealViewController *drawer = [self.viewController revealViewController];
    drawer.panGestureRecognizer.enabled = NO;
}
- (void)startDrawerGesture {
    SWRevealViewController *drawer = [self.viewController revealViewController];
    drawer.panGestureRecognizer.enabled = YES;

}
#pragma mark - 将要显示新的表视图方法调用
- (void)willShowTableViewWithIndex:(NSInteger)index {
    // 判断是否需要创建
    if (index >= self.tableViews.count) {
        // 创建
        self.contentSize = CGSizeMake(self.width * (index + 1), self.height);
        NSInteger orinCount = self.tableViews.count;
        NSInteger createCount = index - self.tableViews.count + 1;
        for (int i = 0;  i < createCount; i++) {
            NewestTableView *newestTableView = [[NewestTableView alloc] initWithFrame:CGRectMake(self.width * (orinCount + i), 0, self.width, self.height) style:UITableViewStylePlain];
            newestTableView.showsVerticalScrollIndicator = NO;
            newestTableView.delegate = self;
            [self addSubview:newestTableView];
            [self.tableViews addObject:newestTableView];
        }
    }
    if ([self.dataSource respondsToSelector:@selector(messageScrollViewWillShowTableViewWithIndex:)]) {
        [self.dataSource messageScrollViewWillShowTableViewWithIndex:index];
    }
}

- (void)dealReusableTablesView:(NSInteger)index {
 
    for (UITableView *tableView in self.tableViews) {
        
        if ([tableView isKindOfClass:[NewestTableView class]]) {
            
            NSInteger tbIndex = [self.tableViews indexOfObject:tableView];
            
            // remove
            if (tbIndex == index && [self.reusableTables containsObject:tableView]) {
                [self.reusableTables removeObject:tableView];
            }
            // add
            if (tbIndex != index && ![self.reusableTables containsObject:tableView]) {
                [self.reusableTables addObject:tableView];
            }
        }
        
    }
}

#pragma mark - 子视图切换时将上一个显示的表视图contentOffset.x至为0
- (void)resetSubPriorTableViewContentOffset {
    NSInteger index = self.contentOffset.x / self.width;
    if (self.currentIndex != index) {
        UITableView *priorTableView = self.tableViews[self.currentIndex];
        priorTableView.contentOffset = CGPointMake(0, 0);
    }
    self.currentIndex = index;
    [self dealReusableTablesView:index];
    if ([self.scrollDelegate respondsToSelector:@selector(messageScrollViewScrolledIndex:)]) {
        [self.scrollDelegate messageScrollViewScrolledIndex:index];
    }
}

#pragma mark - ChannelViewDelegate
- (void)channelViewTabClickedWithIndex:(NSInteger)index {
    if (index >= 0 && index < self.allChannelCount) {
        [self willShowTableViewWithIndex:index];
        [self setContentOffset:CGPointMake(self.width * index, 0) animated:NO];
        self.currentIndex = index;
        [self dealReusableTablesView:index];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        // 子视图代理逻辑
        // 处理滑动时子视图表视图和父视图表视图的位置关系
        [self scrollInteractionWithScrollView:scrollView];
        // 缓存清理
        [self disposeCleanMemoryImageWithScrollView:scrollView];
        // 当前表视图加载更多数据
        [self loadMoreInteractionWithScrollView:scrollView];
        
    }else{
        // 处理当scrollView滑动时子视图的滑动是否可用
        [self subTableInteraction];
        // 处理当scrollView即将滑动到新的子视图位置即将显示的位置判断
        [self subTableShowJudge];
        
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self) {
        [self resetSubPriorTableViewContentOffset];
        self.isScrolling = NO;
        if (self.currentIndex == 0) {
            // 开启抽屉手势
            [self startDrawerGesture];
        }else{
            // 禁止抽屉手势
            [self stopDrawerGesture];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 判断tableView的class
    if ([tableView isMemberOfClass:[NewestTableView class]]) {
        
        SmallCellModel *model = [[tableView cellForRowAtIndexPath:indexPath] valueForKey:@"model"];
        [self.viewModel saveModelTag:model];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
        if ([model.newstype isEqualToString:@"图集"]) {
            ImageBrowserController *imageBroser = [[ImageBrowserController alloc] init];
            imageBroser.cellModel = model;
            [[self viewController].navigationController pushViewController:imageBroser animated:YES];
            
        }else{
            MessgeDetailController *detail = [[MessgeDetailController alloc] init];
            detail.cellModel = model;
            [[self viewController].navigationController pushViewController:detail animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        if (indexPath.section == 0 || indexPath.section == 1) {
            return 80;
        }
    }
    
    if ([tableView isMemberOfClass:[NewestTableView class]]) {
        NewestTableView *newestTable = (NewestTableView *)tableView;
        SmallCellModel *model = newestTable.models[indexPath.row];
        if ([model.newstype isEqualToString:@"图集"]) {
            return ATLAS_CELL_HEIGHT;
        }
        
    }
    
    return ORDINARY_CELL_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        SpecialTableView *specialTableView = (SpecialTableView *)tableView;
        NSInteger row = specialTableView.allDataList[section].count;
        if (section == 0 && row != 0) {
            return 30;
        }else if(section == 1 && row != 0) {
            return 30;
        }else if (section == 2 && row != 0){
            return 30;
        }else{
            return 1;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor  grayColor];
        [view addSubview:label];
        NSInteger row = [tableView numberOfRowsInSection:section];
        if (section == 0 && row != 0) {
            label.text = @"栏目推荐";
            return view;
        }else if(section == 1 && row != 0) {
            label.text = @"已订阅";
            return view;
        }else if (section == 2 && row != 0){
            label.text = @"未订阅";
            return view;
        }else{
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
            return line;
        }
        
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        return 1;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        return view;
    }
    return nil;
}

@end
