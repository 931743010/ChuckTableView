//
//  SimpleController.m
//  ChuckTableView
//
//  Created by cong on 2016/10/30.
//  Copyright © 2016年 liangdianxiong. All rights reserved.
//

#import "SimpleController.h"
#import "ChuckTableView.h"
@interface SimpleController ()<ChuckDelegate>

@end

@implementation SimpleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ChuckTableView* tableView = nil;
    tableView = [[ChuckTableView alloc]
                 initWithFrame:self.view.bounds
                 style:0
                 heightForRow:^CGFloat(id cell, id model, NSIndexPath *indexPath) {
                     return 60;
                 }
                 vcDelegate:self
                 configureBlock:^(UITableViewCell* cell, id model, NSIndexPath *indexPath) {
                     
                     
                     cell.textLabel.text = model;
                     
                 } cellDidselectConfig:^(id cell, id model, NSIndexPath *indexPath) {
                     //默认点击cell配置
                     NSLog(@"点击到了：%@",model);
                     
                 }];
    
    [self.view addSubview:tableView];
    
    [tableView addModel:@"消息中心"];
    [tableView addModel:@"会员中心"];
    [tableView addModels:@[@"定时关闭",@"关于我们",@"退出登录"]];
    
    
}

@end
