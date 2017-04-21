//
//  HoverView.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "HoverView.h"
#import "ChannelModel.h"



@interface HoverView ()

@property(nonatomic, strong)NSMutableArray<UIButton *> *buttons;
@property(nonatomic, strong)NSArray *models;

@end

@implementation HoverView


- (void)updateWithModels:(NSArray *)models {
    self.models = models;
    if (models.count != self.buttons.count) {
        [self removeSubviews];
        [self.buttons removeAllObjects];
        self.backgroundColor = [UIColor whiteColor];
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        [self addSubview:bgView];
        CGFloat containerWidth = (SCREEN_WIDTH - HOVER_VIEW_UNIT_SPACE * (models.count - 1) - HOVER_VIEW_LEFT_RIGHT_SPACE * 2) / models.count;
        CGFloat containerHeight = HOVER_VIEW_HEIGHT - HOVER_VIEW_TOP_BOTTOM_SPACE * 2;
        // 创建
        for (int i = 0; i< models.count; i++) {
            
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(HOVER_VIEW_LEFT_RIGHT_SPACE + i * (containerWidth + HOVER_VIEW_UNIT_SPACE), HOVER_VIEW_TOP_BOTTOM_SPACE, containerWidth, containerHeight)];
            [bgView addSubview:containerView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithGes:)];
            [containerView addGestureRecognizer:tap];
            
            UILabel *title = [[UILabel alloc] init];
            title.font = [UIFont systemFontOfSize:HOVER_VIEW_TITLE_FONT_SIZE];
            title.textColor = [UIColor whiteColor];
            [containerView addSubview:title];
            
            UILabel *subTitle = [[UILabel alloc] init];
            subTitle.textColor = [UIColor whiteColor];
            subTitle.font = [UIFont systemFontOfSize:HOVER_VIEW_SUBTITLE_FONT_SIZE];
            [containerView addSubview:subTitle];
            
            UIImageView *logo = [[UIImageView alloc] init];
            logo.contentMode = UIViewContentModeScaleAspectFill;
            logo.clipsToBounds = YES;
            [containerView addSubview:logo];
            
            [logo mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(containerView);
                make.height.equalTo(@(containerHeight));
                make.width.equalTo(@(containerHeight));
                make.centerY.equalTo(containerView);
            }];
            
            [title mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(logo.mas_left);
                make.left.equalTo(containerView).offset(10);
                make.height.equalTo(@(20));
                make.top.equalTo(containerView).offset(5);
            }];
            
            [subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(logo.mas_left);
                make.left.equalTo(containerView).offset(10);
                make.height.equalTo(@(20));
                make.top.equalTo(title.mas_bottom).offset(5);
            }];
            
    
        }
    }
    // 赋值
    for (int i = 0; i< models.count; i++) {
        ChannelModel *model = self.models[i];
        
        UIView *containerView = [self.subviews firstObject].subviews[i];
        containerView.backgroundColor = [UIColor colorWithhHexString:model.bgcolor Alpha:1.0];
        
        UILabel *title = containerView.subviews[0];
        title.text = model.name;
        
        UILabel *subTitle = containerView.subviews[1];
        subTitle.text = model.subtitle;
        
        UIImageView *logo = containerView.subviews[2];
        [logo sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
    
    }
    
}
- (void)tapWithGes:(UITapGestureRecognizer *)tap {
    NSInteger index = [[self.subviews firstObject].subviews indexOfObject:tap.view];
    id model = self.models[index];
    NSLog(@"%@",model);
}


@end
