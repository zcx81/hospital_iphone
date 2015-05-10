//
//  XWHProcessStatus.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/19.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHProcessStatus.h"

@implementation XWHProcessStatus

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.activityId = [[dic objectForKey:@"activity_id"] integerValue];
        self.activityName = [dic objectForKey:@"activity_name"];
    }
    return self;
}

@end
