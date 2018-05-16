//
//  ViewController.m
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/14.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothVC.h"
@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 140, 50)];
    [btn setTitle:@"进入蓝牙列表" forState:UIControlStateNormal];
    [btn setTitleColor:ThemeColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoBluetoothVC:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 7;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
    
    UIButton *printBtn = [[UIButton alloc] initWithFrame:CGRectMake(btn.left, btn.bottom + 10, btn.width, btn.height)];
    [printBtn setTitle:@"打印页面" forState:UIControlStateNormal];
    [printBtn setTitleColor:Origin_Color forState:UIControlStateNormal];
    [printBtn addTarget:self action:@selector(gotoPrintVC:) forControlEvents:UIControlEventTouchUpInside];
    printBtn.layer.cornerRadius = 7;
    printBtn.layer.masksToBounds = YES;
    [self.view addSubview:printBtn];
}
#pragma mark  =====  action  =====
-(void)gotoBluetoothVC:(id)sender
{
    BluetoothVC *bluetoothVC = [BluetoothVC new];
    [self.navigationController pushViewController:bluetoothVC animated:YES];
}
-(void)gotoPrintVC:(id)sender
{
    [ToolBox noticeContent:@"暂时没有打印机..." andShowView:self.view andyOffset:NoticeHeight];
}
@end
