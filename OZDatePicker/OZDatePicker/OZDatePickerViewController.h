//
//  ZSJDatePickerViewController.h
//  司机短租
//
//  Created by omni on 15/8/26.
//  Copyright (c) 2015年 Unorganized. All rights reserved.
//

#import "TDSemiModalViewController.h"
#import "OZDatePicker.h"

@protocol ZSJDatePickerDelegate;

@interface OZDatePickerViewController : TDSemiModalViewController
@property (nonatomic, strong) id<ZSJDatePickerDelegate> delegate;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (nonatomic,strong) OZDatePicker* datePicker;


@end

@protocol ZSJDatePickerDelegate <NSObject>

-(void)ensureChoice:(OZDatePickerViewController*)viewController;

-(void)cancelChoice;

@end