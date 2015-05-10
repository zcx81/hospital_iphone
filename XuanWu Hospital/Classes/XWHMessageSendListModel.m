//
//  XWHMessageSendListModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/7.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageSendListModel.h"

/*
 {
 "messageRemindId": 472990,
 "subject": "娴嬭瘯",
 "is_list": true,
 "to_user_list": [
 {
 "if_readed": "N",
 "user_name": "test30"
 },
 {
 "if_readed": "N",
 "user_name": "test31"
 }
 ]
 },
 */

@implementation XWHMessageSendListModel

- (id)initWithDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        self.messageRemindId = [[diction objectForKey:@"messageRemindId"] integerValue];
        self.subject = [diction objectForKey:@"subject"];
        self.isAttachment = [[diction objectForKey:@"is_list"] boolValue];
        self.toUserList = [diction objectForKey:@"to_user_list"];
        self.sendTime = [diction objectForKey:@"send_time"];
    }
    return self;
}

@end
