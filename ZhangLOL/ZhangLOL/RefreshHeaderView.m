//
//  RefreshHeaderView.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RefreshHeaderView.h"

#define REFRESH_HEADER_HEIGHT 250.0
#define TRIGGER_HEIGHT 80.0


@interface RefreshHeaderView ()
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


- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    if (self) {
        self.scrollView = scrollView;
        self.oriFrame = CGRectMake((self.frame.size.width - 60.0) * 0.5, 20, 60, 60);
        self.containerView = [[UIView alloc] initWithFrame:self.oriFrame];
        self.containerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [self addSubview:self.containerView];
        
        self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake((self.oriFrame.size.width - 36.0) * 0.5, 0, 36, 36)];
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 8; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"personal_refresh_loading2%d",i]]];
        }
        self.fristFrame = [UIImage imageNamed:@"personal_refresh_loading21"];
        self.animationView.image = self.fristFrame;
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 0.35; // 一张0.05秒 20fps
        [self.containerView addSubview:self.animationView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.animationView.bottom, self.oriFrame.size.width, self.oriFrame.size.height - self.animationView.height)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont systemFontOfSize:10];
        self.tipLabel.text = @"下拉刷新";
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
        if (ABS(newY) > TRIGGER_HEIGHT) {
            CGFloat increment =  ABS(newY) - TRIGGER_HEIGHT;
            self.containerView.frame = CGRectMake(self.oriFrame.origin.x, self.oriFrame.origin.y + increment, self.oriFrame.size.width, self.oriFrame.size.height);
        }else{
            self.containerView.frame = self.oriFrame;
        }
        // 下滑时期
        if (oldY >= newY) {
            if (newY >= 0) {
                self.status = RefreshHeaderViewStatusWaitScroll;
                self.tipLabel.text = @"下拉刷新";
                
            }else if (newY > -TRIGGER_HEIGHT) {
                self.status = RefreshHeaderViewStatusScrolling;
                self.tipLabel.text = @"下拉刷新";
            }else{
                self.status = RefreshHeaderViewStatusWaitLoosen;
                self.tipLabel.text = @"释放刷新";
                
            }
        }else{
            // 上滑时期
            if (oldY >= 0) {
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    self.status = RefreshHeaderViewStatusWaitScroll;
                    self.tipLabel.text = @"下拉刷新";
                }
            }else if (oldY > -TRIGGER_HEIGHT) {
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    self.status = RefreshHeaderViewStatusScrolling;
                    self.tipLabel.text = @"下拉刷新";
                }
                
            }else{
                
                if (self.status != RefreshHeaderViewStatusRefreshing) {
                    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
                        self.status = RefreshHeaderViewStatusWaitLoosen;
                        self.tipLabel.text = @"释放刷新";
                
                    }
                }
            }
            
        }
        
    }else{
        NSInteger newState = new.integerValue;
        if (newState == UIGestureRecognizerStateEnded && -self.scrollView.contentOffset.y > TRIGGER_HEIGHT) {
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
        self.scrollView.contentInset = UIEdgeInsetsMake(TRIGGER_HEIGHT, 0, 0, 0);
        self.containerView.frame = self.oriFrame;
    } completion:^(BOOL finished) {
        [self.animationView startAnimating];
        self.tipLabel.text = @"刷新中";
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
        self.tipLabel.text = @"下拉刷新";
        self.scrollView.userInteractionEnabled = YES;
        self.status = RefreshHeaderViewStatusWaitScroll;
    }];
}


@end
