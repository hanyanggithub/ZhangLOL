//
//  ChannelView.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChannelViewDelegate <NSObject>

- (void)channelViewTabClickedWithIndex:(NSInteger)index;

@end


@interface ChannelView : UIView
@property(nonatomic, weak)id<ChannelViewDelegate>delegate;
- (void)updateWithChannelModels:(NSArray *)models;
- (NSInteger)channelCount;

@end
