//
//  ToolBox.m
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.

#import "ToolBox.h"
#import "AppDelegate.h"
@implementation ToolBox
+(CGSize) sizeForLableWithText:(NSString *)strText fontSize:(NSInteger)fontSize withSize:(CGSize)size
{
    CGSize textSize;
    if (!strText) strText = @"";
    NSString *s = strText;
    NSAttributedString *attrStr = [[NSAttributedString  alloc] initWithString:s];
    NSRange range = NSMakeRange(0, attrStr.length);
    NSMutableDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range].mutableCopy;
    NSDictionary *dic1 = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    [dic addEntriesFromDictionary:dic1];
    
    // 计算文本的大小
    textSize = [s boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                            attributes:dic        // 文字的属性
                               context:nil].size;
    return textSize;
}

+(void)noticeContent:(NSString *)content andShowView:(UIView *)view andyOffset:(CGFloat)yOffset;
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = content;
    hud.label.textColor = UIColorFromHex(0xffffff);
    hud.label.superview.backgroundColor = SystemBlack;
    hud.label.font = [UIFont systemFontOfSize:content.length > 15 ? 13 : 20];
    hud.label.numberOfLines = 2;
    hud.margin = 8.f;
    hud.offset = CGPointMake(0, yOffset);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:content.length > 15 ? 5 : 1];
}

//判断当前控制器是否正在显示
+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

//返回到指定控制器
+(void)backToTargetVC:(Class)targetVC fromNowNC:(UINavigationController *)nowNC
{
    for (UIViewController *controller in nowNC.viewControllers) {
        if ([controller isKindOfClass:targetVC]) {
            [nowNC popToViewController:controller animated:YES];
        }
    }
}
//判断返回数据是否为null
+(BOOL)dataISEmpty:(id)text
{
    if ([text isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([text isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (text == nil){
        return YES;
    }
    return NO;
}
@end
