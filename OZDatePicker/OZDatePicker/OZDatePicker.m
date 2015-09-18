//
//  ZSJDatePicker.m
//  ZSJDatePicker
//
//  Created by omni on 15/8/26.
//  Copyright (c) 2015年 Unorganized. All rights reserved.
//

#import "OZDatePicker.h"
#import "UIColor+Addition.h"

@interface OZDatePicker()
{
//    NSDate* selDate;
//    NSInteger selHourInt,selMinuteInt;
}
@property (nonatomic, strong)NSMutableArray *tables;
@property (nonatomic, strong)NSMutableArray *selectedRowIndexes;
@property (nonatomic, strong)UIView *backgroundView;
@property (nonatomic, strong)UIView *overlay;
@property (nonatomic, strong)UIView *selector;


- (void)addContent;
- (void)removeContent;
- (void)updateDelegateSubviews;

- (NSInteger)componentFromTableView:(UITableView*)tableView;
- (void)alignTableViewToRowBoundary:(UITableView*)tableView;

@end

@implementation OZDatePicker


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        self.fontColor = [UIColor blackColor];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        shouldUseShadows = YES;
    }
    return self;
}

- (void) dealloc{
    
    self.tables = nil;
    self.selectedRowIndexes = nil;
    
    self.backgroundView = nil;
    self.overlay = nil;
    self.selector = nil;
    
}

- (void)update{
    //view
    [self removeContent];
    [self addContent];
    [self updateDelegateSubviews];
    
    //data
    [self fillWithCalendar];

    [[self.tables objectAtIndex:0] reloadData];


}

//返回tableView
- (UITableView *)tableViewForComponent:(NSInteger)component{
    
    return [self.tables objectAtIndex:component];
}

//当前选中的cell
- (NSInteger)selectedRowInComponent:(NSInteger)component{
    
    NSInteger current = [[self.selectedRowIndexes objectAtIndex:component] integerValue];
    NSLog(@"current cell %ld",current);
    return current;
}

//当前选中的cell集合
-(void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated{
    
    //替换index
    [self.selectedRowIndexes replaceObjectAtIndex:component withObject:[NSNumber numberWithInteger:row]];
    
    UITableView *table = [self.tables objectAtIndex:component];

    const CGPoint alignedOffset = CGPointMake(0, row*table.rowHeight - table.contentInset.top);
    [table setContentOffset:alignedOffset animated:animated];
    
    if (component == 0) {
        [[self.tables objectAtIndex:1] reloadData];
        [[self.tables objectAtIndex:2] reloadData];
        
    }else if (component == 1)
    {
        [[self.tables objectAtIndex:2] reloadData];

    }

}

#pragma mark - Date Method

- (void)setDate:(NSDate *)date animated:(BOOL)animated{
    
    //当前时间点
//    self.calendar.timeZone = [NSTimeZone localTimeZone];
//    NSDateComponents *dateComponents = [self.calendar components:(NSHourCalendarUnit  | NSMinuteCalendarUnit) fromDate:date];
//    NSInteger hour = [dateComponents hour];
//    NSInteger minute = [dateComponents minute];
    
    //第一列日期
    [self selectRow:0 inComponent:0 animated:YES];
    //第二列小时
    [self selectRow:0 inComponent:1 animated:YES];
    //第三列分钟
    //    NSInteger current = minute/5;
    [self selectRow:0 inComponent:2 animated:YES];

}

- (NSDate*)getDate
{
    NSMutableArray* selArr = [NSMutableArray array];
    for (UITableView* table in self.tables) {
        const CGPoint relativeOffset = CGPointMake(0, table.contentOffset.y+table.contentInset.top);
        const NSUInteger row = round(relativeOffset.y/table.rowHeight);
        [selArr addObject:[NSNumber numberWithInteger:row]];
    }
    
    //table 1当前的indexpath.row
    NSInteger one = [[selArr objectAtIndex:0] integerValue];
    //table 2当前的indexpath.row
    NSInteger two = [[selArr objectAtIndex:1] integerValue];
    //table 3当前的indexpath.row
    NSInteger three = [[selArr objectAtIndex:2] integerValue];
    
    //选择的日期
    NSDate* selDay = [day objectAtIndex:one];
    //选择的小时
    NSInteger hour = [[[hours objectAtIndex:one] objectAtIndex:two] integerValue];

    NSInteger hourArrCount = [[hours objectAtIndex:one] count] - 1;//小时的数量

    //当前Minute数据
    NSArray* tmpMinute;
    if (one == 0 && two == 0) {
        tmpMinute = minutes[0];
    }else if (one == 1 && two == hourArrCount)
    {
        tmpMinute = minutes[2];
    }else
    {
        tmpMinute = minutes[1];
    }
    
    NSInteger minute = [[tmpMinute objectAtIndex:three] integerValue];
    
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay) fromDate:selDay];

    NSDate* finalDate = [self dateWithYear:components.year month:components.month day:components.day hour:hour minute:minute];
    
    return finalDate;
    
}

