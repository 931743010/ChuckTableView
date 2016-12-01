//
//  ChuckCollectionView.m
//  ChuckTableView
//
//  Created by 梁慧聪 on 2016/11/30.
//  Copyright © 2016年 liangdianxiong. All rights reserved.
//

#import "ChuckCollectionView.h"
#import "UICollectionViewCell+Chuck.h"
#import "UICollectionReusableView+Chuck.h"
#import "NSMutableArray+Chuck.h"
@implementation ChuckCollectionView

//基础配置
- (id)initWithFrame:(CGRect)frame
collectionViewLayout:(UICollectionViewLayout *)layout
    defaultHeadSize:(CGSize)headSize
    defaultFootSize:(CGSize)footSize
         vcDelegate:(id<ChuckDelegate>)delegate
     configureBlock:(CellConfigureBefore)before
cellDidselectConfig:(CellDidselectConfigureBefore)cellDidselectConfigBefore
headFootConfigureBefore:(HeadFootConfigureBefore) headFootConfigureBefore{
    if(self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.cellConfigureBefore = [before copy];
        self.cellDidselectConfigBefore = [cellDidselectConfigBefore copy];
        self.headFootConfigureBefore = [headFootConfigureBefore copy];
        self.delegate = self;
        self.dataSource = self;
        self.headSize= headSize;
        self.footSize = footSize;
        self.vcDelegate = delegate;

        //添加对Account的监听
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint p = [change[@"new"] CGPointValue];
        CGPoint op = [change[@"old"] CGPointValue];
        if (op.y < p.y) {
            //往下滚动
            CGFloat lastPageY = self.contentSize.height-self.frame.size.height;
            if (lastPageY - 20 < p.y && !self.showFootRefresh) {
                self.showFootRefresh = YES;
                [self reloadData];
            }
        }
    }
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}
-(NSMutableArray *)modelSource{
    if (!_modelSource) {
        _modelSource = [NSMutableArray array];
    }
    return _modelSource;
}
//自增量的sectionRow数组，添加元素，更改元素
//如果越界了就填充数据
-(void)ifBeyondSection:(NSInteger)section{
    //0 -->1
    if (section>=self.modelSource.count) {
        //填充足够的空数组
        for (NSInteger i=self.modelSource.count; i<section+1; i++) {
            [self.modelSource addObject:[[NSMutableArray alloc]init]];
        }
    }
}

#pragma mark -- 添加元素 --
//section 0
- (void)addModel:(id)model {
    [self addModel:model cellClass:UICollectionViewCell.class section:0];
}
- (void)addModels:(NSArray *)models {
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addModel:model];
    }
}
- (void)addModel:(id)model cellClass:(Class)cellClass{
    if(!model||![cellClass isSubclassOfClass:[UICollectionViewCell class]]) return;
    [self addModel:model cellClass:cellClass section:0 allowEdit:NO editStyle:UITableViewCellEditingStyleNone];
}
//section any
- (void)addModel:(id)model section:(NSInteger)section{
    [self addModel:model cellClass:UICollectionViewCell.class section:section];
}
- (void)addModels:(NSArray *)models section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addModel:model section:section];
    }
}
- (void)addModels:(NSArray *)models cellClass:(Class)cellClass section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addModel:model cellClass:cellClass section:section];
    }
}


