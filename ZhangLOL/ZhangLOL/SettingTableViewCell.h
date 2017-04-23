//
//  SettingTableViewCell.h
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SettingTableViewCellRightViewStyle) {
    SettingTableViewCellRightViewStyleNone,
    SettingTableViewCellRightViewStyleLabel,
    SettingTableViewCellRightViewStyleNewMessageTipView
};

@interface SettingTableViewCell : UITableViewCell
@property(nonatomic, copy)NSString *leftTitle;

@property(nonatomic, assign)SettingTableViewCellRightViewStyle rightViewStyle;
@property(nonatomic, copy)NSString *rightTitle;

@end
