//
//  StarCardController.m
//  ChuckTableView
//
//  Created by 梁慧聪 on 2017/1/4.
//  Copyright © 2017年 liangdianxiong. All rights reserved.
//

#import "StarCardController.h"
#import "ChuckCollectionView.h"
#import "ChuckLayout.h"
#import "UtilScreenSize.h"

#import "CollectCellTopBar.h"
#import "CollectCellContent.h"
#import "CollectCellBottomBar.h"
@interface StarCardController ()<ChuckDelegate>
@property(nonatomic,strong)ChuckCollectionView* collect;
@property (nonatomic,strong)ChuckLayout * layout;
@end

@implementation StarCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.collect.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collect];
    
    [self.collect addModel:@"星卡详情" cellClass:CollectCellTopBar.class section:CellTopBar];
    [self.collect addModel:@"CellContent" cellClass:CollectCellContent.class section:CellContent];
    [self.collect addModel:@"CellContent" cellClass:CollectCellContent.class section:CellContent];
    [self.collect addModel:@"CellBottomBar" cellClass:CollectCellBottomBar.class section:CellBottomBar];
}
-(void)resetFrame{
    __weak typeof(self) wSelf = self;
    if (!CGSizeEqualToSize(self.collect.contentSize, CGSizeZero) ) {
        CGFloat height = self.view.frame.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            wSelf.collect.frame = CGRectMake(0, height - wSelf.collect.contentSize.height,wSelf.view.frame.size.width, wSelf.collect.contentSize.height);
        }];
    }
}
//转屏处理
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self resetFrame];
}
-(ChuckCollectionView *)collect{
    __weak typeof(self) wSelf = self;
    if (!_collect) {
        CGRect frame= self.view.bounds;
        frame.origin.y = frame.size.height;
        _collect =
        [[ChuckCollectionView alloc]
         initWithFrame:frame
         collectionViewLayout:self.layout
         vcDelegate:self
         configureBlock:^(UICollectionViewCell *cell, id model, NSIndexPath *indexPath) {
             NSUInteger section = indexPath.section;
             switch ([wSelf whichType:section]) {
                 case CellTopBar:
                     break;
                 case CellContent:
                     break;
                 case CellBottomBar:
                     break;
             }
             
         } cellDidselectConfig:^(UICollectionViewCell *cell, id model, NSIndexPath *indexPath) {
             NSLog(@"点击到什么：%@,%ld,%ld",model,indexPath.section,indexPath.item);
         }];
    }
    return _collect;
}
-(CellType)whichType:(NSInteger)section{
    if (section==0) return CellTopBar;
    if (self.collect?([self.collect numberOfSections]-1==section?YES:NO):NO) return CellBottomBar;
    return CellContent;
}
-(ChuckLayout *)layout{
    __weak typeof(self) wSelf = self;
    if (!_layout) {
        
        NSInteger perRow = 4;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        
        UIEdgeInsets sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        CGFloat interitemSpacing = PxToPt(10);
        CGFloat lineSpacing = PxToPt(1);
        CGFloat w = (width-interitemSpacing * (perRow -1) - sectionInset.left -sectionInset.right)/perRow * 1.0;
        CGFloat h = w/3.0 * 2;
        
        _layout = [[ChuckLayout alloc]initItemSize:^CGSize(id model,ChuckModel * chuckModel, NSInteger section) {
            switch ([wSelf whichType:section]) {
                case CellTopBar:
                    if ([model isEqualToString:@"星卡详情"]) {
                        return CGSizeMake(wSelf.view.frame.size.width,324.0/1324 * height);
                    }
                    return CGSizeMake(wSelf.view.frame.size.width,130.0/1324 * height);
                    break;
                case CellContent:
                    if ([model isEqualToString:@"CellContent"]) {
                        return CGSizeMake(wSelf.view.frame.size.width,130.0/1324 * height);
                    }
                    else if([model isEqualToString:@"CCellAcount"]){
                        return CGSizeMake(wSelf.view.frame.size.width,130.0/1324 * height);
                    }
                    return (CGSize){w,h};
                    break;
                case CellBottomBar:
                    return (CGSize){wSelf.view.frame.size.width,90.0/1324 * height};
                    break;
            }
        } interitemSpacingIndexPath:^CGFloat(id model,ChuckModel * chuckModel, NSInteger section) {
            return interitemSpacing;
        } lineSpacingIndexPath:^CGFloat(id model,ChuckModel * chuckModel, NSInteger section) {
            if([wSelf whichType:section]==CellContent) return PxToPt(2);
            return lineSpacing;
        } contentInsetIndexPath:^UIEdgeInsets(NSInteger section) {
            switch ([wSelf whichType:section]) {
                case CellTopBar:
                    return UIEdgeInsetsZero;
                    break;
                case CellContent:
                    return sectionInset;
                    break;
                case CellBottomBar:
                    return UIEdgeInsetsMake(5, 0, 0, 0);
                    break;
            }
        }];
    }
    return _layout;
}

#pragma mark ChuckDelegate
-(void)chuckContentSizeChange:(CGSize)contentSize{
    [self resetFrame];
}

@end