//添加元素 -- start
- (void)addModel:(id)model cellClass:(Class)cellClass section:(NSInteger)section{
    if(!model||![cellClass isSubclassOfClass:[UICollectionViewCell class]]) return;
    [self addModel:model cellClass:cellClass section:section allowEdit:NO editStyle:UITableViewCellEditingStyleNone];
}
//添加元素 -- final
-(void)addModel:(id)model cellClass:(Class)cellClass section:(NSInteger)section allowEdit:(BOOL)edit editStyle:(UITableViewCellEditingStyle)editStyle{
    if(!model||![cellClass isSubclassOfClass:[UICollectionViewCell class]]) return;

    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self numberOfRowsAtSection:section] inSection:section];

    [self storeModel:model cellClass:cellClass allowEdit:edit editStyle:editStyle indexPath:indexPath];
}
//保存model
- (void)storeModel:(id)model cellClass:(Class)cellClass allowEdit:(BOOL)edit editStyle:(UITableViewCellEditingStyle)editStyle indexPath:(NSIndexPath *)indexPath{
    if(!model||![cellClass isSubclassOfClass:[UICollectionViewCell class]]) return;

    //保存model
    ChuckModel * chuckModel = [self configModel:model cellClass:cellClass allowEdit:edit editStyle:editStyle indexPath:indexPath];
    [self upSertModel:chuckModel indexPath:indexPath];

    //注册cell
    if (![self.config containsObject:NSStringFromClass(cellClass)]) {
        [self.config addObject:NSStringFromClass(cellClass)];
        [self registerCell:cellClass];
    }

}
#pragma -- model操作 --
//model - 插入或者更新model
-(void)upSertModel:(ChuckModel *)chuckModel indexPath:(NSIndexPath *)indexPath{
    if (![indexPath isKindOfClass:[NSIndexPath class]]) return;
    [self ifBeyondSection:indexPath.section];
    if (indexPath.row>=[self.modelSource[indexPath.section] count]) {
        //填充足够的空ChuckModel,
        for (NSInteger i=[self.modelSource[indexPath.section] count]; i<indexPath.row; i++) {
            [self.modelSource[indexPath.section] addObject:[[ChuckModel alloc]initEmptyIndexPath:chuckModel.indexPath]];
        }
        [self.modelSource[indexPath.section] addObject:chuckModel];
        return;
    }
    self.modelSource[indexPath.section][indexPath.row] = chuckModel;
}
//model
- (ChuckModel*)configModel:(id)model cellClass:(Class)cellClass allowEdit:(BOOL)edit editStyle:(UITableViewCellEditingStyle)editStyle indexPath:(NSIndexPath *)indexPath{
    return [[ChuckModel alloc]initWithModel:model cellClass:cellClass allowEdit:edit editStyle:editStyle indexPath:indexPath];
}
- (ChuckModel *)getModelAtIndexPath:(NSIndexPath *)indexPath{
    return self.modelSource[indexPath.section][indexPath.row];
}
-(HeadFootModel *)getHeadFootModelAtSection:(NSUInteger)section kind:(NSString *)kind{
    return  [kind isEqualToString:UICollectionElementKindSectionFooter]?[self getFootModelAtSection:section]:[self getHeadModelAtSection:section];
}
- (HeadFootModel *)getHeadModelAtSection:(NSUInteger)section{
    NSMutableArray * arr = self.modelSource[section];
    if (!arr.headModel) {
        arr.headModel = [[HeadFootModel alloc] initEmptySection:section];
    }
    return [self.modelSource[section] headModel];
}
- (HeadFootModel *)getFootModelAtSection:(NSUInteger)section{
    NSMutableArray * arr = self.modelSource[section];

    if (!arr.footModel) {
        arr.footModel = [[HeadFootModel alloc] initEmptySection:section];
    }
    return [self.modelSource[section] footModel];
}
//注册cell
-(void)registerCell:(Class)cellClass{
    NSString * nibpath =  [[NSBundle mainBundle] pathForResource:NSStringFromClass(cellClass) ofType:@"nib"];
    if ([nibpath isKindOfClass:[NSString class]]) {
        [self registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }else{
        [self registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
}
-(void)registerHeadFootCell:(Class)cellClass isFoot:(BOOL)isFoot{
    if (![cellClass isSubclassOfClass:[UICollectionReusableView class]]) {
        return;
    }
    NSString * nibpath =  [[NSBundle mainBundle] pathForResource:NSStringFromClass(cellClass) ofType:@"nib"];
    if ([nibpath isKindOfClass:[NSString class]]) {
        [self registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass)  bundle:nil]forSupplementaryViewOfKind:isFoot?UICollectionElementKindSectionFooter:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(cellClass)];
    }else{
        [self registerClass:cellClass forSupplementaryViewOfKind:isFoot?UICollectionElementKindSectionFooter:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(cellClass)];
    }
}
-(NSInteger)numberOfRowsAtSection:(NSInteger)section{
    [self ifBeyondSection:section];
    return [self.modelSource[section] count];
}
-(NSInteger)numberOfSection{
    return self.modelSource.count;
}
#pragma mark collectionViewHead&foot
//section 0
- (void)addHeadModel:(id)model{
    [self addHeadModel:model cellClass:UICollectionReusableView.class section:0];
}
- (void)addHeadModels:(NSArray *)models{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addHeadModel:model];
    }
}
- (void)addHeadModel:(id)model cellClass:(Class)cellClass{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [self addHeadFootModel:model cellClass:cellClass section:0 isFoot:NO editStyle:UITableViewCellEditingStyleNone];
}
//section any
- (void)addHeadModel:(id)model section:(NSInteger)section{
    [self addHeadModel:model cellClass:UICollectionReusableView.class section:section];
}
- (void)addHeadModels:(NSArray *)models section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addHeadModel:model section:0];
    }
}
- (void)addHeadModels:(NSArray *)models cellClass:(Class)cellClass section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addHeadModel:model cellClass:cellClass section:section];
    }
}


