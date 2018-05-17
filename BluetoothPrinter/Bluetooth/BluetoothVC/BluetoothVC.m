//
//  PrintVCViewController.m
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/15.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "BluetoothVC.h"
#import "BluetoothCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface BluetoothVC ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>
{
    //这里保存这个可以写的特性，便于后面往这个特性中写数据
    CBCharacteristic *_chatacter;//--------------外设的可写特性，全局保存，方便使用
    
    NSDictionary *_currentPeripheral;//----------当前连接的外设
    
    UIActivityIndicatorView *_aciv;//------------连接外设时的加载控件
    
    //设置定时器，扫描一分钟后停止扫描，节省性能。
    NSInteger _timeNum;
    NSTimer *_timer;
}
@property (nonatomic ,strong)NSArray *dataSource;
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)UISwitch *bluetoothSwitch;//-------------蓝牙开关按钮

@property(strong,nonatomic) CBCentralManager *centerManager;//--------中心设备管理器

@property(strong,nonatomic) NSMutableArray *peripherals;//------------所有蓝牙外设

@end

@implementation BluetoothVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"蓝牙列表";
    self.view.backgroundColor = BG_COlOR;
    
    //data
    _dataSource = @[@"",@"已连接设备",@"其他设备"];
    //init views
    [self.view addSubview:self.tableView];
    AdjustsScrollViewInsetNever(self, _tableView);
    
    //初始化蓝牙manager
    [self initCBCentralManager];
    
    //下拉刷新，搜索蓝牙外设
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self scan:nil];
    }];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //
    [self stopTimer];
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
    self.peripherals = [NSMutableArray array]; //存放所有扫描到的蓝牙外设
    NSLog(@"self.centerManager ===== %@",self.centerManager);
}
#pragma mark  =====  action  =====
-(void)stopLoad//关闭下拉加载
{
    if ([_tableView.mj_header isRefreshing]) {
        [_tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}
//第二步：扫描蓝牙外设
- (void)scan:(id)sender
{
    if (_timer)
    {
        [self stopTimer];
    }
    _timeNum = 120;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount:) userInfo:nil repeats:YES];
    [_timer fire];
    
    [self startScanPeripheral];
}
-(void)startScanPeripheral
{
    if (self.centerManager.state != CBCentralManagerStatePoweredOn)
    {
        [ToolBox noticeContent:@"请检查蓝牙是否打开" andShowView:self.view andyOffset:NoticeHeight];
        if ([_tableView.mj_header isRefreshing])
            [_tableView.mj_header endRefreshing];
        return;
    }
    //扫描蓝牙设备
    [self.centerManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
    //key值是NSNumber,默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
    [self stopLoad];
}
-(void)stopScanPeripheral
{
    if (@available(iOS 9.0, *))
    {
        if ([self.centerManager isScanning])
        {
            [self.centerManager stopScan];
            [ToolBox noticeContent:@"扫描结束" andShowView:self.view andyOffset:NoticeHeight];
            NSLog(@"扫描结束");
        }
    } else {
        // Fallback on earlier versions
    }
}
- (void)closeAction:(UISwitch *)sender
{
    //    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    NSURL * url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];//ios11无效了
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
        BluetoothCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (!cell)
        {
            cell = [[BluetoothCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            
        }
        
        //    NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
        if (self.peripherals.count > 0)
        {
            CBPeripheral *peripheral = nil;
            NSString *peripheralStr = nil;
            if (indexPath.section == 1)//已连接设备
            {
                peripheral = _currentPeripheral[@"peripheral"];
                peripheralStr = _currentPeripheral[@"locolName"];
                peripheralStr = peripheralStr.length <= 0 ? _currentPeripheral[@"peripheralName"] : peripheralStr;
                peripheralStr = peripheralStr.length <= 0 ? [peripheral.identifier UUIDString] : peripheralStr;
                
                cell.cancel_Block = ^(UITableViewCell *cell) {
                  
                    [self cancelPeripheral:peripheral];
                };
            }
            else//其他设备
            {
                peripheral = self.peripherals[indexPath.row][@"peripheral"];
                peripheralStr = self.peripherals[indexPath.row][@"locolName"];
                peripheralStr = peripheralStr.length <= 0 ? self.peripherals[indexPath.row][@"peripheralName"] : peripheralStr;
                peripheralStr = peripheralStr.length <= 0 ? [peripheral.identifier UUIDString] : peripheralStr;
            }
            
            cell.deviceNameL.text = peripheralStr;
            
            //
            if (peripheral.state == CBPeripheralStateConnected && indexPath.section == 1)
            {
                cell.stateL.text = @"已连接";
                cell.cancelBtn.hidden = NO;
            }
            else
            {
                cell.stateL.text = @"未连接";
                cell.cancelBtn.hidden = YES;
            }
        }
        //reframe
        if (indexPath.section == 2)
             cell.stateL.hidden = YES;
        else
            cell.stateL.hidden = NO;
        
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
        return;
    else if (indexPath.section == 1)
    {
        if (_currentPeripheral != nil)//点击"已连接设备"连接时，不需要替换数据源
        {
            CBPeripheral *peripheral = _currentPeripheral[@"peripheral"];
            
            [self contentPeripheral:peripheral withIndexPath:indexPath];
        }
    }
    else
    {
        NSDictionary *dict = [self.peripherals objectAtIndex:indexPath.row];
        CBPeripheral *peripheral = dict[@"peripheral"];
       
        // 连接某个蓝牙外设
        if (dict)
        {
            //
            NSDictionary *dic = _currentPeripheral;
            _currentPeripheral = self.peripherals[indexPath.row];
            
            NSArray *deleteIndexPaths = @[];
            NSArray *insertIndexPaths = @[];
            if (dic)
            {
                [self.peripherals removeObjectAtIndex:indexPath.row];
                [self.peripherals insertObject:dic atIndex:0];

                //刷新cell
                deleteIndexPaths = @[[NSIndexPath indexPathForRow:indexPath.row inSection:2]];
                insertIndexPaths = @[[NSIndexPath indexPathForRow:0 inSection:2]];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            }
            else
            {
                [self.peripherals removeObjectAtIndex:indexPath.row];
                
                //刷新cell
                deleteIndexPaths = @[[NSIndexPath indexPathForRow:indexPath.row inSection:2]];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            }
            
            [self contentPeripheral:peripheral withIndexPath:indexPath];
        }
    }
    
    //滑动到顶部
    [tableView setContentOffset:CGPointMake(0,0) animated:YES];
    tableView.scrollsToTop = YES;
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
#pragma mark  =====  tools  =====
-(void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}
-(void)timerCount:(id)sender
{
    if (_timeNum <= 0)
    {
        //关闭定时器
        [self stopTimer];
        
        //关闭扫描
        [self stopScanPeripheral];
        
        return;
    }
    --_timeNum;
//    NSLog(@"%ld",_timeNum);
}
#pragma mark  =====  contentPeripheralTools  =====
-(void)hiddenAciv//隐藏加载图
{
    [_aciv stopAnimating];
    [_aciv removeFromSuperview];
    
    BluetoothCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    cell.stateL.hidden = NO;
    cell.cancelBtn.hidden = NO;
}
-(void)changeCurrentPeripheralState//修改“已连接外设”的连接状态
{
     BluetoothCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    CBPeripheral *peripheral = _currentPeripheral[@"peripheral"];
    if (peripheral.state == CBPeripheralStateConnected)
    {
        cell.stateL.text = @"已连接";
        cell.cancelBtn.hidden = NO;
    }
    else
    {
        cell.stateL.text = @"未连接";
        cell.cancelBtn.hidden = YES;
    }
    
    //刷新cell
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:1]];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}
-(void)contentPeripheral:(CBPeripheral *)peripheral withIndexPath:(NSIndexPath *)indexPath//点击cell，连接外设
{
    [self connectPeripheral:peripheral];
    
//    //点击cell数据已替换，刷新列表
    [self changeCurrentPeripheralState];
    
    //添加加载图
    if (_aciv) {
        [_aciv removeFromSuperview];
    }
    
    BluetoothCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    cell.stateL.hidden = YES;
    cell.cancelBtn.hidden = YES;
    
    UIActivityIndicatorView * aciv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, (cell.height - 40)/2, 40, 40)];
    aciv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [aciv startAnimating];
    [cell.contentView addSubview:aciv];
    
    _aciv = aciv;
}
- (void)cancelPeripheral:(CBPeripheral *)peripheral//点击断开，取消当前连接
{
    if (!peripheral) {
        return;
    }
    [self.centerManager cancelPeripheralConnection:peripheral];
    _currentPeripheral = nil;
    
    //刷新cell
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
}
#pragma mark
#pragma mark  =====  CBCentralManagerDelegate  =====
/*第三步：扫描完成，将发现设备的不重复地添加到外设数组中
 这个代理方法每扫描到一个外设，就会进入一次。
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI//RSSI信号强度
{
    
    NSString *locolName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];//广播的名称（准确）
    NSString *peripheralName = peripheral.name;//设备名称 (修改过的名称获取不到)
    
    NSLog(@"locolName%@\n Discovered name:%@\n identifier:%@\n advertisementData:%@\n RSSI:%@\n state:%ld\n",locolName,peripheral.name, peripheral.identifier,advertisementData,RSSI,(long)peripheral.state);
    
    /*
     if (peripheral.name.length <= 0 && locolName.length <= 0)
    {
        return ;
    }
     由于设备名称改变，可能会导致无法获取到peripheralName的情况，使用locolName获取可能更准确。
     这里没有做限制，不论是否能获取到外设名称都添加到列表中。
     显示的时候优先级如下：locolName（有显示）无->peripheralName（有显示）无->identifier
     */
    
    locolName = locolName == nil ? @"" : locolName;
    peripheralName = peripheralName == nil ? @"" : peripheralName;
    if (self.peripherals.count == 0)
    {
        NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
        [self.peripherals addObject:dict];
        
        //将已连接外设，置为当前外设
        if(peripheral.state == CBPeripheralStateConnected)
        {
            [self.peripherals removeObject:dict];
            _currentPeripheral = dict;
        }
    }
    else
    {
        BOOL isExist = NO;
        for (int i = 0; i < self.peripherals.count; i++)
        {
            NSDictionary *dict = [self.peripherals objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])//扫描到的外设已有，替换
            {
                isExist = YES;
                NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
                [self.peripherals replaceObjectAtIndex:i withObject:dict];
            }
            
            //去除已连接的外设
            if (_currentPeripheral)
            {
                CBPeripheral *currentPer = _currentPeripheral[@"peripheral"];
                if ([per.identifier.UUIDString isEqualToString:currentPer.identifier.UUIDString]) {
                    
                    [self.peripherals removeObjectAtIndex:i];
                }
            }
        }
        
        if (!isExist)
        {
            NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
            [self.peripherals addObject:dict];
        }
        
        //将已连接外设，置为当前外设
        if(peripheral.state == CBPeripheralStateConnected)
        {
            NSDictionary *dict = @{@"peripheral":peripheral,@"locolName":locolName,@"peripheralName":peripheralName,@"advertisementData":advertisementData,@"RSSI":RSSI};
            [self.peripherals removeObject:dict];
            _currentPeripheral = dict;
        }
    }
    [self.tableView reloadData];
    
}
//第四步：连接蓝牙设备
- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [self.centerManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
    /*
     CBConnectPeripheralOptionNotifyOnDisconnectionKey
     在程序被挂起时，断开连接显示Alert提醒框
     */
    // 设置外设的代理是为了后面查询外设的服务和外设的特性，以及特性中的数据。
    [peripheral setDelegate:self];
}

