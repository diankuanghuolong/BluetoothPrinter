//
//  Factory.h
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Factory : NSObject
//label
+(UILabel *)getLabel:(CGRect)frame andText:(NSString * )text andFontSize:(CGFloat)size andTextColor:(UIColor *)color;
+(UILabel *)getLabel:(CGRect)frame andText:(NSString * )text andFontSize:(CGFloat)size andTextColor:(UIColor *)color andTextAlignment:(NSTextAlignment) textAlignment;

//textfield
+(UITextField *)getTextField:(CGRect) rect andFontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor andPlaceHolder:(NSString *)placeHolder andKeyboardType:(UIKeyboardType)keyboardType andReturnKeyType:(UIReturnKeyType) returnKeytype;

//line
+(UIView *)getLineView:(CGRect)rect;
@end