//section 0
- (void)addFootModel:(id)model{
    [self addFootModel:model cellClass:UICollectionReusableView.class section:0];
}
- (void)addFootModels:(NSArray *)models{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addFootModel:model];
    }
}
- (void)addFootModel:(id)model cellClass:(Class)cellClass{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [self addHeadFootModel:model cellClass:cellClass section:0 isFoot:YES editStyle:UITableViewCellEditingStyleNone];
}
//section any
- (void)addFootModel:(id)model section:(NSInteger)section{
    [self addFootModel:model cellClass:UICollectionReusableView.class section:section];
}
- (void)addFootModels:(NSArray *)models section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addFootModel:model section:0];
    }
}
- (void)addFootModels:(NSArray *)models cellClass:(Class)cellClass section:(NSInteger)section{
    if(![models isKindOfClass:[NSArray class]]) return;
    for (id model in models) {
        [self addFootModel:model cellClass:cellClass section:section];
    }
}


//添加head元素 -- start
- (void)addHeadModel:(id)model cellClass:(Class)cellClass section:(NSInteger)section{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [self addHeadFootModel:model cellClass:cellClass section:section isFoot:NO editStyle:UITableViewCellEditingStyleNone];
}
- (void)addFootModel:(id)model cellClass:(Class)cellClass section:(NSInteger)section{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [self addHeadFootModel:model cellClass:cellClass section:section isFoot:YES editStyle:UITableViewCellEditingStyleNone];
}
//添加head元素 -- final
-(void)addHeadFootModel:(id)model cellClass:(Class)cellClass section:(NSInteger)section isFoot:(BOOL)isFoot editStyle:(UITableViewCellEditingStyle)editStyle{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [self ifBeyondSection:section];//扩充大小
    [self storeHeadModel:model cellClass:cellClass isFoot:isFoot editStyle:editStyle section:section];
}
//保存model
- (void)storeHeadModel:(id)model cellClass:(Class)cellClass isFoot:(BOOL)isFoot editStyle:(UITableViewCellEditingStyle)editStyle section:(NSUInteger)section{
    if(!model||![cellClass isSubclassOfClass:[UICollectionReusableView class]]) return;

    //保存model
    NSMutableArray * chuckMutableArray = self.modelSource[section];
    if (isFoot) {
        chuckMutableArray.footModel = [[HeadFootModel alloc]initWithHeadFootModel:model
                                                                        cellClass:cellClass
                                                                             kind:UICollectionElementKindSectionFooter
                                                                        editStyle:editStyle
                                                                          section:section];
    }else{
        chuckMutableArray.headModel = [[HeadFootModel alloc]initWithHeadFootModel:model
                                                                        cellClass:cellClass
                                                                             kind:UICollectionElementKindSectionHeader
                                                                        editStyle:editStyle
                                                                          section:section];
    }


    //注册cell
    if (![self.config containsObject:NSStringFromClass(cellClass)]) {
        [self.config addObject:NSStringFromClass(cellClass)];
        [self registerHeadFootCell:cellClass isFoot:isFoot];
    }

}
#pragma mark UICollectionViewDataSource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellforChuckModel:(ChuckModel *)chuckModel forIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:chuckModel.identifier forIndexPath:indexPath];
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView reusableViewforHeadFootModel:(HeadFootModel *)headFootModel section:(NSUInteger)section{
    
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:headFootModel.kind
                                       withReuseIdentifier:headFootModel.identifier
                                              forIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    return view;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self numberOfRowsAtSection:section];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    //normal cell
    ChuckModel *chuckModel = [self getModelAtIndexPath:indexPath];
    UICollectionViewCell *cell = [self collectionView:collectionView cellforChuckModel:chuckModel forIndexPath:indexPath];
    id model = chuckModel.model;

    if(self.cellConfigureBefore) {
        self.cellConfigureBefore(cell, model,indexPath);
    }
    if ([cell respondsToSelector:@selector(collectionView:vcDelegate:cellForRowWithModel:atIndexPath:)]) {
        [cell collectionView:self vcDelegate:self.vcDelegate cellForRowWithModel:model atIndexPath:indexPath];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeadFootModel * headFootModel = [self getHeadFootModelAtSection:indexPath.section kind:kind];
    UICollectionReusableView *view = [self collectionView:collectionView reusableViewforHeadFootModel:headFootModel section:indexPath.section];
    id model = headFootModel.model;
    if(self.headFootConfigureBefore) {
        self.headFootConfigureBefore(view, model,kind,indexPath.section);
    }
    return view;
}
//返回头headerView的大小
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    CGSize size=self.headSize;
//    HeadFootModel * headFootModel = [self getHeadFootModelAtSection:section];
//    UICollectionReusableView *view = [self collectionView:collectionView reusableViewforHeadFootModel:headFootModel section:section];
//    if ([view respondsToSelector:@selector(collectionView:layout:model:referenceSizeForHeaderInSection:)]) {
//        return  [view collectionView:self layout:collectionViewLayout model:headFootModel.model referenceSizeForHeaderInSection:section];
//    }
//
//    if (![view isMemberOfClass:[UICollectionReusableView class]]) {
//        [view layoutIfNeeded];
//        [view updateConstraintsIfNeeded];
//        size = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//        if (CGSizeEqualToSize(size, CGSizeZero)) {
//            return self.headSize;
//        }
//        return size;
//    }
//    return size;
//}
////返回头footerView的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    CGSize size=self.footSize;
//    HeadFootModel * headFootModel = [self getHeadFootModelAtSection:section];
//    UICollectionReusableView *view = [self collectionView:collectionView reusableViewforHeadFootModel:headFootModel section:section];
//    if ([view respondsToSelector:@selector(collectionView:layout:model:referenceSizeForFooterInSection:)]) {
//        return  [view collectionView:self layout:collectionViewLayout model:headFootModel.model referenceSizeForFooterInSection:section];
//    }
//    if (![view isMemberOfClass:[UICollectionReusableView class]]) {
//        [view layoutIfNeeded];
//        [view updateConstraintsIfNeeded];
//        size = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//        if (CGSizeEqualToSize(size, CGSizeZero)) {
//            return self.footSize;
//        }
//        return size;
//    }
//    return size;
//}
#pragma mark -- UICollectionViewDelegate --
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    ChuckModel *chuckModel = [self getModelAtIndexPath:indexPath];
    UICollectionViewCell *cell = [self collectionView:collectionView cellforChuckModel:chuckModel forIndexPath:indexPath];
    if(self.cellDidselectConfigBefore) {
        self.cellDidselectConfigBefore(cell, chuckModel.model,indexPath);
    }
    if ([cell respondsToSelector:@selector(collectionView:vcDelegate:didSelectRowWithModel:atIndexPath:)]) {
        [cell collectionView:self vcDelegate:self.vcDelegate didSelectRowWithModel:chuckModel.model atIndexPath:indexPath];
    }
}
#pragma mark -- 上拉加载更多 ---
-(UIView *)getRefreshView{
    if (_showFootRefresh && _vcDelegate && [_vcDelegate respondsToSelector:@selector(collectionView:viewForFooterRefresh:)]) {
        UIView * refresh = [_vcDelegate collectionView:self viewForFooterRefresh:nil];
        return refresh;
    }
    return nil;
}
//如果有上拉加载更多
-(UIView *)ifExistFooterRefresh:(NSIndexPath *)indexPath{
    if (indexPath.section+1 == [self numberOfSection] && indexPath.row == [self numberOfRowsAtSection:indexPath.section]) {
        UIView * refresh = [self getRefreshView];
        return refresh;
    }
    return nil;
}
@end
