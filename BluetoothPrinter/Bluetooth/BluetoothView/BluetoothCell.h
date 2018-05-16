//
//  BluetoothCell.h
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/16.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^cancle_Block)(UITableViewCell *cell);
@interface BluetoothCell : UITableViewCell

@property (nonatomic ,strong)UILabel *deviceNameL;
@property (nonatomic ,strong)UILabel *stateL;
@property (nonatomic ,strong)UIButton *cancelBtn;

@property (nonatomic ,copy)cancle_Block cancel_Block;
@end
