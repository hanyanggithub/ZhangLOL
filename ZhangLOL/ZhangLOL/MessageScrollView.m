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
#import "ChannelView.h"
#import "CacheManager.h"
@interface MessageScrollView ()<UITableViewDelegate,UIGestureRecognizerDelegate,ChannelViewDelegate>
@property(nonatomic, strong)NSMutableArray *reusableTables; // 可复用表视图
@property(nonatomic, strong)NSMutableArray *tableViews;     // 所有的子视图
@property(nonatomic, assign)CGPoint priorPoint;
@end

@implementation MessageScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createFirstTwoTableViews];
        self.currentIndex = 0;
        self.pagingEnabled = YES;
        self.delegate = self;
        self.directionalLockEnabled = YES;
        self.alwaysBounceHorizontal = YES;
    }
    return self;
}
- (void)createFirstTwoTableViews {
    self.contentSize = CGSizeMake(self.width * 2, self.height);
    NewestTableView *newestTableView = [[NewestTableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    newestTableView.showsVerticalScrollIndicator = NO;
    newestTableView.delegate = self;
    [self addSubview:newestTableView];
    [self.tableViews addObject:newestTableView];
    
    SpecialTableView *specialTableView = [[SpecialTableView alloc] initWithFrame:CGRectMake(self.width, 0, self.width, self.height) style:UITableViewStyleGrouped];
    specialTableView.showsVerticalScrollIndicator = NO;
    specialTableView.delegate = self;
    [self addSubview:specialTableView];
    [self.tableViews addObject:specialTableView];
}

- (NSMutableArray *)tableViews {
    if (_tableViews == nil) {
        _tableViews = [NSMutableArray array];
    }
    return _tableViews;
}
- (UITableView *)currentTableView {
    return self.tableViews[self.currentIndex];
}


- (void)updateTableViewsWithModels:(NSArray *)models index:(NSInteger)index info:(NSDictionary *)info {
    if (index < self.tableViews.count) {
        BaseTableView *tableView = self.tableViews[index];
        switch (index) {
            case 0:
                [tableView updateWithChannelModels:models];
                break;
            case 1:
                tableView.info = info;
                [tableView updateWithChannelModels:nil];
                break;
            default:
                break;
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
    }
    // 2.2 向下滑
    if (scrollDirection == UIScrollViewScrollDirectionDown) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
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
- (void)subTableInteractionWithScrollView:(UIScrollView *)scrollView {
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        for (UITableView *tableView in self.tableViews) {
            if (tableView.scrollEnabled) {
                tableView.scrollEnabled = NO;
            }
        }
    }
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) {
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

#pragma mark - 表视图复用处理
- (void)willShowTableViewWithIndex:(NSInteger)index {
    
}

#pragma mark - ChannelViewDelegate
- (void)channelViewTabClickedWithIndex:(NSInteger)index {
    if (index >= 0 && index < self.tableViews.count) {
        [self setContentOffset:CGPointMake(self.width * index, 0) animated:YES];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        // 子视图代理逻辑
        [self scrollInteractionWithScrollView:scrollView];
        [self disposeCleanMemoryImageWithScrollView:scrollView];
        [self loadMoreInteractionWithScrollView:scrollView];
        
    }else{
        // 本对象逻辑
        [self subTableInteractionWithScrollView:scrollView];
        UIScrollViewScrollDirection scrollDirection = [self scrollDirectionWithCurrentPoint:self.contentOffset];
        if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan && scrollDirection == UIScrollViewScrollDirectionRight) {
            NSLog(@"开始向右滑动");
        }
        if (scrollView.panGestureRecognizer.state ==  UIGestureRecognizerStateBegan && scrollDirection == UIScrollViewScrollDirectionLeft) {
            NSLog(@"开始向左滑动");
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self) {
        NSInteger index = scrollView.contentOffset.x / scrollView.width;
        if (self.currentIndex != index) {
            UITableView *priorTableView = self.tableViews[self.currentIndex];
            priorTableView.contentOffset = CGPointMake(0, 0);
        }        self.currentIndex = index;
        if ([self.scrollDelegate respondsToSelector:@selector(messageScrollViewScrolledIndex:)]) {
            [self.scrollDelegate messageScrollViewScrolledIndex:index];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self) {
        NSInteger index = scrollView.contentOffset.x / scrollView.width;
        if (self.currentIndex != index) {
            UITableView *priorTableView = self.tableViews[self.currentIndex];
            priorTableView.contentOffset = CGPointMake(0, 0);
        }
        self.currentIndex = index;
        if ([self.scrollDelegate respondsToSelector:@selector(messageScrollViewScrolledIndex:)]) {
            [self.scrollDelegate messageScrollViewScrolledIndex:index];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 判断tableView的class
    if ([tableView isMemberOfClass:[NewestTableView class]]) {
        MessgeDetailController *detail = [[MessgeDetailController alloc] init];
        detail.model = [[tableView cellForRowAtIndexPath:indexPath] valueForKey:@"model"];
        [detail.model setValue:@(1) forKey:@"isRead"];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self viewController].hidesBottomBarWhenPushed = YES;
        [[self viewController].navigationController pushViewController:detail animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isMemberOfClass:[SpecialTableView class]]) {
        if (indexPath.section == 0 || indexPath.section == 1) {
            return 80;
        }
    }
    return 100;
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
        view.backgroundColor = [UIColor clearColor];
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
            line.backgroundColor = [UIColor clearColor];
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
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    return nil;
}

@end
