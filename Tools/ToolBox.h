//
//  ToolBox.h
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
@interface ToolBox : NSObject

//提示信息显示框
+(void)noticeContent:(NSString *)content andShowView:(UIView *)view andyOffset:(CGFloat)yOffset;

////判断当前控制器是否正在显示
+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;

//返回到指定控制器
+(void)backToTargetVC:(Class)targetVC fromNowNC:(UINavigationController *)nowNC;

//判断返回数据是否为null
+(BOOL)dataISEmpty:(id)text;
@end
