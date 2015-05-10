//
//  XWHBulletinDetailModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/4.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHBulletinDetailModel.h"

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

@implementation XWHBulletinDetailModel

- (id)initWithDataDiction:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.title = [dictionary objectForKey:@"title"];
            self.bulletinId = [[dictionary objectForKey:@"bulletinId"] integerValue];
            self.clickCount = [[dictionary objectForKey:@"clicks"] integerValue];
            self.createTime = [dictionary objectForKey:@"create_time"];
            self.bulletinTypeId = [[dictionary objectForKey:@"bulletinTypeId"] integerValue];
            self.content = [dictionary objectForKey:@"content"];
            self.userName = [dictionary objectForKey:@"userName"];
            self.typeName = [dictionary objectForKey:@"typeName"];
            self.checkUser = [dictionary objectForKey:@"checkUser"];
//            self.relateNews = [dictionary objectForKey:@"relateNews"];
            self.attachFilesArray = [dictionary objectForKey:@"attachFiles"];
        }
    }
    return self;
}

@end
