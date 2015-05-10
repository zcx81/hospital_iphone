//
//  XWHWorkFlowRecord.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/16.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHWorkFlowRecord.h"

@implementation XWHWorkFlowRecord

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.taskName = [dic objectForKey:@"taskName"];
        self.ownerName = [dic objectForKey:@"ownerName"];
        self.executeTime = [dic objectForKey:@"executeTime"];
        self.agreeNameRecord = [dic objectForKey:@"agreeNameRecord"];
        self.ownerKeyPic = [dic objectForKey:@"ownerKeyPic"];
        self.attTextRecord = [dic objectForKey:@"attTextRecord"];
    }
    return self;
}

@end
