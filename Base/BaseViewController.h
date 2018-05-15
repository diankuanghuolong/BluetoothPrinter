//
//  BaseViewController.h
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
    基累控制器，为子类控制器定制样式，其他子控制器继承该控制器
 */
@interface BaseViewController : UIViewController
{
    UIView * _navBarLineView;//获取导航栏底部线条，方便处理
}

#pragma mark  =====  property  =====
@property(nonatomic,strong)UIView * navBarBGView;  //-----自定义导航栏视图
@property (nonatomic ,strong)UIButton *backBtn;//返回按钮

#pragma mark  ===== action  ======
-(void)createCustomBackButtonOnNavBar;            //------自定义返回按钮
-(void)hideNavigationBarLineView;                 //------隐藏导航栏底部线条方法
//
-(void)back;                                      //------返回按钮点击事件

#pragma mark  ===== tools  =====
/*
    添加统一处理事件
    例：
    1.登陆失效处理
    2.网络异常处理
 */

@end