//刷新数据
-(void)reloadData{
    
    for (UITableView *table in self.tables) {
        [table reloadData];
    }
}


#pragma mark - UITableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //每个tableView的cell个数
    const NSInteger component = [self componentFromTableView:tableView];
    return [self numberOfRowsInComponent:component];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"PickerCell";
    static const NSInteger tag = 4223;
    
    const NSInteger component = [self componentFromTableView:tableView];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *view = nil;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        const CGRect viewRect = cell.contentView.bounds;
        
        view = [self viewForComponent:component inRect:viewRect];

        view.frame = viewRect;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.tag = tag;
        cell.userInteractionEnabled = YES;
        view.userInteractionEnabled = YES;

        [cell.contentView addSubview:view];
    }else{
        view = [cell.contentView viewWithTag:tag];
    }
    
    //各个tableView中的cell元素
    [self setDataForView:view row:indexPath.row inComponent:component];
    
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    const NSInteger component = [self componentFromTableView:tableView];

    [self selectRow:indexPath.row inComponent:component animated:YES];

}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
        [self alignTableViewToRowBoundary:(UITableView *)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self alignTableViewToRowBoundary:(UITableView *)scrollView];
}


#pragma mark - Date Configuration
//填充日期
- (void)fillWithCalendar{

    /**
     *  day为今天和明天
     *  hours，minutes中分别存储了两天的数组，
     */
    //日历
//    NSCalendar *calendar = self.calendar;
//    calendar.timeZone = [NSTimeZone localTimeZone];
    
    NSDate *curDate = [NSDate date];//UTC时间。北上广深属于UTC+8时区

    /**
     *  默认是5分钟之内的整数值。如果需求是推迟30分钟，则将当前时间加上30min，作为当前时间即可。以此类推。
     */
//    curDate = [curDate dateByAddingTimeInterval:30 * 60];

    NSDateComponents *dateComponents = [self.calendar components:(NSHourCalendarUnit  | NSMinuteCalendarUnit) fromDate:curDate];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    
    NSInteger newHour = hour;
    if (minute>=55) {
        newHour++;//如果时间大于55分，往后推一个时间单位：1小时。如11：55，则newHour=12
    }
    
    hours = [NSMutableArray array];
    NSMutableArray* arr1 = [NSMutableArray array];
    NSMutableArray* arr2 = [NSMutableArray array];
    
    for (NSInteger i=0; i<24; i++) {
        if (newHour < 24)
        {
            [arr1 addObject:[NSNumber numberWithInteger:newHour]];
        }else
        {
            [arr2 addObject:[NSNumber numberWithInteger:(newHour-24)]];
        }
        
        newHour++;
    }
    
    if (minute < 55) {
        //比如11:40，明天的最后数组里面，也要加上11点，以便可以叫到11:35分之前的单
        [arr2 addObject:[NSNumber numberWithInteger:(newHour-24)]];//把明天的当前小时加入到明天的数组里（数组数量被额外增1）
    }
    
    [hours addObject:arr1];[hours addObject:arr2];
    
    
    minutes = [NSMutableArray array];
    NSMutableArray* arr3 = [NSMutableArray array];
    NSMutableArray* arr4 = [NSMutableArray array];
    NSInteger fiveDiv = minute/5+1;//往后推一个时间单位：5分钟
    for (NSInteger i=0; i<12; i++) {
        if (fiveDiv<12) {
            [arr3 addObject:[NSNumber numberWithInteger:fiveDiv*5]];
        }
        
        [arr4 addObject:[NSNumber numberWithInteger:i*5]];
 
        fiveDiv++;
    }

    if (minute>=55) {
        [arr3 addObject:[NSNumber numberWithInteger:0]];//把0分这个特殊值加入第一个数组
    }
    
    NSArray* arr5 = [NSArray array];
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arr3];
    arr5 = [arr4 filteredArrayUsingPredicate:filterPredicate];//从总的数组中过滤掉第一个数组中的内容。
    
    [minutes addObject:arr3];
    [minutes addObject:arr4];
    [minutes addObject:arr5];

    
    day = [NSMutableArray array];
    //把今天、明天加入进去
    NSDate* tomorrow = [NSDate dateWithTimeInterval:86400 sinceDate:curDate];

    [day addObject:curDate];
    [day addObject:tomorrow];
    
}


