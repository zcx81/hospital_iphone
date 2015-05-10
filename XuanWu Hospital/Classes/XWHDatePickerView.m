//
//  XWHPublicView.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/25.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHDatePickerView.h"

@interface XWHDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *yearArray;
@property (strong, nonatomic) NSArray *monthArray;
@property (strong, nonatomic) NSMutableArray *dayArray;

@property (assign, nonatomic) NSInteger selectedYear;
@property (assign, nonatomic) NSInteger selectedMonth;
@property (assign, nonatomic) NSInteger currentYear;
@property (assign, nonatomic) NSInteger currentMonth;
@property (assign, nonatomic) NSInteger currentDay;

@end

@implementation XWHDatePickerView

- (void)awakeFromNib
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentyearString = [NSString stringWithFormat:@"%@",
                                   [formatter stringFromDate:date]];

    self.yearArray = [NSMutableArray array];
    for (NSInteger index = 2012; index <= [currentyearString integerValue]; index++) {
        [self.yearArray addObject:[NSNumber numberWithInteger:index]];
    }
    self.monthArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    self.dayArray = [NSMutableArray array];
    for (NSInteger index = 1; index <= 31; index++) {
        [self.dayArray addObject:[NSNumber numberWithInteger:index]];
    }
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)cancelAction:(id)sender {
    self.callBack(NO, @"");
}

- (IBAction)acrionDone:(id)sender {
    NSNumber *year = [self.yearArray objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSNumber *month = [self.monthArray objectAtIndex:[self.pickerView selectedRowInComponent:1]];
    NSNumber *day = [self.dayArray objectAtIndex:[self.pickerView selectedRowInComponent:2]];
    NSString *dateString = [NSString stringWithFormat:@"%@/%02d/%02d", year, [month intValue], [day intValue]];
    self.callBack(YES, dateString);
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.selectedYear = row;
        [self.pickerView reloadAllComponents];
    }
    else if (component == 1)
    {
        self.selectedMonth = row;
        [self.pickerView reloadAllComponents];
    }
    
}

#pragma mark - UIPickerViewDatasource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%@年",[self.yearArray objectAtIndex:row]];
    } else if (component == 1) {
        return [NSString stringWithFormat:@"%@月",[self.monthArray objectAtIndex:row]];
    } else {
        return [NSString stringWithFormat:@"%@日",[self.dayArray objectAtIndex:row]];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.yearArray count];
    } else if (component == 1) {
        return [self.monthArray count];
    } else { // day
        if (self.selectedMonth == 0 || self.selectedMonth == 2 || self.selectedMonth == 4 || self.selectedMonth == 6 || self.selectedMonth == 7 || self.selectedMonth == 9 || self.selectedMonth == 11) {
            return 31;
        } else if (self.selectedMonth == 1) {
            int yearint = [[self.yearArray objectAtIndex:self.selectedYear] integerValue];
            
            if(((yearint %4==0)&&(yearint %100!=0))||(yearint %400==0)){
                return 29;
            }
            else
            {
                return 28; // or return 29
            }
            
        } else {
            return 30;
        }
    }
}

- (void)initSelectData
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    
    self.currentYear = [[formatter stringFromDate:date] integerValue];
    
    [formatter setDateFormat:@"MM"];
    self.currentMonth = [[formatter stringFromDate:date] integerValue];
    
    [formatter setDateFormat:@"dd"];
    self.currentDay = [[formatter stringFromDate:date] integerValue];
    
    [self.pickerView selectRow:[self.yearArray indexOfObject:[NSNumber numberWithInteger:self.currentYear]] inComponent:0 animated:NO];
    [self.pickerView selectRow:self.currentMonth-1 inComponent:1 animated:NO];
    [self.pickerView selectRow:self.currentDay-1 inComponent:2 animated:NO];
}

- (void)initSelectDataWithStr:(NSString *)date
{
    if (date != nil && date.length != 0) {
        NSArray *array = [date componentsSeparatedByString:@"/"];
        if (array.count == 3) {
            self.currentYear = [[array firstObject] integerValue];
            self.currentMonth = [[array objectAtIndex:1] integerValue];
            self.currentDay = [[array objectAtIndex:2] integerValue];
            [self.pickerView selectRow:[self.yearArray indexOfObject:[NSNumber numberWithInteger:self.currentYear]] inComponent:0 animated:NO];
            [self.pickerView selectRow:self.currentMonth-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:self.currentDay-1 inComponent:2 animated:NO];
        }
    } else {
        [self initSelectData];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
