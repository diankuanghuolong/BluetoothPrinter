//
//  ViewController.m
//  BluetoothPrinter
//
//  Created by Ios_Developer on 2018/5/14.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "ViewController.h"
#import "PrintVCV.h"
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
    [btn addTarget:self action:@selector(gotoPrintVC:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 7;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
}
#pragma mark  =====  action  =====
-(void)gotoPrintVC:(id)sender
{
    PrintVCV *printVC = [PrintVCV new];
    [self.navigationController pushViewController:printVC animated:YES];
}

@end