- (NSInteger)numberOfComponents
{
    return 3;
}


- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    //第一列选中的cell.第一列选中今天，数组取前半部分。第一列选中明天，数组
   
    NSInteger firstComponetSelected = [[self.selectedRowIndexes objectAtIndex:0] integerValue];
    NSInteger secondComponetSelected = [[self.selectedRowIndexes objectAtIndex:1] integerValue];
    NSInteger hourArrCount = [[hours objectAtIndex:1] count] - 1;//前面再最后加入了一个当前时间点，数字被增加了1.这里需要减去

    if (component == 0) {
        return 2;
    }
    else if (component == 1){
        NSArray* tmpHour = hours[firstComponetSelected];
        return [tmpHour count];
    }
    else if (component == 2){
        NSArray* tmpMinute;
        if (firstComponetSelected == 0 && secondComponetSelected == 0) {
            tmpMinute = minutes[0];
        }else if (firstComponetSelected == 1 && secondComponetSelected == hourArrCount)
        {
            tmpMinute = minutes[2];
        }else
        {
            tmpMinute = minutes[1];
        }
        return [tmpMinute count];

    }
    
    return 0;
}

#pragma Cell中SetDataSource
- (void)setDataForView:(UIView *)view row:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label = (UILabel *) view;
    
    NSInteger firstComponetSelected = [[self.selectedRowIndexes objectAtIndex:0] integerValue];
    NSInteger secondComponetSelected = [[self.selectedRowIndexes objectAtIndex:1] integerValue];
    NSInteger hourArrCount = [[hours objectAtIndex:1] count] - 1;

    if (component == 0) {
        
        NSDate* selDate = [day objectAtIndex:row];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSString* dayStr = [dateFormatter stringFromDate:selDate];

        if (row == 0) {
            dayStr = [@"今天 " stringByAppendingString:dayStr];
        }else if (row == 1)
        {
            dayStr = [@"明天 " stringByAppendingString:dayStr];
        }
        label.text = dayStr;
        
    }
    else if (component == 1){
        
        NSArray* hoursArr = [hours objectAtIndex:firstComponetSelected];
        NSInteger selHourInt = [[hoursArr objectAtIndex:row] integerValue];
        NSString* hourStr = [NSString stringWithFormat:@"%ld",selHourInt];
        label.text = hourStr;
        
    }
    else if (component == 2){
        
        NSArray* tmpMinute;
        if (firstComponetSelected == 0 && secondComponetSelected == 0) {
            tmpMinute = minutes[0];
        }else if (firstComponetSelected == 1 && secondComponetSelected == hourArrCount)
        {
            tmpMinute = minutes[2];
        }else
        {
            tmpMinute = minutes[1];
            
        }
        NSInteger selMinuteInt = [[tmpMinute objectAtIndex:row] integerValue];
        NSString* minuteStr = [NSString stringWithFormat:@"%ld",selMinuteInt];
        label.text = minuteStr;
    }
    
}

