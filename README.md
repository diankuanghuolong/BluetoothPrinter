# BluetoothPrinter
BluetoothPrinter

[简书](https://www.jianshu.com/p/ec896828c363)

plist配置![plist配置](https://github.com/diankuanghuolong/BluetoothPrinter/blob/master/BluetoothPrinter/showImages/Pasted%20Graphic.png)


声明：本文借鉴多篇网络资源，记不全了。这里提供两个🔗：[🔗一](https://www.jianshu.com/p/1f479b6ab6df)

[另一个链接，因为看到多篇相似文章，不确定原作者是谁，就不给了。]

iOS模拟iPhone设置中蓝牙页面，实现蓝牙外设获取并连接，列表页面效果。

首先：
有两个代理需要了解：
```
CBCentralManagerDelegate（中心设备管理代理）CBPeripheralDelegate（外设代理）
```
使用步骤：
一.导入蓝牙所需框架
```
#import <CoreBluetooth/CoreBluetooth.h>
```
二.使用
  1.大致步骤如下：
```
  /*第一步：创建设备管理器
 创建完之后,会回调CBCentralManagerDelegate中的方法：- (void)centralManagerDidUpdateState:(CBCentralManager *)central
 */
-(void)initCBCentralManager
{
    self.centerManager = [[CBCentralManager alloc] init];
    self.centerManager = [self.centerManager initWithDelegate:self queue:nil];
    self.peripherals = [NSMutableArray array]; //存放所有扫描到的蓝牙外设
    NSLog(@"self.centerManager ===== %@",self.centerManager);
}
```
对于蓝牙监听状态方法，单独给出下。这里头有料。
```
//外设管理器状态发生变化，初始化centerManger后，会走这里
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    /*
     温馨提示：
     由于ios11 🍎开发人员给iPhone一个新功能，在上拉的控制中心里，我们可以快捷关闭wifi和蓝牙了。but，只是关闭当前连接着的蓝牙、wifi，也就是说，如果当前网络环境下还有可以连接到的wifi和蓝牙，你在控制中心关闭掉当前连接的之后，会重新寻找可连接网络去连接。如果想要完全关闭，需要进入到设置页面去关闭。
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
```
```
//第二步：扫描蓝牙外设
- (void)scan:(id)sender
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
}
```
下边只给出所需代理的方法名称，内部实现，可以在demo中
[查看](https://github.com/diankuanghuolong/BluetoothPrinter/blob/master/BluetoothPrinter/Print/printVC/PrintVCV.m)
```
#pragma mark  =====  CBCentralManagerDelegate  =====
/*第三步：扫描完成，将发现设备的不重复地添加到外设数组中
 这个代理方法每扫描到一个外设，就会进入一次。
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI//RSSI信号强度;
//第四步：连接蓝牙设备
- (void)connectPeripheral:(CBPeripheral *)peripheral;
/*第五步：连接成功后，调用扫描蓝牙外设服务的代理
 [peripheral discoverServices:nil];
 */
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;//连接失败代理
-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//收到连接状态断开 代理
#pragma mark  ======   CBPeripheralDelegate  =====
/*第六步：扫描到外设服务后，可以获取外设的服务特性
 [peripheral discoverCharacteristics:nil forService:service];
 */
 -(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error；
 //第七步：扫描到指定外设的服务特性，根据外设特性进行交互
 -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error；
 //如果需要打印，可以实现下面方法
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
```
![展示图片](https://github.com/diankuanghuolong/BluetoothPrinter/blob/master/BluetoothPrinter/showImages/bluetooth.gif)

