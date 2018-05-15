//
//  Factory.m
//  ShellFrameDemo
//
//  Created by Ios_Developer on 2017/12/6.
//  Copyright © 2017年 hai. All rights reserved.
//

#import "Factory.h"

@implementation Factory
//label
+(UILabel *)getLabel:(CGRect)frame andText:(NSString * )text andFontSize:(CGFloat)size andTextColor:(UIColor *)color
{
    //title label
    UILabel * label1 = [[UILabel alloc] initWithFrame:frame];
    label1.userInteractionEnabled = YES;
    label1.text = text;
    label1.textColor = color;
    label1.font = [UIFont systemFontOfSize:size];
    return label1;
    
}

+(UILabel *)getLabel:(CGRect)frame andText:(NSString * )text andFontSize:(CGFloat)size andTextColor:(UIColor *)color andTextAlignment:(NSTextAlignment) textAlignment
{
    //title label
    UILabel * label1 = [[UILabel alloc] initWithFrame:frame];
    label1.userInteractionEnabled = YES;
    label1.text = text;
    label1.textColor = color;
    label1.font = [UIFont systemFontOfSize:size];
    label1.textAlignment = textAlignment;
    return label1;
    
}
//textfield
+(UITextField *)getTextField:(CGRect) rect andFontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor andPlaceHolder:(NSString *)placeHolder andKeyboardType:(UIKeyboardType)keyboardType andReturnKeyType:(UIReturnKeyType) returnKeytype
{
    UITextField * tf = [[UITextField alloc] initWithFrame:rect];
    tf.font = [UIFont systemFontOfSize:fontSize];
    tf.placeholder = placeHolder;
    tf.textColor = textColor;
    tf.keyboardType = keyboardType;
    tf.returnKeyType = returnKeytype;
    return  tf;
}
//线条
+(UIView *)getLineView:(CGRect)rect
{
    
    UIView * view =[[UIView alloc] initWithFrame:rect];
    view.backgroundColor = UIColorFromHex(0xaaaaaa);
    return  view;
}
@end