- (UIView *)viewForComponent:(NSInteger)component inRect:(CGRect)rect
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.fontColor;
    label.font = [UIFont systemFontOfSize:14];

    
    return label;
}


- (CGFloat) widthForComponent:(NSInteger)component
{
    CGFloat width = self.frame.size.width;
    
    switch (component) {
        case 0:
            width *= 0.6;
            break;
        case 1:
            width *= 0.2;
            break;
        case 2:
            width *= 0.2;
            break;
        default:
            return 0; // never
    }
    
    return round(width);
}


#pragma mark - Date Method


#pragma mark - Other methods

- (NSInteger)componentFromTableView:(UITableView *)tableView
{
    return [self.tables indexOfObject:tableView];
}

- (void)alignTableViewToRowBoundary:(UITableView *)tableView
{
    const CGPoint relativeOffset = CGPointMake(0, tableView.contentOffset.y + tableView.contentInset.top);
    const NSUInteger row = round(relativeOffset.y / tableView.rowHeight);
    
    const NSInteger component = [self componentFromTableView:tableView];
    [self selectRow:row inComponent:component animated:YES];
}


- (NSDate *)dateWithYear:(NSInteger)yearS month:(NSInteger)monthS day:(NSInteger)dayS hour:(NSInteger)hourS minute:(NSInteger)minuteS {
//    self.calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:yearS];
    [components setMonth:monthS];
    [components setDay:dayS];
    [components setHour:hourS];
    [components setMinute:minuteS];
    NSDate* tmpDate = [self.calendar dateFromComponents:components];
    return tmpDate;
}

- (void)setShouldUseShadows:(BOOL)useShadows{
    
    shouldUseShadows = useShadows;
    [self update];
}


#pragma mark - Content managemet
//创建3个TableView
- (void)addContent{
    
    rowHeight = 44;
    
    centralRowOffset = (self.frame.size.height - rowHeight)/2;
    
    const NSInteger components = [self numberOfComponents];
    
    self.tables = [[NSMutableArray alloc] init];
    self.selectedRowIndexes = [[NSMutableArray alloc] init];
    
    //创建三个tableView
    CGRect tableFrame = CGRectMake(0, 0, 0, self.bounds.size.height);
    for (NSInteger i = 0; i<components; ++i) {
        
        tableFrame.size.width = [self widthForComponent:i];
        
        
        UITableView *table = [[UITableView alloc] initWithFrame:tableFrame];
        table.rowHeight = rowHeight;
        table.contentInset = UIEdgeInsetsMake(centralRowOffset, 0, centralRowOffset, 0);
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.showsVerticalScrollIndicator = NO;
        
        table.dataSource = self;
        table.delegate = self;
        [self addSubview:table];
        
        [self.tables addObject:table];
        //初始化3个数
        [self.selectedRowIndexes addObject:[NSNumber numberWithInteger:0]];
        
        tableFrame.origin.x += tableFrame.size.width-5;
    }
    
    if (shouldUseShadows) {
        UIView *upperShadow = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height*2/5)];

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = upperShadow.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor],(id)[[UIColor colorWithHexString:@"f5f5f5" alpha:0.5f] CGColor],  nil];
        [upperShadow.layer insertSublayer:gradient atIndex:0];
        [upperShadow setUserInteractionEnabled:NO];
        
        [self addSubview:upperShadow];
        
        UIView *lowerShadow = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height-self.bounds.size.height*2/5, self.bounds.size.width, self.bounds.size.height*2/5)];

        CAGradientLayer *gradient2 = [CAGradientLayer layer];
        gradient2.frame = lowerShadow.bounds;
        gradient2.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithHexString:@"f5f5f5" alpha:0.5f] CGColor],(id)[[UIColor whiteColor] CGColor],  nil];
        [lowerShadow.layer insertSublayer:gradient2 atIndex:0];
        [lowerShadow setUserInteractionEnabled:NO];
        
        [self addSubview:lowerShadow];
    }
    
    
}


