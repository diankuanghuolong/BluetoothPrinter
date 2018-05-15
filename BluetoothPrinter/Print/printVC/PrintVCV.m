//
//  PrintVCViewController.m
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/15.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "PrintVCV.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface PrintVCV ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>
{
    //这里保存这个可以写的特性，便于后面往这个特性中写数据
      CBCharacteristic *_chatacter;//外设的可写特性，全局保存，方便使用
}
@property (nonatomic ,strong)NSArray *dataSource;
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)UISwitch *bluetoothSwitch;
/**中心设备管理器*/
@property(strong,nonatomic) CBCentralManager *centerManager;

/**所有蓝牙设备*/
@property(strong,nonatomic) NSMutableArray *peripherals;

@end

@implementation PrintVCV

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"蓝牙列表";
    self.view.backgroundColor = BG_COlOR;
    
    //
    _dataSource = @[@"",@"我的设备",@"其他设备"];
    //init
    [self.view addSubview:self.tableView];
    AdjustsScrollViewInsetNever(self, _tableView);
    
    [self initCBCentralManager];
    
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [self scan:nil];
    }];
}
#pragma mark ===== lazyLoad  =====
-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = BG_COlOR;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 5)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        _tableView.showsVerticalScrollIndicator = NO;
        if (@available (iOS 11,*)) {
            _tableView.estimatedRowHeight = 0;
        }
    }
    return _tableView;
}
#pragma mark  =====  init  =====
/*第一步：创建设备管理器
 创建完之后,会回掉CBCentralManagerDelegate中的方法：- (void)centralManagerDidUpdateState:(CBCentralManager *)central
 */
-(void)initCBCentralManager
{
    self.centerManager = [[CBCentralManager alloc] init];
    self.centerManager = [self.centerManager initWithDelegate:self queue:nil];
    self.peripherals = [NSMutableArray array]; //存放所有扫描到的外设
    NSLog(@"self.centerManager ===== %@",self.centerManager);
}
#pragma mark  =====  action  =====
-(void)stopLoad
{
    if ([_tableView.mj_header isRefreshing]) {
        [_tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}
//第二步：扫描蓝牙设备
- (void)scan:(id)sender
{
    if (self.centerManager.state != CBCentralManagerStatePoweredOn)
    {
        [ToolBox noticeContent:@"请检查蓝牙是否打开" andShowView:self.view andyOffset:NoticeHeight];
        return;
    }
    //扫描蓝牙设备
    [self.centerManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
    //key值是NSNumber,默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
}
- (void)closeAction:(UISwitch *)sender
{
//    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    NSURL * url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }

    if (sender.isOn)
    {
        //打开
        NSLog(@"open");
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
    }
    else
    {
        //
        NSLog(@"close");
    }
}
#pragma mark -- table view delegate/datasource method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == _dataSource.count - 1)
    {
       return self.peripherals.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headerV.backgroundColor = BG_COlOR;
    
    UILabel *titleL = [Factory getLabel:CGRectMake(15, 0, headerV.width - 30, headerV.height) andText:_dataSource[section] andFontSize:15 andTextColor:SystemBlack1];
    [headerV addSubview:titleL];
    
    return headerV;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString * str = @"PrintVC0_cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            
            //
            UILabel *titleL = [Factory getLabel:CGRectMake(15, 0,SCREEN_WIDTH - 70 - 20, 50) andText:@"蓝牙" andFontSize:15 andTextColor:SystemBlack];
            [cell.contentView addSubview:titleL];
            
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(titleL.right + 5, 6, 60, 44)];
            [sw addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
            sw.tag = 1000;
            [sw setOn:NO];
            sw.onTintColor = ThemeColor;
            [cell.contentView addSubview:sw];
            _bluetoothSwitch = sw;
        }
        
        return cell;
    }
    else
    {
        static NSString * str = @"PrintVC1_cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            
            [self loadCell:cell withIndexPath:indexPath];
        }
        //fuzhi
        UILabel *peripheralL = [cell.contentView viewWithTag:100];
        UILabel *stateL = [cell.contentView viewWithTag:101];
        
        //    NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
        if (self.peripherals.count > 0)
        {
            CBPeripheral *peripheral = self.peripherals[indexPath.row][@"peripheral"];
            NSString *peripheralStr = self.peripherals[indexPath.row][@"locolName"];
            peripheralStr = peripheralStr.length <= 0 ? [peripheral.identifier UUIDString] : peripheralStr;
            peripheralL.text = peripheralStr;
            
            if (peripheral.state == CBPeripheralStateConnected)
            {
                stateL.text = @"已连接";
            }
            else
            {
                stateL.text = @"未连接";
            }
        }
        //reframe
        if (indexPath.section == 2)
        {
            stateL.hidden = YES;
        }
        else stateL.hidden = NO;
        
        return cell;
    }
}
#pragma mark  =====  loadCell  =====
-(void)loadCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    CGFloat peripheralLW =  SCREEN_WIDTH - 30 - 60,stateLW = 50;
    UILabel *peripheralL = [Factory getLabel:CGRectMake(15, 0,peripheralLW, 50) andText:@"" andFontSize:15 andTextColor:SystemBlack];
    peripheralL.tag = 100;
    [cell.contentView addSubview:peripheralL];
    
    UILabel *stateL = [Factory getLabel:CGRectMake(peripheralL.right + 5, 0, stateLW, 50) andText:@"" andFontSize:15 andTextColor:SystemGray];
    stateL.tag = 101;
    [cell.contentView addSubview:stateL];
    if (indexPath.section == 2)
    {
        stateL.hidden = YES;
    }
    else stateL.hidden = NO;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dict = [self.peripherals objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = dict[@"peripheral"];
    
    // 连接某个蓝牙外设
    [self connectPeripheral:peripheral];
}
/*分割线前移*/
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    //刷新页面布局情况，解决打电话、开热点等，导致的状态栏高度改变引起界面下移情况
    
    CGFloat tabBarH = self.tabBarController.tabBar.height;
    //1.刷新当前VC中tableview的布局
    _tableView.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, self.view.height - SafeAreaTopHeight - tabBarH);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

