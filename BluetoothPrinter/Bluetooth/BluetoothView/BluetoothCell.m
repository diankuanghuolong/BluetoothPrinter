//
//  BluetoothCell.m
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/16.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "BluetoothCell.h"

@implementation BluetoothCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initView];
    }
    return self;
}
#pragma mark  =====  init  =====
-(void)initView
{
    CGFloat stateLW = 50,btnW = self.height,peripheralX = 15, peripheralLW =  SCREEN_WIDTH - peripheralX*2 - stateLW - btnW - 15;
    _deviceNameL = [Factory getLabel:CGRectMake(peripheralX, 0,peripheralLW, 50) andText:@"" andFontSize:15 andTextColor:SystemBlack];
    _deviceNameL.numberOfLines = 2;
    [self.contentView addSubview:_deviceNameL];
    
    _stateL = [Factory getLabel:CGRectMake(_deviceNameL.right + 5, 0, stateLW, 50) andText:@"" andFontSize:15 andTextColor:SystemGray];
    _stateL.hidden = YES;
    [self.contentView addSubview:_stateL];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(_stateL.right + 5, 0, btnW, _stateL.height)];
    [_cancelBtn setTitle:@"断开" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn addTarget:self action:@selector(calcelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_cancelBtn];
}
#pragma mark  =====  action  =====
-(void)calcelAction:(id)sender
{
    __weak BluetoothCell *weakSelf = self;
    if (_cancel_Block)
    {
        _cancel_Block(weakSelf);
    }
}
@end
