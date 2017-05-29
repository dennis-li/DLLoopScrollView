//
//  DLLoopScrollView.m
//  PPInfiniteLoopScrollView
//
//  Created by lixu on 2017/5/29.
//  Copyright © 2017年 lixu. All rights reserved.
//

#import "DLLoopScrollView.h"

@interface DLLoopScrollView ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView *scrollView;

//保存左中右三个视图
@property (nonatomic ,strong) NSMutableArray *viewArray;

@property (nonatomic ,assign) CGSize currentSize;

//总共所需显示的项目个数
@property (nonatomic ,assign) NSInteger itemCount;

//当前显示的是三个视图中的第几个
@property (nonatomic ,assign) NSInteger currentPage;

@end

@implementation DLLoopScrollView

#pragma mark - Life Cycle
- (void) dealloc
{
    NSLog(@"%@ dealloc",[self class]);
}

- (instancetype) initWithFrame:(CGRect)frame withFirstItemNumber:(NSInteger) number
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //配置
        [self p_setupWithFirstItemNumber:number];
        
        [self addSubview:self.scrollView];
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withFirstItemNumber:0];
}


#pragma  mark - Event Response

#pragma  mark - Notification


#pragma  mark - Private Method
- (void) p_setupWithFirstItemNumber:(NSInteger) number
{
    _currentPage = 0;
    _currentItemNumber = number;
    _currentSize = self.frame.size;
}

//最先显示的视图
- (UIView *) p_updateCenterPage
{
    UIView *centerPage = [self.dataSource infiniteLoopScrollView:self pageAtIndex:_currentItemNumber];
    [self.scrollView addSubview:centerPage];
    return centerPage;
}

//更新左边视图
- (UIView *) p_updateLeftPage
{
    NSInteger leftItemNumber = _currentItemNumber-1;
    if (leftItemNumber < 0) {
        leftItemNumber = _itemCount-1;
    }
    
    UIView *leftPage = [self.dataSource infiniteLoopScrollView:self pageAtIndex:leftItemNumber];
    [self.scrollView addSubview:leftPage];
    return leftPage;
}

//更新右边视图
- (UIView *) p_updateRightPage
{
    NSInteger rightItemNumber = _currentItemNumber+1;
    rightItemNumber %= _itemCount;
    UIView *rightView = [self.dataSource infiniteLoopScrollView:self pageAtIndex:rightItemNumber];
    [self.scrollView addSubview:rightView];
    return rightView;
}

//显示的页面少于3个，所以不实现循环的功能
- (void) p_updateSubViewsWithDefult
{
    NSMutableArray *viewArray = [NSMutableArray array];
    UIView *centerPageView = [self p_updateCenterPage];
    centerPageView.frame = CGRectMake(0, 0, _currentSize.width, _currentSize.height);
    [viewArray addObject:centerPageView];
    if (_itemCount > 1) {
        UIView *rightPageView = [self p_updateRightPage];
        rightPageView.frame = CGRectMake(_currentSize.width, 0, _currentSize.width, _currentSize.height);
        [viewArray addObject:rightPageView];
    }
    
    _viewArray = viewArray.mutableCopy;
}

//左中右子视图的页面设置
- (void) p_updateSubViews
{
    UIView *centerPageView = [self p_updateCenterPage];
    UIView *rightPageView = [self p_updateRightPage];
    UIView *leftPageView = [self p_updateLeftPage];
    
    _viewArray = @[centerPageView,rightPageView,leftPageView].mutableCopy;
}

//为了实现永久循环，每次滚动之后更新子视图位置
- (void) p_updatePosition
{
    UIView *viewCenter = [_viewArray objectAtIndex:_currentPage];
    viewCenter.frame = CGRectMake(_currentSize.width, 0, _currentSize.width, _currentSize.height);
    
    NSInteger leftNumber = _currentPage-1;
    if (leftNumber < 0) {
        leftNumber = _viewArray.count-1;
    }
    UIView *viewLeft = [_viewArray objectAtIndex:leftNumber];
    viewLeft.frame = CGRectMake(0, 0, _currentSize.width, _currentSize.height);
    
    NSInteger rightNumber = _currentPage+1;
    UIView *rightView = [_viewArray objectAtIndex:rightNumber % self.viewArray.count];
    rightView.frame = CGRectMake(_currentSize.width*2, 0, _currentSize.width, _currentSize.height);
}

