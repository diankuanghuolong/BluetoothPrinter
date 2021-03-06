//
//  BaseViewController.m
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationCtr.h"

#pragma mark  ===== colors =====
#define NavBarBGViewColor UIColorFromHex(0xffffff)  // ----- 自定义导航栏视图navbarBGV颜色
#define NavBarLineColor  UIColorFromHex(0xaaaaaa)   // ----- 自定义导航栏底部线条颜色

@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    //其他处理 如转场动画等
    
    /*
    这个back手势方法只是在当前项目中使用，其他项目若要使用本demo的基类控制器和基类导航控制器，请将这个手势删除。
     当前项目没有标签栏，所以 UIViewController 不归BaseNavigationCtr管，是野生的。正常项目UIViewController都会有监护人的，不论你的项目是标签栏管理控制器，还是导航栏管理控制器。
     扯多了，反正你项目要用俺的这个基类，记得删除这个手势。
     */
    UIScreenEdgePanGestureRecognizer *backTap = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(customBack:)];
    backTap.delegate = self;
    [backTap setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:backTap];
    
    //导航栏设置
    BaseNavigationCtr * nc = (BaseNavigationCtr *)self.navigationController;
    _navBarLineView = [self findHairlineImageViewUnder:nc.navigationBar];
    if (_navBarLineView) /*lineView.hidden = YES;*/
     _navBarLineView.backgroundColor =  UIColorFromHex(0xaaaaaa);
    
    //自定义back button
    [self createCustomBackButtonOnNavBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_navBarLineView.hidden) _navBarLineView.hidden = NO;
}

#pragma mark  ===== 状态栏改变的通知  =====
-(void)statusBarFrameWillChange:(NSNotification *)notification
{//子类可调用。
     NSValue *statusBarFrameValue =
    [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    NSLog(@"statusBarFrameValue =====  %@",statusBarFrameValue);
//
    CGRect rect;
    [statusBarFrameValue getValue:&rect];
    
    NSLog(@"statusBarFrameValue =====  %@,rect.Height  ===  %f,self.view.height === %f",statusBarFrameValue,rect.size.height,self.view.frame.size.height);
}

#pragma mark  ===== load navBarBGView  =====
/*
  navBarBGView ------自定义nav 在子控制器中设置
  例：
    在子控制器中移除或者隐藏系统导航nav，然后在self.view添加navBarBGView
 */
- (UIView *)navBarBGView//------自定义nav 在子控制器中设置
{
    if (!_navBarBGView){
        _navBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SafeAreaTopHeight)];
        _navBarBGView.backgroundColor = NavBarBGViewColor;
        _navBarBGView.alpha = 0;
        CGFloat line_h = _navBarLineView ? _navBarLineView.frame.size.height : 1;
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _navBarBGView.frame.size.height - line_h , _navBarBGView.frame.size.width, line_h)];
        lineView.backgroundColor = UIColorFromHex(0xaaaaaa);
        [_navBarBGView addSubview:lineView];
    }
    return _navBarBGView;
}
#pragma mark
#pragma mark  ===== tool method  =====
- (void)createCustomBackButtonOnNavBar// ----- 在base viewdidload中使用，也可以在子控制器中重置
{
//    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //解决后退时候，系统默认backbutton造成的...问题 （返回时候，系统默认backButton出现，new将其置空）
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:v];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 24, 24);
#pragma warmming -- 给入back按钮图片 back
    [btn setImage:[UIImage imageNamed:@"nav_btn_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:bbi];
    _backBtn = btn;
}
-(void)hideNavigationBarLineView// ----- 在子控制器中使用，可以隐藏自定义navBarBGView的底部线条
{
    if (_navBarLineView) _navBarLineView.hidden = YES;
}
//发现nav bar 下面的黑线视图方法
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}
- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)customBack:(UIScreenEdgePanGestureRecognizer *)panTap
{
    if(self.navigationController.childViewControllers.count == 1)
    {
        return;
    }
    //转场动画什么的都忘记了，好烦啊。今天不想写了。
    if(panTap.state == UIGestureRecognizerStateBegan)
    {
        [ToolBox noticeContent:@"朕的一生，无所畏惧,就算你不招惹朕，朕也要咬你！啊呜。" andShowView:self.view andyOffset:NoticeHeight];
    }
    else if(panTap.state == UIGestureRecognizerStateEnded ||panTap.state == UIGestureRecognizerStateCancelled)
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ToolBox noticeContent:@"你滑个头啊，点返回按钮去!" andShowView:self.view andyOffset:NoticeHeight];
    }
}
#pragma mark  =====  =====
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
