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
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIImageView *titleImage;
@property(nonatomic, strong)UILabel *title;
@property(nonatomic, strong)UILabel *detail;
@property(nonatomic, strong)UILabel *time;
@property(nonatomic, strong)UILabel *readed;
@property(nonatomic, strong)UILabel *typeLabel;

@end

@implementation SmallCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 3;
        self.titleImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:16.0];
        self.detail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detail.textColor = [UIColor grayColor];
        self.detail.font = [UIFont systemFontOfSize:15.0];
        self.detail.textAlignment = NSTextAlignmentJustified;
        self.detail.numberOfLines = 0;
        self.time = [[UILabel alloc] initWithFrame:CGRectZero];
        self.time.textColor = [UIColor grayColor];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.font = [UIFont systemFontOfSize:11.0];
        self.readed = [[UILabel alloc] initWithFrame:CGRectZero];
        self.readed.textColor = [UIColor orangeColor];
        self.readed.textAlignment = NSTextAlignmentRight;
        self.readed.font = [UIFont systemFontOfSize:11.0];
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.typeLabel.font = [UIFont systemFontOfSize:11.0];
        self.typeLabel.textAlignment = NSTextAlignmentCenter;
        self.typeLabel.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.titleImage];
        [self.containerView addSubview:self.title];
        [self.containerView addSubview:self.detail];
        [self.containerView addSubview:self.time];
        [self.containerView addSubview:self.readed];
        [self.containerView addSubview:self.typeLabel];
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(6.0);
            make.right.equalTo(self.contentView).offset(-6.0);
            make.top.equalTo(self.contentView).offset(2.0);
            make.bottom.equalTo(self.contentView).offset(-2.0);
        }];
        
        [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(5.0);
            make.width.equalTo(@(100.0 * SCREEN_SCALE));
            make.top.equalTo(self.containerView).offset(3.0);
            make.height.equalTo(@(90.0));
        }];
        
        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView).offset(-5.0);
            make.width.equalTo(@(50));
            make.top.equalTo(self.containerView).offset(5.0);
            make.height.equalTo(@(20.0));
            
        }];
        [self.readed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView).offset(-5.0);
            make.width.equalTo(@(50.0));
            make.top.equalTo(self.time.mas_bottom).offset(10.0);
            make.height.equalTo(@(20.0));
        }];
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView).offset(-5.0);
            make.width.equalTo(@(50.0));
            make.bottom.equalTo(self.containerView).offset(-5.0);
            make.height.equalTo(@(20.0));
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImage.mas_right).offset(5.0);
            make.right.equalTo(self.time.mas_left).offset(-5.0);
            make.top.equalTo(self.containerView).offset(5.0);
            make.height.equalTo(@(20.0));
        }];
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.title);
            make.top.equalTo(self.title.mas_bottom).offset(1.0);
            make.bottom.equalTo(self.containerView).offset(-5.0);
        }];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        SmallCellModel *model = (SmallCellModel *)self.model;
        [self.titleImage sd_setImageWithURL:[NSURL URLWithString:model.image_url_small] placeholderImage:[UIImage new] options:SDWebImageProgressiveDownload];
        if (model.isRead) {
            self.title.textColor = [UIColor grayColor];
        }else{
            self.title.textColor = [UIColor blackColor];
        }
        self.title.text = model.title;
        self.detail.text = model.summary;
        self.time.text = [self dealTimeWithDateString:model.publication_date]; // 1日内显示几小时前，else显示日期
        NSString *readedStr = nil;
        if ([model.pv integerValue] >= 100000) {
            readedStr = [NSString stringWithFormat:@"%ld万阅",[model.pv integerValue]/10000];
        }else{
            readedStr = [NSString stringWithFormat:@"%.1f万阅",(float)([model.pv integerValue]/10000)];
        }
        self.readed.text = readedStr;
        [self setNewstypeWithNewsTypeId:model.newstype];
    }
}
- (void)setNewstypeWithNewsTypeId:(NSString *)str {
    if ([str isEqualToString:@""]) {
        self.typeLabel.hidden = YES;
        return;
    }else if ([str isEqualToString:@"视频"]) {
        self.typeLabel.textColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1];
        self.typeLabel.layer.borderColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1].CGColor;
    }else if ([str isEqualToString:@"战报"]) {
        self.typeLabel.textColor = [UIColor brownColor];
        self.typeLabel.layer.borderColor = [UIColor brownColor].CGColor;
    }else if ([str isEqualToString:@"俱乐部"]) {
        self.typeLabel.textColor = [UIColor purpleColor];
        self.typeLabel.layer.borderColor = [UIColor purpleColor].CGColor;
    }else if ([str isEqualToString:@"图集"]) {
        self.typeLabel.textColor = [UIColor orangeColor];
        self.typeLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    }else{
        self.typeLabel.textColor = [UIColor blackColor];
        self.typeLabel.layer.borderColor = [UIColor blackColor].CGColor;
    }
    self.typeLabel.text = str;
    CGSize size =  [self.typeLabel sizeThatFits:CGSizeMake(0, 0)];
    [self.typeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-5.0);
        make.width.equalTo(@(size.width + 6));
        make.bottom.equalTo(self.containerView).offset(-5.0);
        make.height.equalTo(@(20.0));
    }];
    self.typeLabel.hidden = NO;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