/*第五步：连接成功后，调用扫描蓝牙外设服务的代理
 [peripheral discoverServices:nil];
 */
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //
    // 连接外设成功后关闭扫描
    [self.centerManager stopScan];
    
    //隐藏加载图，修改连接状态
    [self hiddenAciv];
    [self changeCurrentPeripheralState];
    
     [ToolBox noticeContent:@"连接成功" andShowView:self.view andyOffset:NoticeHeight];
    
    //
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error//连接失败代理
{
    NSLog(@"didFailToConnectPeripheral====%@",error);
    [self hiddenAciv];
    [self changeCurrentPeripheralState];
    
    //        NSString *errorStr = [[NSString alloc] initWithFormat:@"%@",error];
    [ToolBox noticeContent:@"连接失败" andShowView:self.view andyOffset:NoticeHeight];
}
-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error//收到连接状态断开 代理
{
    NSLog(@"已断开连接");
    //隐藏加载图，修改连接状态
    [self hiddenAciv];
    [self changeCurrentPeripheralState];
    
    [ToolBox noticeContent:@"已断开连接" andShowView:self.view andyOffset:NoticeHeight];
}
#pragma mark  ======   CBPeripheralDelegate  =====
/*第六步：扫描到外设服务后，可以获取外设的服务特性
 [peripheral discoverCharacteristics:nil forService:service];
 */
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSString *UUID = [peripheral.identifier UUIDString];
    NSLog(@"didDiscoverServices:%@",UUID);
    if (error)
    {
        NSLog(@"出错====%@",error);
        [ToolBox noticeContent:@"出错啦" andShowView:self.view andyOffset:NoticeHeight];
        return;
    }
    
    CBUUID *cbUUID = [CBUUID UUIDWithString:UUID];
    NSLog(@"cbUUID:%@",cbUUID);
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"service:%@",service.UUID);
        //对外设的CBUUID进行所需的处理
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}
//第七步：扫描到指定外设的服务特性，根据外设特性进行交互
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    /*
     暂时没有打印机，俺先写个打印样式在这里吧。
    {
        NSArray *characteristics = service.characteristics;
        for (CBCharacteristic *characteristic in characteristics)
        {
            if([characteristic.UUID  isEqual:[CBUUID UUIDWithString:@""]])
            {
    
                NSString *str = [NSString stringWithFormat:@"\n快递单号：%@\n交易金额：%@\n成交时间：%@\n\n", @"N764175817414", @"88元",@"2018-05-16" ];
                NSData *data =[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
                //data 通过设置，可以打印二维码、条码、图形等。
                
                //需要注意打印长度的问题，有些打印机会出现换行或者乱码。
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                NSLog(@"开始打印.....");
                [ToolBox noticeContent:@"开始打印....." andShowView:self.view andyOffset:NoticeHeight];
            }
        }
    }
     */
    //
    
    if (error)
    {
        NSLog(@"出错===%@",error);
//        NSString *errorStr = [[NSString alloc] initWithFormat:@"%@",error];
        [ToolBox noticeContent:@"出错啦" andShowView:self.view andyOffset:NoticeHeight];
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
//如果需要打印，可以实现下面方法
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"打印完成");
    [ToolBox noticeContent:@"打印完成" andShowView:self.view andyOffset:NoticeHeight];
}

//外设管理器状态发生变化，初始化centerManger后，会走这里
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    /*
     温馨提示：
     由于ios11 🍎开发人员给iPhone一个新功能，在上来的控制中心里，我们可以快捷关闭wifi和蓝牙了。but，只是关闭当前连接着的蓝牙、wifi，也就是说，如果当前网络环境下还有可以连接到的wifi和蓝牙，你在控制中心关闭掉当前连接的之后，会重新寻找可连接网络去连接。如果想要完全关闭，需要进入到设置页面去关闭。
     嗨，苹果，你个地主家的傻儿子，租子收多了没事干吗？可恶。
     那么开发人员有什么问题呢？
     有！我发现，在设置中心打开蓝牙后，如果再去上拉的控制中心关闭掉蓝牙，就有问题了。这个代理中监听到的状态一直是4（可用，但是未打开。）如果你重新去设置中心关闭，再打开。状态变为正常，但是，保证手机蓝牙状态不变，再次打开app，这个代理监听到的状态还是4。未找到解决方法。
     希望有人可以给个帮助。
     */
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
            
            //扫描外设
            [self scan:nil];
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"可用，未打开");
            [self.peripherals removeAllObjects];
            _currentPeripheral = nil;
            [_tableView reloadData];
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