//更新左右视图
- (void) p_updateUIWithLeft:(BOOL) isLeft
{
    NSInteger refreshPage = _currentPage;
    if (isLeft) {
        if (--refreshPage < 0) {
            refreshPage = 2;
        }
        UIView *leftPageView = _viewArray[refreshPage];
        [leftPageView removeFromSuperview];
        _viewArray[refreshPage] = [self p_updateLeftPage];
    } else {
        refreshPage++;
        refreshPage %= 3;
        UIView *rightPageView = _viewArray[refreshPage];
        [rightPageView removeFromSuperview];
        _viewArray[refreshPage] = [self p_updateRightPage];
    }
    
}

- (void) p_updateCurrentNumber
{
    CGPoint offset = [_scrollView contentOffset] ;
    
    if (offset.x > _currentSize.width)
    { //向右滑动
        _currentPage = ++_currentPage % _viewArray.count;
        _currentItemNumber = ++_currentItemNumber % _itemCount;
        [self p_updateUIWithLeft:NO];
    }
    else if(offset.x < _currentSize.width)
    { //向左滑动
        if (--_currentPage < 0) {
            _currentPage = _viewArray.count-1;
        }
        
        if (--_currentItemNumber < 0) {
            _currentItemNumber = _itemCount-1;
        }
        
        [self p_updateUIWithLeft:YES];
    }
}

#pragma  mark - Public Method
- (void) reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _itemCount = [_dataSource infiniteLoopScrollView:self];
        
        if (_itemCount < 1) {
            return;
        }
        
        //显示的视图不足三个
        if (_itemCount < 3) {
            self.scrollView.contentSize = CGSizeMake(_currentSize.width*_itemCount, 0);
            [self p_updateSubViewsWithDefult];
            return;
        }
        
        //加载三个视图（永远只有左中右三个视图）
        [self p_updateSubViews];
        
        
        
        //刷新视图显示位置
        [self p_updatePosition];
        [_scrollView setContentOffset:CGPointMake(_currentSize.width, 0) animated:NO];
    });
    
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //需要显示的视图不足三个
    if (_itemCount < 3) {
        CGPoint offset = [_scrollView contentOffset];
        if (offset.x
            > 0) {
            _currentPage = 1;
        } else {
            _currentPage = 0;
        }
        return;
    }
    
    //判断滑动的方向,并更新对应方向的下一个视图
    [self p_updateCurrentNumber];
    
    //实现永久循环
    [self p_updatePosition];
    
    [_scrollView setContentOffset:CGPointMake(_currentSize.width, 0) animated:NO];
}

#pragma  mark - Stter / Getter
- (UIScrollView *) scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.frame = CGRectMake(0, 0, _currentSize.width,_currentSize.height);
        
        _scrollView.contentSize = CGSizeMake(_currentSize.width*3, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (void) setDataSource:(id<DLLoopScrollViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

//改变当前显示的项目序列
- (void) setCurrentItemNumber:(NSInteger)currentItemNumber
{
    if (_currentItemNumber == currentItemNumber) {
        return;
    }
    
    if (_itemCount < 3) {
        _currentItemNumber = currentItemNumber;
        NSArray *oldViews = _viewArray.copy;
        [self p_updateSubViewsWithDefult];
        _currentPage = 0;
        for (UIView *view in oldViews) {
            [view removeFromSuperview];
        }
    }
    
    _currentItemNumber = currentItemNumber;
    NSArray *oldViews = _viewArray.copy;
    [self p_updateSubViews];
    _currentPage = 0;
    [self p_updatePosition];
    for (UIView *view in oldViews) {
        [view removeFromSuperview];
    }
}

- (UIView *) currentView
{
    return self.viewArray[_currentPage];
}

@end
