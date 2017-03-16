//
//  ViewController.m
//  CJTLunar
//
//  Created by chenjintian on 17/3/15.
//  Copyright © 2017年 CJT. All rights reserved.
//

#import "ViewController.h"

#import "CJTLunarPicker.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CJTLunarPicker *pickerView = [[CJTLunarPicker alloc] initWithFrame:[UIScreen mainScreen].bounds WithDate:[NSDate date]];
    
    [self.view addSubview:pickerView];
}


@end
