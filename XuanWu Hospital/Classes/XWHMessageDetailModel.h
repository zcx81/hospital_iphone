//
//  XWHMessageDetailModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/7.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ATTACHFILE_ID @"FILE_ID"
#define ATTACHFILE_NAME @"FILE_NAME"
#define ATTACHFILE_EXT @"FILE_EXT"
#define USER_READ @"IF_READED"
#define USER_ID @"USER_ID"
#define USER_NAME @"USER_NAME"
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

/*
 {
 attachFiles =[
 {"FILE_ID":"389820125","FILE_NAME":"APP-IBM_存储产品客户端制作报价单","FILE_EXT":"xls"},
 {"FILE_ID":"389820126","FILE_NAME":"APP公司简介客户端报价","FILE_EXT":"xls"}];
 
 content = Jgjhgjh;
 fromUserId = 1;
 fromUserName = "\U7cfb\U7edf\U7ba1\U7406\U5458";
 messageRemindId = 473040;
 rtnMsg = 9;
 sendTime = "2014/09/14 01:06:24";
 subject = jhjhkjh;
 userList =     (
 {
 "IF_READED" = N;
 "USER_ID" = 3920;
 "USER_NAME" = test30;
 }
 );
 }
 */

@interface XWHMessageDetailModel : NSObject

@property (assign, nonatomic) NSInteger messageRemindId;
@property (assign, nonatomic) NSInteger fromUserId;

@property (copy, nonatomic) NSString *sendTime;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *fromUserName;

@property (strong, nonatomic) NSArray *attachFilesArray;
@property (strong, nonatomic) NSArray *userList;

- (id)initWithDiction:(NSDictionary *)diction;

@end
