//
//  NewestTableView.m
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//


#import "NewestTableView.h"
#import "HoverView.h"
#import "SmallCell.h"

@interface NewestTableView ()<UITableViewDataSource>

@end

@implementation NewestTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
//        self.estimatedRowHeight = 100;
//        self.rowHeight = UITableViewAutomaticDimension;
        self.dataSource = self;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
//        HoverView * hoverView = [[HoverView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60)];
//        self.tableHeaderView = hoverView;

    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.models == nil) {
        return 0;
    }else{
        return self.models.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmallCell *cell = (SmallCell *)[tableView dequeueReusableCellWithIdentifier:@"smallCellId"];
    if (!cell) {
        cell = [[SmallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"smallCellId"];
    }
    cell.model = self.models[indexPath.row];
    return cell;
}
- (void)updateWithChannelModels:(NSArray *)models {
    [super updateWithChannelModels:models];
    // 判断数据的变化(单个刷新单元格还是全刷)
    

    self.models = models;
    [self reloadData];
}




@end
