//
//  NewestBaseCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/18.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "NewestBaseCell.h"
#import "SmallCellModel.h"


@implementation NewestBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bigContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bigContainerView.backgroundColor = [UIColor whiteColor];
        self.bigContainerView.layer.cornerRadius = 3;
        
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:ORDINARY_CELL_TITLE_FONT_SIZE];
        
        self.detail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detail.textColor = [UIColor grayColor];
        self.detail.font = [UIFont systemFontOfSize:ORDINARY_CELL_CONTENT_FONT_SIZE];
        self.detail.numberOfLines = 0;
        
        self.time = [[UILabel alloc] initWithFrame:CGRectZero];
        self.time.textColor = [UIColor grayColor];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.font = [UIFont systemFontOfSize:ORDINARY_CELL_TIME_FONT_SIZE];
        
        self.readed = [[UILabel alloc] initWithFrame:CGRectZero];
        self.readed.textColor = MAIN_COLOR;
        self.readed.textAlignment = NSTextAlignmentRight;
        self.readed.font = [UIFont systemFontOfSize:ORDINARY_CELL_TIME_FONT_SIZE];
        
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.typeLabel.font = [UIFont systemFontOfSize:ORDINARY_CELL_TIME_FONT_SIZE];
        self.typeLabel.textAlignment = NSTextAlignmentCenter;
        self.typeLabel.layer.cornerRadius = 2.0;
        self.typeLabel.layer.borderWidth = 1.0;
        
        [self.contentView addSubview:self.bigContainerView];
        [self.bigContainerView addSubview:self.title];
        [self.bigContainerView addSubview:self.detail];
        [self.bigContainerView addSubview:self.time];
        [self.bigContainerView addSubview:self.readed];
        [self.bigContainerView addSubview:self.typeLabel];
        
        [self.bigContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(ORDINARY_CELL_HORIZONTAL_PADDING);
            make.right.equalTo(self.contentView).offset(-ORDINARY_CELL_HORIZONTAL_PADDING);
            make.top.equalTo(self.contentView).offset(ORDINARY_CELL_VERTICAL_PADDING);
            make.bottom.equalTo(self.contentView).offset(-ORDINARY_CELL_VERTICAL_PADDING);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TITLE_MARGIN_RIGHT);
            make.width.equalTo(@(60.0));
            make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
            make.height.equalTo(@(ORDINARY_CELL_TYPE_HEIGHT));
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        // 设置已读状态
        SmallCellModel *model = (SmallCellModel *)self.model;
        if (model.isRead) {
            self.title.textColor = [UIColor grayColor];
        }else{
            self.title.textColor = [UIColor blackColor];
        }
        // 设置标题内容
        self.title.text = model.title;
        // 设置时间内容
        self.time.text = [self dealTimeWithDateString:model.publication_date]; // 1日内显示几小时前，else显示日期
        
        // 设置阅读量内容
        NSString *readedStr = nil;
        if ([model.pv integerValue] >= 100000) {
            readedStr = [NSString stringWithFormat:@"%ld万阅",[model.pv integerValue]/10000];
        }else{
            readedStr = [NSString stringWithFormat:@"%.1f万阅",(float)([model.pv integerValue]/10000)];
        }
        self.readed.text = readedStr;
        
        // 设置详情
        self.detail.text = model.summary;
        // 设置信息类型标签
        [self setNewstypeWithNewsTypeId:model.newstype];
    }
}

- (void)setNewstypeWithNewsTypeId:(NSString *)str {
    if ([str isEqualToString:@""]) {
        self.typeLabel.hidden = YES;
        return;
    }else if ([str isEqualToString:@"视频"]) {
        self.typeLabel.textColor = [UIColor colorWithhHexString:@"#81c23d" Alpha:1.0];
        self.typeLabel.layer.borderColor = [UIColor colorWithhHexString:@"#81c23d" Alpha:1.0].CGColor;
    }else if ([str isEqualToString:@"战报"]) {
        self.typeLabel.textColor = MAIN_COLOR;
        self.typeLabel.layer.borderColor = MAIN_COLOR.CGColor;
    }else if ([str isEqualToString:@"俱乐部"]) {
        self.typeLabel.textColor = [UIColor purpleColor];
        self.typeLabel.layer.borderColor = [UIColor purpleColor].CGColor;
    }else if ([str isEqualToString:@"图集"]) {
        self.typeLabel.textColor = [UIColor orangeColor];
        self.typeLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    }else if ([str isEqualToString:@"活动"]){
        self.typeLabel.textColor = [UIColor colorWithhHexString:@"#00bfc8" Alpha:1.0];
        self.typeLabel.layer.borderColor = [UIColor colorWithhHexString:@"#00bfc8" Alpha:1.0].CGColor;
    }else if ([str isEqualToString:@"专题"]){
        self.typeLabel.textColor = [UIColor blueColor];
        self.typeLabel.layer.borderColor = [UIColor blueColor].CGColor;
    }else{
        self.typeLabel.textColor = [UIColor blackColor];
        self.typeLabel.layer.borderColor = [UIColor blackColor].CGColor;
    }
    self.typeLabel.text = str;
    // 计算占用宽度
    CGSize size =  [self.typeLabel sizeThatFits:CGSizeMake(0, 0)];
    [self.typeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TITLE_MARGIN_RIGHT);
        make.width.equalTo(@(size.width + 6));
        make.bottom.equalTo(self.bigContainerView).offset(-ORDINARY_CELL_TIME_MARGIN_BOTTOM);
        make.height.equalTo(@(ORDINARY_CELL_TYPE_HEIGHT));
    }];
    self.typeLabel.hidden = NO;
}

@end
