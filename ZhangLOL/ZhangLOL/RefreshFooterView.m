//
//  RefreshFooterView.m
//  ZhangLOL
//
//  Created by mac on 17/4/21.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RefreshFooterView.h"

#define REFRESH_FOOTER_HEIGHT 70.0          // 自身的高度/触发的contentOffset为REFRESH_FOOTER_HEIGHT + scrollView.contentSize.height

NSString * const refreshFooterViewUpSlideRefreshText = @"上滑加载更多";
NSString * const refreshFooterViewLoosenRefreshText = @"释放加载更多";
NSString * const refreshFooterViewRefreshingText = @"努力获取中";

@interface RefreshFooterView ()

@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView *bgView;
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIImageView *animationView;
@property(nonatomic, assign)RefreshFooterViewStatus status;
@property(nonatomic, strong)UILabel *tipLabel;
@property(nonatomic, copy)void(^block)(RefreshFooterViewStatus status);
@property(nonatomic, assign)CGRect originalFrame;


@end

@implementation RefreshFooterView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {

    self = [super initWithFrame:CGRectMake(scrollView.frame.origin.x, CGRectGetMaxY(scrollView.frame), scrollView.frame.size.width, REFRESH_FOOTER_HEIGHT)];
    if (self) {
        self.scrollView = scrollView;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.scrollView.superview insertSubview:self belowSubview:self.scrollView];
        self.originalFrame = self.frame;
        
        self.bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.bgView];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 80) * 0.5, 0, 80, 60)];
        [self addSubview:self.containerView];
        
        self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake((self.containerView.frame.size.width - 34) * 0.5, 0, 34, 34)];
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 8; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"personal_refresh_loading2%d",i]]];
        }
        self.animationView.image = [UIImage imageNamed:@"personal_refresh_loading21"];
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 0.35; // 一张0.05秒 20fps
        [self.containerView addSubview:self.animationView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.animationView.frame), self.containerView.frame.size.width, self.containerView.frame.size.height - self.animationView.frame.size.height)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont systemFontOfSize:10];
        self.tipLabel.text = refreshFooterViewUpSlideRefreshText;
        self.tipLabel.textColor = [UIColor blackColor];
        [self.containerView addSubview:self.tipLabel];
        
        // add observer
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.scrollView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)setOtherScrollView:(UIScrollView *)scrollView {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    self.scrollView = scrollView;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.originalFrame = CGRectMake(scrollView.frame.origin.x, CGRectGetMaxY(scrollView.frame), scrollView.frame.size.width, REFRESH_FOOTER_HEIGHT);
    [self.scrollView.superview insertSubview:self belowSubview:self.scrollView];
    self.frame = self.originalFrame;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.scrollView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSNumber *new = change[NSKeyValueChangeNewKey];
    NSNumber *old = change[NSKeyValueChangeOldKey];
    
    CGFloat triggerY = REFRESH_FOOTER_HEIGHT + self.scrollView.contentSize.height;
    
    // 监听contentSize判断显示还是隐藏
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newContentSize = new.CGSizeValue;
        if (newContentSize.height >= self.scrollView.height) {
            if (self.hidden) {
                self.hidden = NO;
            }
        }else{
            if (!self.hidden) {
                self.hidden = YES;
            }
        }
    }
    
    // 不是隐藏态才相应事件
    if (!self.hidden) {
        // 监听滑动手势的状态结束时判断滑动视图的偏移量决定是否开始刷新
        if ([keyPath isEqualToString:@"panGestureRecognizer.state"]) {
            NSInteger newState = new.integerValue;
            if (newState == UIGestureRecognizerStateEnded && self.scrollView.contentOffset.y + self.scrollView.height > triggerY && self.status != RefreshFooterViewStatusRefreshing) {
                [self startRefreshing];
            }
        }
        
        // 监听位移量变化控制位置变化和文本显示内容
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint pointNew = new.CGPointValue;
            CGPoint pointOld = old.CGPointValue;
            CGFloat newY = pointNew.y;
            CGFloat oldY = pointOld.y;
            CGFloat newBottomY = newY + self.scrollView.height;
            // 位置变化
            if (newBottomY > self.scrollView.contentSize.height) {
                CGFloat increment =  newBottomY - self.scrollView.contentSize.height;
                self.frame = CGRectMake(self.frame.origin.x, self.originalFrame.origin.y - increment, self.frame.size.width, self.frame.size.height);
            }else{
                self.frame = self.originalFrame;
            }
            
            // 文本显示和状态设置
            // 上滑时期
            if (newY >= oldY) {
                CGFloat oldBottomY = oldY + self.scrollView.height;
                if (oldBottomY < triggerY) {
                    if (self.status != RefreshFooterViewStatusRefreshing) {
                    self.status = RefreshFooterViewStatusWaitRefreshing;
                    self.tipLabel.text = refreshFooterViewUpSlideRefreshText;
                    }
                }else{
                    if (self.status != RefreshFooterViewStatusRefreshing) {
                    self.status = RefreshFooterViewStatusWaitUserLoosen;
                    self.tipLabel.text = refreshFooterViewLoosenRefreshText;
                    }
                }
            }else{
                // 下滑时期
                if (newBottomY < triggerY) {
                    if (self.status != RefreshFooterViewStatusRefreshing) {
                        self.status = RefreshFooterViewStatusWaitRefreshing;
                        self.tipLabel.text = refreshFooterViewUpSlideRefreshText;
                    }
                }else{
                    if (self.status != RefreshFooterViewStatusRefreshing) {
                        self.status = RefreshFooterViewStatusWaitUserLoosen;
                        self.tipLabel.text = refreshFooterViewLoosenRefreshText;
                    }
                }
                
            }
        }
    }

}
- (void)setStatus:(RefreshFooterViewStatus)status {
    if (_status != status) {
        _status = status;
        if (self.block) {
            self.block(status);
        }
    }
}
- (void)refreshFooterViewStatusChangedBlock:(void(^)(RefreshFooterViewStatus status))block {
    self.block = block;
}
- (RefreshFooterViewStatus)currentStatus {
    return  self.currentStatus;
}
- (void)startRefreshing {
    self.status = RefreshFooterViewStatusRefreshing;
    self.tipLabel.text = refreshFooterViewRefreshingText;
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);
    } completion:^(BOOL finished) {
        [self.animationView startAnimating];
    }];
}
- (void)stopRefreshing {
    self.status = RefreshFooterViewStatusWaitRefreshing;
    self.tipLabel.text = refreshFooterViewUpSlideRefreshText;
    self.scrollView.contentInset = UIEdgeInsetsZero;
    [self.animationView stopAnimating];
}
- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

@end
