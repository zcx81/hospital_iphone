//
//  XWHMessageDetailModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/7.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageDetailModel.h"
/*
 {
 "messageRemindId":33417717,
 "sendTime":"2014/03/04 14:47:24",
 "subject":"似懂非懂双方的首发",
 "content":"",
 "fromUserId":1,//发送者ID
 "attachFiles":[
 {"FILE_ID":"389820125","FILE_NAME":"APP-IBM_存储产品客户端制作报价单","FILE_EXT":"xls"},
 {"FILE_ID":"389820126","FILE_NAME":"APP公司简介客户端报价","FILE_EXT":"xls"}],
 "fromUserName":"系统管理员",
 "rtnMsg":"9" "9" //查看成功  10 查看失败}
 */

@implementation XWHMessageDetailModel

- (id)initWithDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        self.messageRemindId = [[diction objectForKey:@"messageRemindId"] integerValue];
        self.sendTime = [diction objectForKey:@"sendTime"];
        self.subject = [diction objectForKey:@"subject"];
        self.content = [diction objectForKey:@"content"];
        self.fromUserId = [[diction objectForKey:@"fromUserId"] integerValue];
        self.fromUserName = [diction objectForKey:@"fromUserName"];
        self.attachFilesArray = [diction objectForKey:@"attachFiles"];
        self.userList = [diction objectForKey:@"userList"];
    }
    return self;
}


@end
