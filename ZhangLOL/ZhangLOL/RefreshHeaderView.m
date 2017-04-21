//
//  RefreshHeaderView.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RefreshHeaderView.h"

#define REFRESH_HEADER_HEIGHT 250.0                 // 自身的高度
#define REFRESH_HEADER_BGVIEW_HEIGHT 80.0           // 背景视图高度
#define REFRESH_HEADER_TRIGGER_HEIGHT 70.0          // 触发高度(触发偏移量)
#define REFRESH_HEADER_CONTAINERVIEW_HEIGHT 60.0    // 内容视图的高度
#define REFRESH_HEADER_CONTAINERVIEW_WIDTH  60.0    // 内容视图的宽度
#define REFRESH_HEADER_ANIMATIONVIEW_HEIGHT 34.0    // 动画视图的高度
#define REFRESH_HEADER_ANIMATIONVIEW_WIDTH  34.0    // 动画视图的宽度
#define REFRESH_HEADER_TIPVIEW_HEIGHT  (REFRESH_HEADER_CONTAINERVIEW_HEIGHT -  REFRESH_HEADER_ANIMATIONVIEW_HEIGHT)   // 文字提示视图的高度

NSString * const downSlideRefresh = @"下拉刷新";
NSString * const loosenRefresh = @"释放刷新";
NSString * const refreshing = @"刷新中";

@interface RefreshHeaderView ()

@property(nonatomic, strong)UIImageView *bgView;
@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, assign)RefreshHeaderViewStatus status;
@property(nonatomic, copy)void(^block)(RefreshHeaderViewStatus);
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIImageView *animationView;
@property(nonatomic, strong)UIImage *fristFrame;
@property(nonatomic, strong)UILabel *tipLabel;
@property(nonatomic, assign)CGRect oriFrame; // 初始位置
@property(nonatomic, strong)NSDate *startDate;

@end


@implementation RefreshHeaderView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView location:(RefreshHeaderViewLocation)location
{
    
    self = [super initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    if (self) {
        self.scrollView = scrollView;
        // 背景
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, REFRESH_HEADER_BGVIEW_HEIGHT)];
        [self addSubview:self.bgView];
        
        // 内容视图的位置
        if (location == RefreshHeaderViewLocationTopEqualToScrollViewTop) {
            self.oriFrame = CGRectMake((self.frame.size.width - REFRESH_HEADER_CONTAINERVIEW_WIDTH) * 0.5, (REFRESH_HEADER_BGVIEW_HEIGHT - REFRESH_HEADER_CONTAINERVIEW_HEIGHT) * 0.5, REFRESH_HEADER_CONTAINERVIEW_WIDTH, REFRESH_HEADER_CONTAINERVIEW_HEIGHT);
        }else{
            self.oriFrame = CGRectMake((self.frame.size.width - REFRESH_HEADER_CONTAINERVIEW_WIDTH) * 0.5, (REFRESH_HEADER_BGVIEW_HEIGHT - REFRESH_HEADER_CONTAINERVIEW_HEIGHT) * 0.5, REFRESH_HEADER_CONTAINERVIEW_WIDTH, REFRESH_HEADER_CONTAINERVIEW_HEIGHT);
        }
        
        self.containerView = [[UIView alloc] initWithFrame:self.oriFrame];
        self.containerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [self addSubview:self.containerView];
        
        self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake((self.oriFrame.size.width - REFRESH_HEADER_ANIMATIONVIEW_WIDTH) * 0.5, 0, REFRESH_HEADER_ANIMATIONVIEW_WIDTH, REFRESH_HEADER_ANIMATIONVIEW_HEIGHT)];
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 8; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"personal_refresh_loading2%d",i]]];
        }
        self.fristFrame = [UIImage imageNamed:@"personal_refresh_loading21"];
        self.animationView.image = self.fristFrame;
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 0.35; // 一张0.05秒 20fps
        [self.containerView addSubview:self.animationView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.animationView.bottom, self.oriFrame.size.width, REFRESH_HEADER_TIPVIEW_HEIGHT)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont systemFontOfSize:10];
        self.tipLabel.text = downSlideRefresh;
        self.tipLabel.textColor = [UIColor blackColor];
        [self.containerView addSubview:self.tipLabel];
        
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.scrollView.superview insertSubview:self belowSubview:self.scrollView];
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
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint pointNew = new.CGPointValue;
        CGPoint pointOld = old.CGPointValue;
        CGFloat newY = pointNew.y;
        CGFloat oldY = pointOld.y;
        // 跟随scrollView移动
        if (ABS(newY) > REFRESH_HEADER_TRIGGER_HEIGHT && newY < 0) {
            CGFloat increment =  ABS(newY) - REFRESH_HEADER_TRIGGER_HEIGHT;
            self.containerView.frame = CGRectMake(self.oriFrame.origin.x, self.oriFrame.origin.y + increment, self.oriFrame.size.width, self.oriFrame.size.height);
        }else{
            self.containerView.frame = self.oriFrame;
        }
        // 下滑时期
        if (oldY >= newY) {
            if (newY >= 0) {
                self.status = RefreshHeaderViewStatusWaitUserSlideDown;
                self.tipLabel.text = downSlideRefresh;
                
            }else if (newY > -REFRESH_HEADER_TRIGGER_HEIGHT) {
                self.status = RefreshHeaderViewStatusUserSlidingDown;
                self.tipLabel.text = downSlideRefresh;
            }else{
                self.status = RefreshHeaderViewStatusWaitUserLoosen;
                self.tipLabel.text = loosenRefresh;
                
            }
        }else{
            // 上滑时期
            if (oldY >= 0) {
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    self.status = RefreshHeaderViewStatusWaitUserSlideDown;
                    self.tipLabel.text = downSlideRefresh;
                }
            }else if (oldY > -REFRESH_HEADER_TRIGGER_HEIGHT) {
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    self.status = RefreshHeaderViewStatusUserSlidingDown;
                    self.tipLabel.text = downSlideRefresh;
                }
                
            }else{
                
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
                        self.status = RefreshHeaderViewStatusWaitUserLoosen;
                        self.tipLabel.text = loosenRefresh;
                
                    }
                }
            }
            
        }
        
    }else{
        NSInteger newState = new.integerValue;
        if (newState == UIGestureRecognizerStateEnded && -self.scrollView.contentOffset.y > REFRESH_HEADER_TRIGGER_HEIGHT) {
            [self startRefreshing];
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
        self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_TRIGGER_HEIGHT, 0, 0, 0);
        self.containerView.frame = self.oriFrame;
    } completion:^(BOOL finished) {
        [self.animationView startAnimating];
        self.tipLabel.text = refreshing;
    }];
}
- (void)stopRefreshing {
    if (self.status == RefreshHeaderViewStatusRefreshing) {
        double a = self.startDate.timeIntervalSinceNow;
        if (a < 1.0) {
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
        self.tipLabel.text = downSlideRefresh;
        self.scrollView.userInteractionEnabled = YES;
        self.status = RefreshHeaderViewStatusWaitUserSlideDown;
    }];
}
- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
}
@end
