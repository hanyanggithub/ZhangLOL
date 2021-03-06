//
//  ChannelView.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "ChannelView.h"
#import "ChannelModel.h"
#import "MessageScrollView.h"

#define CHANNELBAR_TAB_MIN_WIDTH   (SCREEN_WIDTH / CHANNELBAR_MAX_TAB_COUNT)

@interface ChannelView ()<MessageScrollViewDelegate>
@property(nonatomic, strong)NSMutableArray<UILabel *> *labels;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView *indicator;
@property(nonatomic, assign)NSInteger currentIndex;

@end

@implementation ChannelView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.currentIndex = 0;
        self.labels = [NSMutableArray array];
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_selected"]];
        self.indicator.hidden = YES;
        [self.scrollView addSubview:self.indicator];
    }
    return self;
}

- (void)updateWithChannelModels:(NSArray *)models {
    // 移除
    if (self.labels.count > 0 && models.count != self.labels.count) {
        [self.scrollView removeSubviews];
        [self.labels removeAllObjects];
    }
    // 创建
    if (self.labels.count == 0) {
        CGFloat tabWidth = 0;
        if (models.count < CHANNELBAR_MAX_TAB_COUNT) {
            tabWidth = SCREEN_WIDTH / models.count;
        }else{
            tabWidth = CHANNELBAR_TAB_MIN_WIDTH;
        }
        self.scrollView.contentSize = CGSizeMake(tabWidth * models.count, self.height);
        for (int i = 0; i < models.count; i++) {
            UIControl *tabContainer = [[UIControl alloc] initWithFrame:CGRectMake(i * tabWidth, 0, tabWidth, CHANNELBAR_HEIGHT)];
            [tabContainer addTarget:self action:@selector(clickedTab:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tabContainer.width * 0.2, tabContainer.height * 0.25, tabContainer.width * 0.6, tabContainer.height * 0.5)];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:CHANNELBAR_LABEL_FONT_SIZE];
            // 类型image
            UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(label.right, label.top - 6, 20, 12)];
            rightImageView.hidden = YES;
            [self.scrollView addSubview:tabContainer];
            [tabContainer addSubview:label];
            [tabContainer addSubview:rightImageView];
            [self.labels addObject:label];
        }
    }
    
    // 设置内容
    if (models.count <= self.labels.count) {
        for (int i = 0; i < models.count; i++) {
            UILabel *label = self.labels[i];
            ChannelModel *model = models[i];
            label.text = model.name;
            CGSize labelSize = [label sizeThatFits:CGSizeMake(0, label.height)];
            CGFloat containerViewWidth = label.superview.width;
            UIImageView *imageView = [label.superview.subviews lastObject];
            if (labelSize.width < containerViewWidth * 0.6) {
                // 调整label
                label.frame = CGRectMake((containerViewWidth - labelSize.width) * 0.5, label.top, labelSize.width, label.height);
                // 类型image
                imageView.frame = CGRectMake(label.right, label.top - 6, 20, 12);
            }
            if (i == self.currentIndex) {
                label.textColor = MAIN_COLOR;
            }
            if ([model.shownew isEqualToString:@"1"]) {
                imageView.image = [UIImage imageNamed:@"locate_view_attached_new"];
                imageView.hidden = NO;
            }
            if ([model.showhot isEqualToString:@"1"]) {
                imageView.image = [UIImage imageNamed:@"locate_view_attached_hot"];
                imageView.hidden = NO;
            }
        }
        // 设置indicator
        UILabel *label = [self.labels firstObject];
        self.indicator.frame = CGRectMake(label.left, label.bottom + 2, label.width, label.width/78.0 *11.0);
        self.indicator.hidden = NO;
        [self.scrollView bringSubviewToFront:self.indicator];
    }
}

- (void)clickedTab:(UIControl *)tabContainer {
    UILabel *label = [tabContainer.subviews firstObject];
    NSInteger index = [self.labels indexOfObject:label];
    // 做动作
    [self actionWithIndex:index];
    // 反馈
    if ([self.delegate respondsToSelector:@selector(channelViewTabClickedWithIndex:)]) {
        [self.delegate channelViewTabClickedWithIndex:index];
    }
    
}
#pragma mark - MessageScrollViewDelegate
- (void)messageScrollViewScrolledIndex:(NSInteger)index {
    if (index >= 0 && index < self.labels.count) {
        // 做动作
        [self actionWithIndex:index];
    }
}
- (void)actionWithIndex:(NSInteger)index {
    self.userInteractionEnabled = NO;
    // 1.清空选中状态
    UILabel *labelFont = [self.labels objectAtIndex:self.currentIndex];
    labelFont.textColor = [UIColor blackColor];
    // 2.scrollView滑动到某位置
    // 1.1 label.centerx - screenwidth /2.0
    UILabel *labelNow = [self.labels objectAtIndex:index];
    labelNow.textColor = MAIN_COLOR;
    
    UIView *container = labelNow.superview;
    // 将要滑动的位置 >0 && < contentOffset - self.width
    CGFloat target_x = container.center.x  - self.width * 0.5;
    // 边界判断
    if (target_x < 0) {
        target_x = 0;
    }
    if (target_x > self.scrollView.contentSize.width - self.width) {
        target_x = self.scrollView.contentSize.width - self.width;
    }
    [self.scrollView setContentOffset:CGPointMake(target_x, 0) animated:YES];
    
    // 2.indicator和label对应
    [UIView animateWithDuration:0.1 animations:^{
        self.indicator.center = CGPointMake(container.center.x, self.indicator.center.y);
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
    self.currentIndex = index;
}
- (NSInteger)channelCount {
    return  self.labels.count;
}
@end
