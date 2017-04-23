//
//  SettingTableViewCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SettingTableViewCell.h"

@interface SettingTableViewCell ()

@property(nonatomic, strong)UILabel *leftLabel;
@property(nonatomic, strong)UIImageView *tipView;
@property(nonatomic, strong)UILabel *rightLabel;

@end

@implementation SettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftLabel = [[UILabel alloc] init];
        self.leftLabel.textColor = [UIColor blackColor];
        self.leftLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.leftLabel];
        
        self.rightLabel = [[UILabel alloc] init];
        self.rightLabel.textColor = [UIColor grayColor];
        self.rightLabel.font = [UIFont systemFontOfSize:14];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        self.rightLabel.hidden = YES;
        [self.contentView addSubview:self.rightLabel];
        
        self.tipView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battle_kill_right_point"]];
        self.tipView.hidden = YES;
        [self.contentView addSubview:self.tipView];
        
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.height.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@(SCREEN_WIDTH * 0.25));
        }];
        
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.height.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.leftLabel.mas_right);
        }];
        
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-5);
            make.height.equalTo(@(8));
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@(8));
        }];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.leftLabel.text = self.leftTitle;
    if (self.rightViewStyle == SettingTableViewCellRightViewStyleLabel) {
        self.rightLabel.hidden = NO;
        self.tipView.hidden = YES;
        self.rightLabel.text = self.rightTitle;
    }else if(self.rightViewStyle == SettingTableViewCellRightViewStyleNewMessageTipView){
        self.rightLabel.hidden = YES;
        self.tipView.hidden = NO;
    }else{
        self.rightLabel.hidden = YES;
        self.tipView.hidden = YES;
    }
}

@end
