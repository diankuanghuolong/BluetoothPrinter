//
//  PrintModel.h
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/15.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "BaseModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
/*
 有问题没有使用（我是地主家的傻儿子）
*/
@interface BluetoothModel : BaseModel

@property (nonatomic ,strong)CBPeripheral *peripheral;
@property (nonatomic ,strong)NSString *locolName;
@property (nonatomic ,strong)NSString *peripheralName;
@property (nonatomic ,strong)NSString *advertisementData;
@property (nonatomic ,strong)NSString *RSSI;
@end
