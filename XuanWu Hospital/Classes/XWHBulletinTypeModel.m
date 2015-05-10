//
//  XWHBulletinTypeModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHBulletinTypeModel.h"
/*
 {
 TBL_BULLETIN_TYPE_ID: "15",//公告板类型ID
 TBL_BULLETIN_TYPE_NAME: "行政管理",//类型名称
 CREATE_TIME: "2013/12/24 11:35:25",
 UPDATE_TIME: "2013/12/24 12:16:39",
 STATE: "A",
 ORDERID: "1"
 }
 */

@implementation XWHBulletinTypeModel

- (id)initWithDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        self.typeId = [[diction objectForKey:@"TBL_BULLETIN_TYPE_ID"] integerValue];
        self.typeName = [diction objectForKey:@"TBL_BULLETIN_TYPE_NAME"];
        self.createTime = [diction objectForKey:@"CREATE_TIME"];
        self.updateTime = [diction objectForKey:@"UPDATE_TIME"];
        self.state = [diction objectForKey:@"STATE"];
        self.orderId = [[diction objectForKey:@"ORDERID"] integerValue];
    }
    return self;
}

@end
