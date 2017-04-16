//
//  MessageScrollView.h
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageScrollViewDelegate <NSObject>

- (void)messageScrollViewScrolledIndex:(NSInteger)index;

@end

@protocol MessageScrollViewDataSource <NSObject>

- (void)messageScrollViewSubTableViewShouldLoadMoreDataWithIndex:(NSInteger)index;
- (void)messageScrollViewWillShowTableViewWithIndex:(NSInteger)index;
@end


@interface MessageScrollView : UIScrollView
@property(nonatomic, weak)id<MessageScrollViewDelegate>scrollDelegate;
@property(nonatomic, weak)id<MessageScrollViewDataSource>dataSource;
@property(nonatomic, assign, readonly)NSInteger currentIndex;    // 当前显示的索引位置
@property(nonatomic, assign)NSInteger allChannelCount;           // 所有频道数
// 刷新子频道数据
- (void)updateTableViewsWithModels:(NSArray *)models index:(NSInteger)index info:(NSDictionary *)info;
// 当前显示的表视图
- (UITableView *)currentTableView;
@end
