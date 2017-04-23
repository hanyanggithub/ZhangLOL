//
//  SpecialExtraCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SpecialExtraCell.h"
#import "SpecialModel.h"
@interface SpecialExtraCell ()
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIImageView *titleImage;
@property(nonatomic, strong)UILabel *title;
@property(nonatomic, strong)UILabel *subTitle;

@property(nonatomic, strong)UIImageView *rightArrow;
@property(nonatomic, strong)UILabel *time;
@property(nonatomic, strong)UIButton *bookButton;


@end


@implementation SpecialExtraCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 3;
        
        self.titleImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.titleImage.layer.cornerRadius = 25;
        self.titleImage.layer.masksToBounds = YES;
        
        
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:16.0];
        
        self.subTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subTitle.textColor = [UIColor grayColor];
        self.subTitle.numberOfLines = 0;
        self.subTitle.font = [UIFont systemFontOfSize:13.0];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectZero];
        self.time.textColor = [UIColor grayColor];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.font = [UIFont systemFontOfSize:11.0];
        
        self.rightArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightArrow.image = [UIImage imageNamed:@"news_topic_arrow_view"];
        
        self.bookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bookButton.hidden = YES;
        [self.bookButton setBackgroundImage:[UIImage imageNamed:@"news_special_column_unsubscribe_normal"] forState:UIControlStateNormal];
        [self.bookButton setBackgroundImage:[UIImage imageNamed:@"news_special_column_unsubscribe_press"] forState:UIControlStateHighlighted];
        
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.titleImage];
        [self.containerView addSubview:self.title];
        [self.containerView addSubview:self.subTitle];
        [self.containerView addSubview:self.time];
        [self.containerView addSubview:self.rightArrow];
        [self.containerView addSubview:self.bookButton];
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(6.0);
            make.right.equalTo(self.contentView).offset(-6.0);
            make.top.equalTo(self.contentView).offset(2.0);
            make.bottom.equalTo(self.contentView).offset(-2.0);
        }];
        
        [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(10.0);
            make.width.equalTo(@(50));
            make.top.equalTo(self.containerView).offset(10.0);
            make.height.equalTo(@(50));
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleImage.mas_right).offset(10.0);
            make.width.equalTo(@(200));
            make.top.equalTo(self.containerView).offset(10.0);
            make.height.equalTo(@(20.0));
        }];
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView).offset(-5.0);
            make.width.equalTo(@(10.0));
            make.centerY.equalTo(self.contentView);
            make.height.equalTo(@(15.0));
        }];
        [self.bookButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rightArrow.mas_left);
            make.width.equalTo(@(60.0));
            make.centerY.equalTo(self.contentView);
            make.height.equalTo(@(30.0));
        }];

        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rightArrow.mas_left).offset(-1.0);
            make.width.equalTo(@(60));
            make.centerY.equalTo(self.contentView);
            make.height.equalTo(@(20.0));
            
        }];
        
        [self.subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.time.mas_left);
            make.top.equalTo(self.title.mas_bottom).offset(1.0);
            make.bottom.equalTo(self.containerView).offset(-5.0);
        }];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        SpecialModel *model = (SpecialModel *)self.model;
        [self.titleImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@"locate_view_head_default_icon"] options:SDWebImageProgressiveDownload|SDWebImageRetryFailed];
        self.title.text = model.col_title;
        self.subTitle.text = model.last_news_title;
        self.time.text = [NSString stringWithFormat:@"%@更新",[self dealTimeWithDateString:model.last_update]];
        if (![model.type isEqualToString:@"2"]) {
            self.time.hidden = YES;
            self.rightArrow.hidden = YES;
            self.bookButton.hidden = NO;
        }else{
            self.time.hidden = NO;
            self.rightArrow.hidden = NO;
            self.bookButton.hidden = YES;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
