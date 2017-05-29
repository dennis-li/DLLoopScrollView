//
//  DLLoopScrollView.h
//  PPInfiniteLoopScrollView
//
//  Created by lixu on 2017/5/29.
//  Copyright © 2017年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLLoopScrollView;
@protocol DLLoopScrollViewDataSource <NSObject>

@required

//数据源总数
- (NSInteger) infiniteLoopScrollView:(DLLoopScrollView *) infiniteLoopScrollView;

//需要显示的的subView
- (UIView *) infiniteLoopScrollView:(DLLoopScrollView *) infiniteLoopScrollView pageAtIndex:(NSInteger ) index;


@end

@interface DLLoopScrollView : UIView

@property (nonatomic ,weak) id <DLLoopScrollViewDataSource> dataSource;

//当前显示的第几个项目
@property (nonatomic ,assign) NSInteger currentItemNumber;

//当前显示的view
@property (nonatomic ,strong) UIView *currentView;

- (void) reloadData;

@end

