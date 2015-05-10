//
//  XWHDaiBanBigModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/2.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHDaiBanBigModel.h"
//{
//    "PROCDEF_NAME": "科主任请假申请",
//    "PROCDEF_ID": "164",
//    "CNT": "1"
//}

@implementation XWHDaiBanBigModel

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.procdefName = [dic objectForKey:@"PROCDEF_NAME"];
        self.procdefId = [[dic objectForKey:@"PROCDEF_ID"] integerValue];
        self.cnt = [[dic objectForKey:@"CNT"] integerValue];
    }
    return self;
}

@end
