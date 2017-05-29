//
//  ViewController.m
//  DLLoopScrollView
//
//  Created by lixu on 2017/5/29.
//  Copyright © 2017年 lixu. All rights reserved.
//

#import "ViewController.h"
#import "DLLoopScrollView.h"

@interface ViewController () <DLLoopScrollViewDataSource>

@property (nonatomic ,strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DLLoopScrollView *loopScrollView = [[DLLoopScrollView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 300)];
    [self.view addSubview:loopScrollView];
    loopScrollView.dataSource = self;
    
    self.dataSource = @[@"0",@"1",@"2",@"3",@"4",@"5"];
}

- (NSInteger) numberOfPagesInLoopScrollView:(DLLoopScrollView *)loopScrollView
{
    return self.dataSource.count;
}

- (UIView *) loopScrollView:(DLLoopScrollView *)loopScrollView pageAtIndex:(NSInteger)index
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor orangeColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 20)];
    label.text = self.dataSource[index];
    [view addSubview:label];
    
    return view;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
