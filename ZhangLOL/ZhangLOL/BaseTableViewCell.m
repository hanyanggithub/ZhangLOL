//
//  BaseTableViewCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (NSString *)dealTimeWithDateString:(NSString *)time {
    if ([time isEqualToString:@""]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *pub_date = [formatter dateFromString:time];
    NSInteger p = ABS(pub_date.timeIntervalSinceNow);
    NSString *result = nil;
    if (p > 3600 * 24) {
        result = [time substringWithRange:NSMakeRange(5, 5)];
    }else{
        NSInteger hour = p / 3600;
        NSInteger mine = (p % 3600) / 60;
        NSInteger sec = (p % 3600) % 60;
        if (hour != 0) {
            result = [NSString stringWithFormat:@"%ld小时前",hour];
        }else if (mine != 0){
            result = [NSString stringWithFormat:@"%ld分钟前",mine];
        }else{
            result = [NSString stringWithFormat:@"%ld秒前",sec];
        }
    }
    return result;
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
