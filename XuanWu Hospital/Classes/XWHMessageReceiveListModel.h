//
//  XWHMessageReceiveListModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@interface XWHMessageReceiveListModel : NSObject

@property (assign, nonatomic) NSInteger messageRemindId;
@property (assign, nonatomic) NSInteger messageRemindUserId;

@property (assign, nonatomic) BOOL isAttachment;
@property (assign, nonatomic) BOOL isReaded;

@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *fromUserName;
@property (copy, nonatomic) NSString *sendTime;

- (id)initWithDiction:(NSDictionary *)diction;

@end
