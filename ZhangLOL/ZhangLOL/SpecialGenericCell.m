//
//  SpecialGenericCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SpecialGenericCell.h"
#import "SpecialModel.h"
@interface SpecialGenericCell ()
@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIImageView *titleImage;
@property(nonatomic, strong)UILabel *title;
@property(nonatomic, strong)UILabel *author;
@property(nonatomic, strong)UILabel *booked;
@property(nonatomic, strong)UILabel *detail;

@property(nonatomic, strong)UIImageView *rightArrow;
@property(nonatomic, strong)UIButton *bookButton;

@end

@implementation SpecialGenericCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 3;
        
        self.titleImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.titleImage.layer.cornerRadius = 25;
        self.titleImage.layer.masksToBounds = YES;
        
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:16.0];
        
        self.author = [[UILabel alloc] initWithFrame:CGRectZero];
        self.author.textColor = [UIColor grayColor];
        self.author.font = [UIFont systemFontOfSize:11.0];
        
        self.booked = [[UILabel alloc] initWithFrame:CGRectZero];
        self.booked.textColor = [UIColor orangeColor];
        self.booked.font = [UIFont systemFontOfSize:11.0];
        
        self.detail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detail.textColor = [UIColor grayColor];
        self.detail.font = [UIFont systemFontOfSize:13.0];
        
        self.rightArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightArrow.image = [UIImage imageNamed:@"news_topic_arrow_view"];
        self.rightArrow.hidden = YES;
        self.bookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bookButton setBackgroundImage:[UIImage imageNamed:@"news_special_column_unsubscribe_normal"] forState:UIControlStateNormal];
        [self.bookButton setBackgroundImage:[UIImage imageNamed:@"news_special_column_unsubscribe_press"] forState:UIControlStateHighlighted];
        
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.titleImage];
        [self.containerView addSubview:self.title];
        [self.containerView addSubview:self.author];
        [self.containerView addSubview:self.booked];
        [self.containerView addSubview:self.detail];
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
        [self.author mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.width.equalTo(@(200));
            make.top.equalTo(self.title.mas_bottom).offset(5.0);
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
            make.top.equalTo(self.contentView).offset(20.0);
            make.height.equalTo(@(30.0));
        }];
        [self.booked mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.author.mas_right).offset(5.0);
            make.right.equalTo(self.bookButton.mas_left).offset(5.0);
            make.top.equalTo(self.title.mas_bottom).offset(5.0);
            make.height.equalTo(@(20.0));
            
        }];
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.title);
            make.right.equalTo(self.bookButton.mas_left);
            make.top.equalTo(self.booked.mas_bottom).offset(1.0);
            make.bottom.equalTo(self.containerView).offset(-5.0);
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model) {
        SpecialModel *model = (SpecialModel *)self.model;
        [self.titleImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage new] options:SDWebImageProgressiveDownload];
        self.title.text = model.col_title;
        self.author.text = model.author;
        CGSize titleSize = [self.author sizeThatFits:CGSizeZero];
        [self.author mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(titleSize.width + 6));
        }];
        // 判断登录状态
        if (/* DISABLES CODE */ (NO)) {
            self.booked.text = model.book_num;
        }else{
            self.booked.text = [NSString stringWithFormat:@"%ldW人已订阅",model.book_num.integerValue / 10000];
        }
        self.detail.text = model.col_des;
        
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
