//
//  AtlasCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/18.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "AtlasCell.h"
#import "SmallCellModel.h"

@interface AtlasCell ()

@property(nonatomic, strong)UIView *atlasContainerView;
@property(nonatomic, strong)UIImageView *bigImageView;
@property(nonatomic, strong)UIImageView *smallTopImageView;
@property(nonatomic, strong)UIImageView *smallBottomImageView;
@property(nonatomic, strong)UIView *shadeView;
@property(nonatomic, strong)UILabel *picCount;

@end

@implementation AtlasCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.atlasContainerView = [[UIView alloc] init];
        [self.bigContainerView addSubview:self.atlasContainerView];
        
        self.bigImageView = [[UIImageView alloc] init];
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bigImageView.clipsToBounds = YES;
        [self.atlasContainerView addSubview:self.bigImageView];
        
        self.smallTopImageView = [[UIImageView alloc] init];
        self.smallTopImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.smallTopImageView.clipsToBounds = YES;
        [self.atlasContainerView addSubview:self.smallTopImageView];
        
        self.smallBottomImageView = [[UIImageView alloc] init];
        self.smallBottomImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.smallBottomImageView.clipsToBounds = YES;
        [self.atlasContainerView addSubview:self.smallBottomImageView];
        
        self.shadeView = [[UIView alloc] init];
        self.shadeView.backgroundColor = [UIColor blackColor];
        self.shadeView.alpha = 0.5;
        [self.smallBottomImageView addSubview:self.shadeView];
        
        self.picCount = [[UILabel alloc] init];
        self.picCount.textColor = [UIColor whiteColor];
        self.picCount.font = [UIFont boldSystemFontOfSize:14];
        self.picCount.textAlignment = NSTextAlignmentCenter;
        [self.smallBottomImageView addSubview:self.picCount];
        
        
        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bigContainerView).offset(ATLAS_CELL_TITLE_MARGIN_LEFT);
            make.width.equalTo(@(60));
            make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
            make.height.equalTo(@(20.0));
            
        }];
        
        [self.readed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.time.mas_right).offset(ORDINARY_CELL_READ_LEFT_SPACE);
            make.width.equalTo(@(50.0));
            make.bottom.equalTo(self.time);
            make.height.equalTo(@(20.0));
        }];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bigContainerView).offset(ATLAS_CELL_TITLE_MARGIN_LEFT);
            make.right.equalTo(self.bigContainerView).offset(-ATLAS_CELL_TITLE_MARGIN_RIGHT);
            make.top.equalTo(self.bigContainerView).offset(ATLAS_CELL_TITLE_MARGIN_TOP);
            make.height.equalTo(@(ATLAS_CELL_TITLE_HEIGHT));
        }];
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.title);
            make.top.equalTo(self.title.mas_bottom).offset(ATLAS_CELL_SUBTITLE_TOP_SPACE);
            make.height.equalTo(@(ATLAS_CELL_SUBTITLE_HEIGHT));
        }];
        
        [self.atlasContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.title);
            make.top.equalTo(self.detail.mas_bottom).offset(ATLAS_CELL_IMAGE_CONTAINER_TOP_SPACE);
            make.bottom.equalTo(self.typeLabel.mas_top).offset(-ATLAS_CELL_IMAGE_CONTAINER_BOTTOM_SPACE);
        }];
        
        [self.smallTopImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.atlasContainerView);
            make.top.equalTo(self.atlasContainerView);
            make.height.equalTo(@(ATLAS_CELL_SMALL_IMAGE_WIDTH));
            make.width.equalTo(@(ATLAS_CELL_SMALL_IMAGE_WIDTH));
        }];
        
        [self.smallBottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.atlasContainerView);
            make.bottom.equalTo(self.atlasContainerView);
            make.height.equalTo(@(ATLAS_CELL_SMALL_IMAGE_WIDTH));
            make.width.equalTo(@(ATLAS_CELL_SMALL_IMAGE_WIDTH));
        }];
        
        [self.bigImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.atlasContainerView);
            make.top.equalTo(self.atlasContainerView);
            make.bottom.equalTo(self.atlasContainerView);
            make.right.equalTo(self.smallTopImageView.mas_left).offset(-ATLAS_CELL_IMAGE_SPACE);
        }];
        
        [self.shadeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.smallBottomImageView);
            make.bottom.equalTo(self.smallBottomImageView);
            make.height.equalTo(self.smallBottomImageView);
            make.width.equalTo(self.smallBottomImageView);
        }];
        
        [self.picCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.smallBottomImageView);
            make.centerY.equalTo(self.smallBottomImageView);
            make.height.equalTo(@(20));
            make.width.equalTo(self.smallBottomImageView);
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        SmallCellModel *model = (SmallCellModel *)self.model;
        [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:model.big_image_url] placeholderImage:[UIImage imageNamed:@"place"] options:SDWebImageProgressiveDownload|SDWebImageRetryFailed];
        
        [self.smallTopImageView sd_setImageWithURL:[NSURL URLWithString:model.small_image_url] placeholderImage:[UIImage imageNamed:@"place"] options:SDWebImageProgressiveDownload|SDWebImageRetryFailed];
        
        [self.smallBottomImageView sd_setImageWithURL:[NSURL URLWithString:model.count_image_url] placeholderImage:[UIImage imageNamed:@"place"] options:SDWebImageProgressiveDownload|SDWebImageRetryFailed];
        
        self.picCount.text = [NSString stringWithFormat:@"%@张",model.count];
        
        CGSize timeSize = [self.time sizeThatFits:CGSizeZero];
        [self.time mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bigContainerView).offset(ATLAS_CELL_TITLE_MARGIN_LEFT);
            make.width.equalTo(@(timeSize.width));
            make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
            make.height.equalTo(@(20.0));
            
        }];
        
        CGSize readedSize = [self.readed sizeThatFits:CGSizeZero];
        [self.readed mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.time.mas_right).offset(ORDINARY_CELL_READ_LEFT_SPACE);
            make.width.equalTo(@(readedSize.width));
            make.bottom.equalTo(self.time);
            make.height.equalTo(@(20.0));
            
        }];
    }
    
}
@end
