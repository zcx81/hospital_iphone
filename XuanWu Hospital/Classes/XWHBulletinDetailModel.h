//
//  XWHBulletinDetailModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/4.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

//{"USERID":1,
//    "handlerId":1,
//    "bulletinId":10001,
//    "clicks":4,
//    "title":"测试",//主题
//    "create_time":"2014/03/06 15:14:30",
//    "bulletinTypeId":1,
//    "content":"<A style=\"LINE-HEIGHT: normal; COLOR: blue; CURSOR: hand\" href=\"http://192.168.2.249:8001/fileIoAction.do?cmd=download&amp;file_id=389820129\" target=_blank>梁老师需要伴奏的歌曲(1).docx<\/A>",//公告内容
//    "bulletinBoardId":102,
//    "userName":"系统管理员",//发表者
//    "bytes":"178",
//    "typeName":
//    "日常公告",//类型名称
//    "relateNews":[]//相关新闻
//}

@interface XWHBulletinDetailModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger bulletinId;
@property (assign, nonatomic) NSInteger clickCount;
@property (copy, nonatomic) NSString *createTime;
@property (assign, nonatomic) NSInteger bulletinTypeId;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *typeName;
@property (strong, nonatomic) NSArray *relateNews;
@property (strong, nonatomic) NSString *checkUser;
@property (strong, nonatomic) NSArray *attachFilesArray;

- (id)initWithDataDiction:(NSDictionary *)dictionary;

@end
