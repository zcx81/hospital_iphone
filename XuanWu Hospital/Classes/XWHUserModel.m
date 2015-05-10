//
//  XWHUserModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/14.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHUserModel.h"
//{
//    "USER_ID": "171",
//    "USER_NAME": "张建",
//    "TOTALTITLE": "宣武医院/院领导",
//    "SPACE": "3072"
//}

@implementation XWHUserModel

- (id)initDataWithDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        self.userId = [[diction objectForKey:@"USER_ID"] integerValue];
        self.userName = [diction objectForKey:@"USER_NAME"];
        self.totalTitle = [diction objectForKey:@"TOTALTITLE"];
        self.space = [[diction objectForKey:@"SPACE"] integerValue];
    }
    return self;
}

@end
