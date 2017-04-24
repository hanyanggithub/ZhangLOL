//
//  RefreshHeaderView.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RefreshHeaderView.h"

#define REFRESH_HEADER_HEIGHT 200.0                 // 自身的高度
#define REFRESH_TRIGGER_HEIGHT 70.0                 // 触发高度(触发偏移量)

NSString * const refreshHeaderViewDownSlideRefreshText = @"下拉刷新";
NSString * const refreshHeaderViewLoosenRefreshText = @"释放刷新";
NSString * const refreshHeaderViewRefreshingText = @"刷新中";

@interface RefreshHeaderView ()

@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView *bgView;
@property(nonatomic, assign)RefreshHeaderViewStatus status;
@property(nonatomic, copy)void(^block)(RefreshHeaderViewStatus);
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, assign)CGRect containerViewOriginalFrame;// 内容视图的初始位置
@property(nonatomic, strong)UIImageView *animationView;
@property(nonatomic, strong)UILabel *tipLabel;
@property(nonatomic, assign)CGRect originalFrame; // 自身的初始位置
@property(nonatomic, strong)NSDate *startDate;    // 记录开始执行下拉刷新的时间
@property(nonatomic, assign)RefreshHeaderViewLocation location;    // 初始化的位置类型

@end


@implementation RefreshHeaderView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView location:(RefreshHeaderViewLocation)location {
    
    CGRect selfFrame;
    if (location == RefreshHeaderViewLocationTopEqualToScrollViewTop) {
        selfFrame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, REFRESH_HEADER_HEIGHT);
    }else{
        selfFrame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y - REFRESH_HEADER_HEIGHT, scrollView.frame.size.width, REFRESH_HEADER_HEIGHT);
    }
    self = [super initWithFrame:selfFrame];
    if (self) {
        self.originalFrame = self.frame;
        self.scrollView = scrollView;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.location = location;
        [self.scrollView.superview insertSubview:self belowSubview:self.scrollView];
        // 背景图片
        self.bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.bgView];
        
        // 内容视图的位置
        if (location == RefreshHeaderViewLocationTopEqualToScrollViewTop) {
            self.containerViewOriginalFrame = CGRectMake((self.frame.size.width - 60) * 0.5, 10, 60, 60);
        }else{
            self.containerViewOriginalFrame = CGRectMake((self.frame.size.width - 60) * 0.5, self.frame.size.height - 60, 60, 60);
        }
        self.containerView = [[UIView alloc] initWithFrame:self.containerViewOriginalFrame];
        [self addSubview:self.containerView];
        
        self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake((self.containerView.frame.size.width - 34) * 0.5, 0, 34, 34)];
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 8; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"personal_refresh_loading2%d",i]]];
        }
        self.animationView.image =[UIImage imageNamed:@"personal_refresh_loading21"];
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 0.35; // 一张0.05秒 20fps
        [self.containerView addSubview:self.animationView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.animationView.frame), self.containerView.frame.size.width, self.containerView.frame.size.height - self.animationView.frame.size.height)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont systemFontOfSize:10];
        self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
        self.tipLabel.textColor = [UIColor blackColor];
        [self.containerView addSubview:self.tipLabel];
        
        
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.scrollView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    NSNumber *new = change[NSKeyValueChangeNewKey];
    NSNumber *old = change[NSKeyValueChangeOldKey];
    
    // 没有单元格隐藏
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newContentSize = new.CGSizeValue;
        if (newContentSize.height == 0) {
            self.hidden = YES;
        }else{
            self.hidden = NO;
        }
    }
    
    if (!self.hidden) {
        // 监听滑动手势的状态结束时判断滑动视图的偏移量决定是否开始刷新
        if ([keyPath isEqualToString:@"panGestureRecognizer.state"]) {
            NSInteger newState = new.integerValue;
            if (newState == UIGestureRecognizerStateEnded && -self.scrollView.contentOffset.y > REFRESH_TRIGGER_HEIGHT) {
                [self startRefreshing];
            }
        }
        
        
        // 监听位移量变化控制位置变化和文本显示内容
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint pointNew = new.CGPointValue;
            CGPoint pointOld = old.CGPointValue;
            CGFloat newY = pointNew.y;
            CGFloat oldY = pointOld.y;
            // 跟随scrollView移动
            if (self.location == RefreshHeaderViewLocationTopEqualToScrollViewTop) {
                if (-newY > REFRESH_TRIGGER_HEIGHT) {
                    CGFloat increment =  ABS(newY) - REFRESH_TRIGGER_HEIGHT;
                    self.containerView.frame = CGRectMake(self.containerViewOriginalFrame.origin.x, self.containerViewOriginalFrame.origin.y + increment, self.containerViewOriginalFrame.size.width, self.containerViewOriginalFrame.size.height);
                }else{
                    self.containerView.frame = self.containerViewOriginalFrame;
                }
            }else{
                if (newY < 0) {
                    CGFloat increment =  ABS(newY);
                    self.frame = CGRectMake(self.originalFrame.origin.x, self.originalFrame.origin.y + increment, self.originalFrame.size.width, self.originalFrame.size.height);
                }else{
                    self.frame = self.originalFrame;
                }
            }
            
            // 下滑时期
            if (oldY >= newY) {
                if (newY >= 0) {
                    self.status = RefreshHeaderViewStatusWaitUserSlideDown;
                    self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
                    
                }else if (newY > -REFRESH_TRIGGER_HEIGHT) {
                    self.status = RefreshHeaderViewStatusUserSlidingDown;
                    self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
                }else{
                    self.status = RefreshHeaderViewStatusWaitUserLoosen;
                    self.tipLabel.text = refreshHeaderViewLoosenRefreshText;
                    
                }
            }else{
                // 上滑时期
                if (oldY >= 0) {
                    if (self.status != RefreshHeaderViewStatusRefreshing) {
                        self.status = RefreshHeaderViewStatusWaitUserSlideDown;
                        self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
                    }
                }else if (oldY > -REFRESH_TRIGGER_HEIGHT) {
                    if (self.status != RefreshHeaderViewStatusRefreshing) {
                        self.status = RefreshHeaderViewStatusUserSlidingDown;
                        self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
                    }
                    
                }else{
                    
                    if (self.status != RefreshHeaderViewStatusRefreshing) {
                        if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
                            self.status = RefreshHeaderViewStatusWaitUserLoosen;
                            self.tipLabel.text = refreshHeaderViewLoosenRefreshText;
                            
                        }
                    }
                }
            }
        }
    }
}
- (void)setStatus:(RefreshHeaderViewStatus)status {
    if (_status != status) {
        _status = status;
        if (self.block) {
            self.block(status);
        }
    }
}
- (void)refreshHeaderViewStatusChangedBlock:(void (^)(RefreshHeaderViewStatus))block {
    self.block = block;
}

- (RefreshHeaderViewStatus)currentStatus {
    return self.status;
}
- (void)startRefreshing {
    self.status = RefreshHeaderViewStatusRefreshing;
    self.startDate = [NSDate date];
    self.scrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_TRIGGER_HEIGHT, 0, 0, 0);
        self.containerView.frame = self.containerViewOriginalFrame;
    } completion:^(BOOL finished) {
        [self.animationView startAnimating];
        self.tipLabel.text = refreshHeaderViewRefreshingText;
    }];
}
- (void)stopRefreshing {
    if (self.status == RefreshHeaderViewStatusRefreshing) {
        double a = self.startDate.timeIntervalSinceNow;
        if (-a < 1.0) {
            [self performSelector:@selector(stopAction) withObject:nil afterDelay:1.0];
        }else{
            [self stopAction];
        }
    }
}
- (void)stopAction {
    [self.animationView stopAnimating];
    [UIView animateWithDuration:0.35 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        self.tipLabel.text = refreshHeaderViewDownSlideRefreshText;
        self.scrollView.userInteractionEnabled = YES;
        self.status = RefreshHeaderViewStatusWaitUserSlideDown;
    }];
}
- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
}
@end