//第三步：扫描完成，发现设备，添加到设备列表中
#pragma mark
#pragma mark  =====  CBCentralManagerDelegate  =====
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI//RSSI信号强度
{
    
    NSString *locolName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];//广播的名称（准确）
    NSString *peripheralName = peripheral.name;//设备名称 (修改过的名称获取不到)

    NSLog(@"locolName%@\n Discovered name:%@\n identifier:%@\n advertisementData:%@\n RSSI:%@\n state:%ld\n",locolName,peripheral.name, peripheral.identifier,advertisementData,RSSI,(long)peripheral.state);
//    if (/*peripheral.name.length <= 0*/locolName.length <= 0)
//    {
//        return ;
//    }
    
    
    locolName = locolName == nil ? @"" : locolName;
    peripheralName = peripheralName == nil ? @"" : peripheralName;
    if (self.peripherals.count == 0)
    {
        NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
        [self.peripherals addObject:dict];
    }
    else
    {
        BOOL isExist = NO;
        for (int i = 0; i < self.peripherals.count; i++)
        {
            NSDictionary *dict = [self.peripherals objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
                [self.peripherals replaceObjectAtIndex:i withObject:dict];
            }
        }
        
        if (!isExist)
        {
            NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
            [self.peripherals addObject:dict];
        }
    }
    [self stopLoad];
    [self.tableView reloadData];
    
}


//第四步：连接蓝牙设备
- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [self.centerManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
    // 设置外设的代理是为了后面查询外设的服务和外设的特性，以及特性中的数据。
    [peripheral setDelegate:self];
    // 既然已经连接到某个蓝牙了，那就不需要在继续扫描外设了
    [self.centerManager stopScan];
}

