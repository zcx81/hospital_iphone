//
//  XWHHelper.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHHelper.h"

@implementation XWHHelper

+ (BOOL)dateFormatter:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *date = [formatter dateFromString:time];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    NSDateComponents *cps = [calendar components:unitFlags fromDate:date  toDate:now  options:0];
    if (cps.year !=0 || cps.month != 0 || cps.day > 2 || (cps.day == 2 && cps.hour > 12)) {
        return YES;
    } else {
        return NO;
    }
}

@end
