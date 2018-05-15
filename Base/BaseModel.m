//
//  BaseModel.m
//  BeiWei36du
//
//  Created by Ios_Developer on 2018/2/6.
//  Copyright © 2018年 com.beiWei36du. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([self isEmpty:oldValue]) {// 以字符串类型为例
        
        if (property.type.typeClass == [NSString class])
        {
            return  @"";
        }
        if (property.type.typeClass == [NSArray class])
        {
            return @[];
        }
        if (property.type.typeClass == [NSDictionary class])
        {
            return @{};
        }
    }
    return oldValue;
}

-(BOOL)isEmpty:(id)text{
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
