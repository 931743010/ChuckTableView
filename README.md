# ChuckTableView

高度封装tableView，简化操作

  1、容易操作的cell增删改查

  2、滚到最后

  3、可以自定义的上拉加载更多


# 例子

#初始化

- (id)initWithFrame:(CGRect)frame
              style:(UITableViewStyle)style
      defaultHeight:(CGFloat)height
         vcDelegate:(id)delegate
     configureBlock:(CellConfigureBefore)before
cellDidselectConfig:(CellDidselectConfigureBefore)cellDidselectConfigBefore;

  初始化后，就配置了基础的默认cell高度，cell的UI与model的默认配置和点击配置

#导入数据model,一个model对应一个cell

 1、不指定cell类型，就默认采用UITableViewCell

 [tableView addModel:@"我是XibAutpHeightCell，在s0,r0"];

 [tableView addModel:@"我是XibAutpHeightCell，在s0,r0" cellClass:XibAutpHeightCell.class];

 2、随意指定插入的section,不用担心数组越界的问题

 [tableView addModels:@[@"我在预设置里面,s2,r0",@"因为我是UItableViewCell,s2,r1"] section:2];

 3、编辑模式

 [tableView addModels:@[@"我是删除模式,s0,r2",@"我是删除模式,s0,r3"] cellClass:XibAutpHeightCell.class editStyle:UITableViewCellEditingStyleDelete];

#事件逻辑，在cell的m文件中导入#import "UITableViewCell+Smart.h"

cellForRow事件，与tableView等同名事件操作一致

- (void)tableView:(SmartTableView *)tableView vcDelegate:(id)vcDelegate cellForRowWithModel:(id)model atIndexPath:(NSIndexPath *)indexPath;

heightForRow事件，与tableView等同名事件操作一致，不设置在有约束情况下，自动计算高度，没有约束情况下，采用默认高度

- (CGFloat)tableView:(SmartTableView *)tableView vcDelegate:(id)vcDelegate heightForRowWithModel:(id)model atIndexPath:(NSIndexPath *)indexPath;

didSelectRowWithModel事件，与tableView等同名事件操作一致

-(void)tableView:(SmartTableView *)tableView vcDelegate:(id)vcDelegate didSelectRowWithModel:(id)model atIndexPath:(NSIndexPath *)indexPath;

编辑事件，与tableView等同名事件操作一致
- (void)tableView:(SmartTableView *)tableView vcDelegate:(id)vcDelegate commitEditingWithModel:(id)model style:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;