//第五步：连接成功，扫描蓝牙设备的服务
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");
    if (error)
    {
        NSString *errorStr = [[NSString alloc] initWithFormat:@"%@",error];
        [ToolBox noticeContent:errorStr andShowView:self.view andyOffset:NoticeHeight];
    }
}
-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"已断开连接");
    [ToolBox noticeContent:@"已断开连接" andShowView:self.view andyOffset:NoticeHeight];
}
//第六步：扫描到外设的所有服务后，筛选指定的服务，扫描该服务的特性
#pragma mark  ======   CBPeripheralDelegate  =====
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSString *UUID = [peripheral.identifier UUIDString];
    NSLog(@"didDiscoverServices:%@",UUID);
    if (error)
    {
        NSLog(@"出错");
        NSString *errorStr = [[NSString alloc] initWithFormat:@"%@",error];
        [ToolBox noticeContent:errorStr andShowView:self.view andyOffset:NoticeHeight];
        return;
    }
    
    CBUUID *cbUUID = [CBUUID UUIDWithString:UUID];
    NSLog(@"cbUUID:%@",cbUUID);
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"service:%@",service.UUID);
        //如果我们知道要查询的特性的CBUUID，可以在参数一中传入CBUUID数组。
        [peripheral discoverCharacteristics:nil forService:service];
    }

}
//第七步：扫描到指定服务的特性后，筛选指定的特性，进行交互
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//    NSArray *characteristics=service.characteristics;
//    for (CBCharacteristic *characteristic in characteristics) {
//        if([characteristic.UUID  isEqual:[CBUUID UUIDWithString:self.txtCharacterUUID.text]])
//        {
//
//            NSString *str = [NSString stringWithFormat:@"\n订单号：%@\n成交额：%@\n成交时间：%@\n\n", @"12345", @"40000",@"2015-10-20" ];
//            NSData *data =[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
//
//            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//            NSLog(@"开始打印.....");
//
//        }
//    }
    if (error)
    {
        NSLog(@"出错");
        NSString *errorStr = [[NSString alloc] initWithFormat:@"%@",error];
        [ToolBox noticeContent:errorStr andShowView:self.view andyOffset:NoticeHeight];
        return;
    }
    
    for (CBCharacteristic *character in service.characteristics)
    {
        // 这是一个枚举类型的属性
        CBCharacteristicProperties properties = character.properties;
        if (properties & CBCharacteristicPropertyBroadcast) {
            //如果是广播特性
        }
        
        if (properties & CBCharacteristicPropertyRead) {
            //如果具备读特性，即可以读取特性的value
            [peripheral readValueForCharacteristic:character];
        }
        
        if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
            //如果具备写入值不需要响应的特性
            //这里保存这个可以写的特性，便于后面往这个特性中写数据
            _chatacter = character;
        }
        
        if (properties & CBCharacteristicPropertyWrite) {
            //如果具备写入值的特性，这个应该会有一些响应
        }
        
        if (properties & CBCharacteristicPropertyNotify) {
            //如果具备通知的特性，无响应
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"打印完成");
    [ToolBox noticeContent:@"打印完成" andShowView:self.view andyOffset:NoticeHeight];
}

//外设管理器状态发生变化
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"central.state ===== %ld",(long)central.state);
    [_bluetoothSwitch setOn:NO];
    switch (central.state) {
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"打开，可用");
             [_bluetoothSwitch setOn:YES];
            //给个scan Button，在button方法中扫描
            
            [self.centerManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
//                        //key值是NSNumber,默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"可用，未打开");
            [ToolBox noticeContent:@"蓝牙未打开，请在设置中打开" andShowView:self.view andyOffset:NoticeHeight];
        }
            break;
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"设备不支持");
            [ToolBox noticeContent:@"设备不支持" andShowView:self.view andyOffset:NoticeHeight];
        }
            break;
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"程序未授权");
            [ToolBox noticeContent:@"程序未授权,请在设置中打开蓝牙权限" andShowView:self.view andyOffset:NoticeHeight];
        }
            break;
    }
}

@end
