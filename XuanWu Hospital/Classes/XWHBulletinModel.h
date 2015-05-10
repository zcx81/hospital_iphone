//
//  XWHBulletinModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/4.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

//"bulletinList":[{
//    "bulletinId":4053,//公告ID
//    "bulletin_userId":778,//发表者ID
//    "bulletinTypeId":8,//类型
//    "is_link":"N",//只有为Y时候为超链接公告：连接地址是：link_content
//    "title":"2014年度申报国自然提交正式版流程",//公告标题
//    "bytes":"0",//大小
//    "update_time":"2014/02/14 15:08:39",//修改时间
//    "clicks":"66",//点击次数
//    "judgeLevel":"0",
//    "user_name":"郭秀海",//发表者
//    "link_content":""}]

@interface XWHBulletinModel : NSObject

@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *linkContent;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *updateTime;

@property (assign, nonatomic) NSInteger bulletinUserId;
@property (assign, nonatomic) NSInteger bulletinId;
@property (assign, nonatomic) NSInteger bulletinTypeId;
@property (assign, nonatomic) BOOL isLink;
@property (assign, nonatomic) NSInteger bytes;
@property (assign, nonatomic) NSInteger clickCount;
@property (assign, nonatomic) NSInteger judgeLevel;

- (id)initWithDataDiction:(NSDictionary *)diction;

@end
