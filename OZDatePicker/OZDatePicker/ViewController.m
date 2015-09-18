//
//  ViewController.m
//  OZDatePicker
//
//  Created by omni on 15/9/18.
//  Copyright (c) 2015年 Unorganized. All rights reserved.
//

#import "ViewController.h"
#import "OZDatePickerViewController.h"
#import "TDSemiModal.h"

@interface ViewController ()
{
    OZDatePickerViewController* datePicker;
    NSDate* bookingDate;//预约时间

}
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDate)];
    [self.dateLabel addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)selectDate
{
    //选择时间
    datePicker = [[OZDatePickerViewController alloc]init];
    datePicker.delegate = (id<ZSJDatePickerDelegate>)self;
    [self presentSemiModalViewController:datePicker];
}

#pragma mark - DatePickerDelegate
-(void)ensureChoice:(OZDatePickerViewController*)viewController
{
    [self dismissSemiModalViewController:datePicker];
    bookingDate = viewController.datePicker.getDate;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* string = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:bookingDate]];
    self.dateLabel.text = string;
}

-(void)cancelChoice
{
    [self dismissSemiModalViewController:datePicker];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
