//
//  SmallCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SmallCell.h"
#import "SmallCellModel.h"

@interface SmallCell ()

@property(nonatomic, strong)UIImageView *titleImage;

@end

@implementation SmallCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.titleImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.bigContainerView addSubview:self.titleImage];
        
        [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bigContainerView).offset(ORDINARY_CELL_IMAGE_MARGIN_LEFT);
            make.width.equalTo(@(ORDINARY_CELL_IMAGE_WIDTH));
            make.centerY.equalTo(self.bigContainerView);
            make.height.equalTo(@(ORDINARY_CELL_IMAGE_HEIGHT));
        }];
        
        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImage.mas_right).offset(ORDINARY_CELL_TITLE_LEFT_SPACE);
            make.width.equalTo(@(60));
            make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
            make.height.equalTo(@(ORDINARY_CELL_TIME_HEIGHT));
            
        }];
        
        [self.readed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.time.mas_right).offset(ORDINARY_CELL_READ_LEFT_SPACE);
            make.width.equalTo(@(50.0));
            make.bottom.equalTo(self.time);
            make.height.equalTo(self.time);
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImage.mas_right).offset(ORDINARY_CELL_TITLE_LEFT_SPACE);
            make.right.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TITLE_MARGIN_RIGHT);
            make.top.equalTo(self.bigContainerView).offset(ORDINARY_CELL_TITLE_MARGIN_TOP);
            make.height.equalTo(@(ORDINARY_CELL_TITLE_HEIGHT));
        }];
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.title);
            make.top.equalTo(self.title.mas_bottom).offset(ORDINARY_CELL_CONTENT_TOP_SPACE);
            make.bottom.equalTo(self.time.mas_top).offset(-ORDINARY_CELL_CONTENT_BOTTOM_SPACE);
        }];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        SmallCellModel *model = (SmallCellModel *)self.model;
        [self.titleImage sd_setImageWithURL:[NSURL URLWithString:model.image_url_small] placeholderImage:[UIImage imageNamed:@"place"] options:SDWebImageProgressiveDownload|SDWebImageRetryFailed];
        
        // 计算实际的宽高
        CGSize timeSize = [self.time sizeThatFits:CGSizeZero];
        [self.time mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImage.mas_right).offset(ORDINARY_CELL_TITLE_LEFT_SPACE);
            make.width.equalTo(@(timeSize.width));
            make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
            make.height.equalTo(@(timeSize.height));
            
        }];
        // 计算阅读数实际宽度
        CGSize readedSize = [self.readed sizeThatFits:CGSizeZero];
        [self.readed mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.time.mas_right).offset(ORDINARY_CELL_READ_LEFT_SPACE);
            make.width.equalTo(@(readedSize.width));
            make.bottom.equalTo(self.time);
            make.height.equalTo(@(readedSize.height));
            
        }];
        
        // 计算内容实际高度
        CGFloat detailWidth = SCREEN_WIDTH - ORDINARY_CELL_HORIZONTAL_PADDING - ORDINARY_CELL_IMAGE_MARGIN_LEFT - ORDINARY_CELL_IMAGE_WIDTH  - ORDINARY_CELL_TITLE_LEFT_SPACE - ORDINARY_CELL_TITLE_MARGIN_RIGHT -  ORDINARY_CELL_HORIZONTAL_PADDING;
        CGSize detailSize = [self.detail sizeThatFits:CGSizeMake(detailWidth, 0)];
        // 计算最大高度
        CGFloat maxHeight = ORDINARY_CELL_HEIGHT - ORDINARY_CELL_VERTICAL_PADDING - ORDINARY_CELL_TITLE_MARGIN_TOP - ORDINARY_CELL_TITLE_HEIGHT - ORDINARY_CELL_CONTENT_TOP_SPACE - ORDINARY_CELL_CONTENT_BOTTOM_SPACE - timeSize.height - ORDINARY_CELL_TIME_MARGIN_BOTTOM - ORDINARY_CELL_VERTICAL_PADDING;
        CGFloat targetHeight = maxHeight;
        if (detailSize.height < maxHeight) {
            targetHeight = detailSize.height;
        }
        [self.detail mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(targetHeight));
            make.left.equalTo(self.title);
            make.right.equalTo(self.title);
            make.top.equalTo(self.title.mas_bottom).offset(ORDINARY_CELL_CONTENT_TOP_SPACE);
            
        }];
    }
}


@end
