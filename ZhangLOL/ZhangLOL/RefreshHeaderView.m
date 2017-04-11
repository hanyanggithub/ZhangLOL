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
        self.oriFrame = CGRectMake((self.frame.size.width - 40) / 2.0, 20, 40, 50);
        self.containerView = [[UIView alloc] initWithFrame:self.oriFrame];
        self.containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.containerView];
        
        self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 8; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"personal_refresh_loading2%d",i]]];
        }
        self.fristFrame = [UIImage imageNamed:@"personal_refresh_loading21"];
        self.animationView.image = self.fristFrame;
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 0.35; // 一张0.05秒 20fps
        [self.containerView addSubview:self.animationView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 40, 20)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont systemFontOfSize:9];
        self.tipLabel.text = @"下拉刷新";
        self.tipLabel.textColor = [UIColor blackColor];
        [self.containerView addSubview:self.tipLabel];
        
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.scrollView.superview insertSubview:self belowSubview:self.scrollView];
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    NSNumber *new = change[NSKeyValueChangeNewKey];
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint pointNew = new.CGPointValue;
        CGFloat newY = pointNew.y;
        
        if (newY >= 0) {
            if (self.status != RefreshHeaderViewStatusRefreshing) {
                self.status = RefreshHeaderViewStatusWaitScroll;
                self.tipLabel.text = @"下拉刷新";
            }
        }else if (newY > -TRIGGER_HEIGHT) {
            if (self.status != RefreshHeaderViewStatusRefreshing) {
                self.status = RefreshHeaderViewStatusScrolling;
                self.tipLabel.text = @"下拉刷新";
            }
            
        }else{
      
            if (self.scrollView.isDecelerating && self.status != RefreshHeaderViewStatusRefreshing) {
                // 刷新动画
                [self startRefreshing];
            }else if (self.status != RefreshHeaderViewStatusRefreshing){
                self.status = RefreshHeaderViewStatusWaitLoosen;
                self.tipLabel.text = @"释放刷新";
                // 跟随
                CGFloat v = ABS(newY) - (TRIGGER_HEIGHT - self.oriFrame.origin.y);
                self.containerView.frame = CGRectMake(self.oriFrame.origin.x, v, self.oriFrame.size.width, self.oriFrame.size.height);
                
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
