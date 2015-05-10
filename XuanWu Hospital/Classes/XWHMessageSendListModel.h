//
//  XWHMessageSendListModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/7.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IF_READED @"if_readed"
#define USER_NAMES @"user_name"

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

@interface XWHMessageSendListModel : NSObject

@property (assign, nonatomic) NSInteger messageRemindId;
@property (assign, nonatomic) BOOL isAttachment;

@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *sendTime;
@property (strong, nonatomic) NSArray *toUserList;

- (id)initWithDiction:(NSDictionary *)diction;

@end
