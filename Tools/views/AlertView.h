//
//  AlertView.h
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^Block_Alert)(id action);

@interface AlertView : NSObject
+(id)alertViewWithTitle:(NSString *)title andContent:(NSString *)content
           andBtnTitles:(NSArray *)buttonTitles andActions:(Block_Alert *)actions andShowVC:(UIViewController *)vc;
+(id)actionSheetWithTitle:(NSString *)title andContent:(NSString *)content
             andBtnTitles:(NSArray *)buttonTitles andActions:(Block_Alert *)actions andShowVC:(UIViewController *)vc;
@end
