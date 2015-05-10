//
//  XWHMessageReceiveListModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageReceiveListModel.h"
/*
 {
 "messageRemindId": 472985,
 "messageRemindUserId": 742774,
 "subject": "消息接收",
 "is_list": false,
 "if_readed": "Y",
 "from_user_name": "系统管理员"
 }
*/

@implementation XWHMessageReceiveListModel

- (id)initWithDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        self.messageRemindId = [[diction objectForKey:@"messageRemindId"] integerValue];
        self.messageRemindUserId = [[diction objectForKey:@"messageRemindUserId"] integerValue];
        self.subject = [diction objectForKey:@"subject"];
        self.isAttachment = [[diction objectForKey:@"is_list"] boolValue];
        if ([[diction objectForKey:@"if_readed"] isEqualToString:@"Y"]) {
            self.isReaded = YES;
        }
        self.fromUserName = [diction objectForKey:@"from_user_name"];
        self.sendTime = [diction objectForKey:@"send_time"];
    }
    return self;
}

@end
