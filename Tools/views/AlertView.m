//
//  AlertView.m
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import "AlertView.h"
#ifndef __IPHONE_8_0
@interface AlertView()<UIAlertViewDelegate,UIActionSheetDelegate>
{
    Block_Alert _alertBlock[5];
}
-(void)setAlertBlock:(Block_Alert)fun atIndex:(int)i;
@end
#endif
@implementation AlertView
#ifndef __IPHONE_8_0
-(void)setAlertBlock:(Block_Alert)fun atIndex:(int)i
{
    if (i >=0 && i < 5)
    {
        _alertBlock[i] = fun;
    }
}
#endif
+(id)alertViewWithTitle:(NSString *)title andContent:(NSString *)content
           andBtnTitles:(NSArray *)buttonTitles andActions:(Block_Alert *)actions andShowVC:(UIViewController *)vc
{
    AlertView * alert = [AlertView new];
    if (alert)
    {
#ifdef __IPHONE_8_0
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
        
        for (int i = 0; i < buttonTitles.count; i ++)
        {
            Block_Alert fun = actions[i];
            if (!fun) break;
            UIAlertAction * action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:fun];
            [alertC addAction:action];
        }
        [vc presentViewController:alertC animated:YES completion:nil];
      
#else
        UIAlertView * alertV  = [[UIAlertView alloc] initWithTitle:title message:content delegate:alert cancelButtonTitle:nil otherButtonTitles:nil];
        for (int i = 0; i < buttonTitles.count; i ++)
        {
            [alertV addButtonWithTitle:buttonTitles[i]];
            Block_Alert fun = actions[i];
            [alert setAlertBlock:fun atIndex:i];
        }
        [alertV show];
#endif
    }
    return alert;
}
+(id)actionSheetWithTitle:(NSString *)title andContent:(NSString *)content
           andBtnTitles:(NSArray *)buttonTitles andActions:(Block_Alert *)actions andShowVC:(UIViewController *)vc
{
    AlertView * alert = [AlertView new];
    if (alert)
    {
#ifdef __IPHONE_8_0
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (int i = 0; i < buttonTitles.count; i ++)
        {
            Block_Alert fun = actions[i];
            if (!fun) break;
            UIAlertAction * action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:fun];
            [alertC addAction:action];
        }
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:action];
        [vc presentViewController:alertC animated:YES completion:nil];
        
#else
        UIActionSheet * actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
        for (int i = 0; i < buttonTitles.count; i ++)
        {
            [actionSheet addButtonWithTitle:buttonTitles[i]];
            Block_Alert fun = actions[i];
            [alert setAlertBlock:fun atIndex:i];
        }
        [actionSheet showInView:vc.navigationController?vc.navigationController.view:vc.view];
#endif
    }
    return alert;
}
#ifndef __IPHONE_8_0
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"------%ld",(long)buttonIndex);
    Block_Alert fun = _alertBlock[buttonIndex];
    fun(nil);
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"------%ld",(long)buttonIndex);
    Block_Alert fun = _alertBlock[buttonIndex];
    fun(nil);
    
}
#endif
@end
