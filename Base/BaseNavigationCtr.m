//
//  BaseNavigationCtr.m
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import "BaseNavigationCtr.h"

@interface BaseNavigationCtr ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation BaseNavigationCtr
#pragma mark  =====  init 打开右滑pop手势 =====
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController: rootViewController];
    if (self)
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    return self;
}
#pragma mark =====  viewDidLoad  =====
/*
    解决首页时右滑手势奔溃问题（即当前页面为第一个nav时，关闭右滑push手势）
    1.导入UINavigationControllerDelegate
    2.viewDidLoad中加入弱引用
 3.实现代理方法navigationControllerdidShowViewController
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 为self创建弱引用对象
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}
#pragma mark  =====  navigationControllerDelegate  didShowViewController  =====
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (viewController == navigationController.viewControllers[0])
    {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark  =====  viewWillAppear =====
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
