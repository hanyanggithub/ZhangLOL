//
//  BaseTableViewCell.m
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    }
    return self;
}

- (NSString *)dealTimeWithDateString:(NSString *)time {
    if ([time isEqualToString:@""]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *pub_date = [formatter dateFromString:time];
    int p = ABS(pub_date.timeIntervalSinceNow);
    NSString *result = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:pub_date];
    
    NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    if (nowComponents.year > components.year) {
        // 不是本年
        result = [time substringToIndex:7];
    }else if (p > 3600 * 24){
        // 本年不是本日
        result = [time substringWithRange:NSMakeRange(5, 5)];
    }else{
        int hour = p / 3600;
        int mine = (p % 3600) / 60;
        int sec = (p % 3600) % 60;
        if (hour != 0) {
            result = [NSString stringWithFormat:@"%d小时前",hour];
        }else if (mine != 0){
            result = [NSString stringWithFormat:@"%d分钟前",mine];
        }else{
            result = [NSString stringWithFormat:@"%d秒前",sec];
        }
    }
    return result;
}

@end
