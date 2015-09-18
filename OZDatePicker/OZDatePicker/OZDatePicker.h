//
//  ZSJDatePicker.h
//  ZSJDatePicker
//
//  Created by omni on 15/8/26.
//  Copyright (c) 2015年 Unorganized. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol OZPickerDelegate;

@interface OZDatePicker : UIView <UITableViewDelegate, UITableViewDataSource> {
    
    CGFloat rowHeight;
    CGFloat centralRowOffset;
    
    NSMutableArray *minutes;
    NSMutableArray *hours;
    NSMutableArray *day;
    
    BOOL shouldUseShadows;
    
}

@property (nonatomic, weak) id<OZPickerDelegate> delegate;
@property (nonatomic, copy)NSCalendar *calendar;

@property (nonatomic, strong)UIColor *fontColor;

- (UITableView *)tableViewForComponent:(NSInteger)component;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (void)reloadData;
- (void)update;
- (NSDate*)getDate;
- (void)setShouldUseShadows:(BOOL)useShadows;
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end


@protocol OZPickerDelegate <NSObject>

@optional


- (UIView *)backgroundViewForDatePicker:(OZDatePicker*)picker;
- (UIColor *)backgroundColorForDatePicker:(OZDatePicker*)picker;

- (UIView *)datePicker:(OZDatePicker*)picker backgroundViewForComponent:(NSInteger)component;
- (UIColor *)datePicker:(OZDatePicker*)picker backgroundColorForComponent:(NSInteger)component;

- (UIView *)overlayViewForDatePickerSelector:(OZDatePicker *)picker;
- (UIColor *)overlayColorForDatePickerSelector:(OZDatePicker *)picker;

- (UIView *)viewForDatePickerSelector:(OZDatePicker *)picker;
- (UIColor *)viewColorForDatePickerSelector:(OZDatePicker *)picker;

@end
