//
//  SpecialTableView.m
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "SpecialTableView.h"
#import "SpecialExtraCell.h"
#import "SpecialGenericCell.h"

#define EXTRA_CELL_ID  @"SpecialExtraCellId"
#define GENERIC_CELL_ID  @"SpecialGenericCellId"

@interface SpecialTableView ()<UITableViewDataSource>



@end

@implementation SpecialTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.allDataList) {
        return self.allDataList.count;
    }else{
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.allDataList) {
        return self.allDataList[section].count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = nil;
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell = (SpecialExtraCell *)[tableView dequeueReusableCellWithIdentifier:EXTRA_CELL_ID];
        if (!cell) {
            cell = [[SpecialExtraCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EXTRA_CELL_ID];
        }
    }else {
        cell = (SpecialGenericCell *)[tableView dequeueReusableCellWithIdentifier:GENERIC_CELL_ID];
        if (!cell) {
            cell = [[SpecialGenericCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GENERIC_CELL_ID];
        }
    }
    cell.model = self.allDataList[indexPath.section][indexPath.row];
    return cell;
}
- (void)updateWithDataModels:(NSArray *)models dataInfo:(NSDictionary *)dataInfo {
    // 判断数据的变化(单个刷新单元格还是全刷)
    if (dataInfo) {
        self.dataInfo = dataInfo;
        NSArray *allDataList = dataInfo[@"data"];
        if (self.allDataList != allDataList) {
            self.allDataList = allDataList;
            [self reloadData];
        }
    }
}

@end