- (void)removeContent
{
    // remove tables
    for (UITableView *table in self.tables) {
        [table removeFromSuperview];
    }
    self.tables = nil;
    
    // remove indexes
    self.selectedRowIndexes = nil;
    
    // remove background
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    // remove overlay
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    
    // remove selector
    [self.selector removeFromSuperview];
    self.selector = nil;
}

//更新背景色设置等
- (void)updateDelegateSubviews
{
    // remove delegate subviews
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    [self.selector removeFromSuperview];
    self.selector = nil;
    
    // component background view/color
    NSUInteger i = 0;
    for (UITableView *table in self.tables) {
        if ([self.delegate respondsToSelector:@selector(datePicker:backgroundViewForComponent:)]) {
            table.backgroundView = [self.delegate datePicker:self backgroundViewForComponent:i];
        } else if ([self.delegate respondsToSelector:@selector(datePicker:backgroundColorForComponent:)]) {
            table.backgroundColor = [self.delegate datePicker:self backgroundColorForComponent:i];
        } else {
            table.backgroundColor = [UIColor whiteColor];
        }
        ++i;
    }
    
    // picker background
    if ([self.delegate respondsToSelector:@selector(backgroundViewForDatePicker:)]) {
        self.backgroundView = [self.delegate backgroundViewForDatePicker:self];
        
        // add and send to back
        [self addSubview:self.backgroundView];
        [self sendSubviewToBack:self.backgroundView];
    } else if ([self.delegate respondsToSelector:@selector(backgroundColorForDatePicker:)]) {
        self.backgroundColor = [self.delegate backgroundColorForDatePicker:self];
    }
    else{
        self.backgroundColor = [UIColor whiteColor];
    }
    
    // optional overlay
    if ([self.delegate respondsToSelector:@selector(overlayViewForDatePickerSelector:)]) {
        self.overlay = [self.delegate overlayViewForDatePickerSelector:self];
    } else if ([self.delegate respondsToSelector:@selector(overlayColorForDatePickerSelector:)]) {
        self.overlay = [[UIView alloc] init];
        self.overlay.backgroundColor = [self.delegate overlayColorForDatePickerSelector:self];
    }
    
    if (self.overlay) {
        
        // ignore user input on selector
        self.overlay.userInteractionEnabled = NO;
        
        // fill parent
        self.overlay.frame = self.bounds;
        [self addSubview:self.overlay];
    }
    
    // custom selector?
    if ([self.delegate respondsToSelector:@selector(viewForDatePickerSelector:)]) {
        self.selector = [self.delegate viewForDatePickerSelector:self];
    } else if ([self.delegate respondsToSelector:@selector(viewColorForDatePickerSelector:)]) {
        self.selector = [[UIView alloc] init];
        self.selector.backgroundColor = [self.delegate viewColorForDatePickerSelector:self];
        self.selector.alpha = 0.3;
    } else {
        self.selector = [[UIView alloc] init];
        self.selector.backgroundColor = [UIColor blackColor];
        self.selector.alpha = 0.3;
    }
    
    // ignore user input on selector
    self.selector.userInteractionEnabled = NO;
    
    // override selector frame
    CGRect selectorFrame;
    selectorFrame.origin.x = 0;
    selectorFrame.origin.y = centralRowOffset;
    selectorFrame.size.width = self.frame.size.width;
    selectorFrame.size.height = rowHeight;
    self.selector.frame = selectorFrame;
    
    [self addSubview:self.selector];
    
    
}

@end
