//
//  ChannelView.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAX_TAB_COUNT 5
#define TAB_MIN_WIDTH (SCREEN_WIDTH / MAX_TAB_COUNT)
#define CHANNELBAR_HEIGHT 44.0


@protocol ChannelViewDelegate <NSObject>

- (void)channelViewTabClickedWithIndex:(NSInteger)index;

@end


@interface ChannelView : UIView
@property(nonatomic, weak)id<ChannelViewDelegate>delegate;
- (void)updateWithChannelModels:(NSArray *)models;

@end
