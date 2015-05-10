//
//  XWHBulletinTypeModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
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
@interface XWHBulletinTypeModel : NSObject

@property (assign, nonatomic) NSInteger typeId;
@property (assign, nonatomic) NSInteger orderId;
@property (copy, nonatomic) NSString *typeName;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *updateTime;

- (id)initWithDiction:(NSDictionary *)diction;

@end
