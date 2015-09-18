//
//  ZSJDatePickerViewController.m
//  司机短租
//
//  Created by omni on 15/8/26.
//  Copyright (c) 2015年 Unorganized. All rights reserved.
//

#import "OZDatePickerViewController.h"
#import "UIColor+Addition.h"

/*** MainScreen Height Width */
#define kScreen_height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define kScreen_width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度
@interface OZDatePickerViewController ()

@end

@implementation OZDatePickerViewController
@synthesize datePicker;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do an additional setup after loading the view.
    datePicker = [[OZDatePicker alloc] initWithFrame:CGRectMake(0, kScreen_height-216, kScreen_width, 216)];
    [datePicker setDelegate:(id<OZPickerDelegate>)self];
    [datePicker setFontColor:[UIColor blackColor]];
    [datePicker update];
//    [datePicker setDate:[NSDate date] animated:YES];
    
    [self.view addSubview:datePicker];
    
    UIView* toolBar = [[UIView alloc] initWithFrame:CGRectMake(0,kScreen_height-216-44, kScreen_width, 44)];
    toolBar.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];

    UIButton* leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 60, 30)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    leftBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancelChoice) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(80, 7, kScreen_width-80*2, 30)];
    titleLab.text = @"预约时间";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textColor = [UIColor colorWithHexString:@"333333"];
    
    UIButton* rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLab.frame)+10, 7, 60, 30)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn setTitle:@"选定" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(saveChoice) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:leftBtn];
    [toolBar addSubview:titleLab];
    [toolBar addSubview:rightBtn];
    
    [self.view addSubview:toolBar];
}


//当前指示颜色
- (UIColor*)viewColorForDatePickerSelector:(OZDatePicker *)picker
{
    return [UIColor whiteColor];
}


- (void)cancelChoice
{
    if ([self.delegate respondsToSelector:@selector(cancelChoice)]) {
        [self.delegate cancelChoice];
    }
}

- (void)saveChoice
{
    if ([self.delegate respondsToSelector:@selector(ensureChoice:)]) {
        [self.delegate ensureChoice:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
