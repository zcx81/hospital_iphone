//
//  XWHHttpClient.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/3.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWHNetWorkResult.h"
#import "XWHAppUpdateModel.h"

typedef NS_ENUM(NSInteger, BulletinType)
{
    GONGGAO = 1,
    GONGSHI = 2
};

typedef NS_ENUM(NSInteger, MESSAGETYPE)
{
    RECEIVE_MESSAGE,
    SENT_MESSAGE
};

typedef void(^LoginHandler)(NetworkResult networkResult, NSInteger status);
typedef void(^GetBulletHandler)(NetworkResult networkResult, NSArray *array, NSInteger totalCount);
typedef void(^GetRtnMsg)(NetworkResult networkResult, NSInteger rtnMsg);

@interface XWHHttpClient : NSObject

+ (instancetype)sharedInstance;

//登录
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completeHandler:(LoginHandler)handler;
//获取公告列表
- (void)getBulletinListByPage:(NSInteger) page type:(BulletinType)type completeHandler:(GetBulletHandler)handler;

//根据条件对公告,公示进行搜索
- (void)searchBulletinWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria kindId:(NSInteger)kind page:(NSInteger)page type:(BulletinType)type completeHandler:(void(^)(NetworkResult networkResult, NSArray *array, NSInteger totalCount))handler;

//获取公告详情
- (void)getBulletDetailById:(NSInteger)bulletId completeHandler:(void(^)(NetworkResult networkResult, id detail))handler;
- (void)getBulletinKind:(void(^)(NetworkResult networkResult, NSArray *array))handler;
//发送公告
- (void)sendBulletinWithType:(BulletinType)kind title:(NSString *)title checkUser:(NSString *)checkUser typeId:(NSInteger)typeId content:(NSString *)content filesArray:(NSArray *)filesArray completehandler:(void (^)(NetworkResult, NSInteger))handler;

// 获取接收的消息列表
- (void)getReceiveMessageByPage:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSArray *array, NSInteger totalCount))handler;
//获取收到的消息详情，并且将其标为已读
- (void)readReceiveMessageById:(NSInteger)messageRemindId compltetHandler:(void(^)(NetworkResult networkResult, NSInteger renMsg, id detail))handler;
//删除收到的消息
- (void)deleteReceiveMessageByIdArray:(NSArray *)messageReminIdArray completeHandler:(void(^)(NetworkResult networResult, NSInteger renMsg))handler;

//获取已发送的消息列表
- (void)getSendMessageByPage:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSArray *array, NSInteger totalCount))handler;
//查看发送消息的详情
- (void)getSendMessageDetailById:(NSInteger)messageRemindId compltetHandler:(void(^)(NetworkResult networkResult, NSInteger renMsg, id detail))handler;
//删除已发送的消息
- (void)deleteSendMessageByIdArray:(NSArray *)messageIdArray completeHandler:(void(^)(NetworkResult networkResult, NSInteger renMsg))handler;

//发送消息
- (void)sendMessageToUser:(NSArray *)userIdAr subject:(NSString *)subject content:(NSString *)content filesArray:(NSArray *)filesArray completeHandler:(void (^)(NetworkResult, NSInteger))handler;
//设置消息已读未读
- (void)setMessageReadStatusByIdArray:(NSArray *)messageIdAr flag:(BOOL)flag completeHandler:(void(^)(NetworkResult networkResult, NSInteger rtnMsg))handler;

//根据条件对已收消息进行搜索
- (void)searchReceiveMessageWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria page:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSArray *array, NSInteger totalCount))handler;

//根据条件对已发消息进行搜索
- (void)searchSentMessageWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria page:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSArray *array, NSInteger totalCount))handler;

//转发消息
- (void)forwardMessageById:(NSInteger)messageId completeHandler:(void(^)(NetworkResult networkResult, NSInteger rtnMsg))handler;
//回复消息
- (void)replyMessageById:(NSInteger)messageId completeHandler:(GetRtnMsg)handler;

//获取所有用户
- (void)getUserListByKeywords:(NSString *)key page:(NSInteger)page completeHandler:(GetBulletHandler)handler;

//下载附件
- (void)downLoadAttachmentById:(NSInteger)attachmentId fileName:(NSString *)fileName completeHandler:(void(^)(NetworkResult networkResult, NSInteger rtnMsg, double precent, NSString *path))handler;

//检查是否右更新
- (void)checkUpdateStateHandler:(void(^)(NetworkResult networkResult, BOOL update, XWHAppUpdateModel *verModel))handler;

//获取所有流程
- (void)getAllWorkFlowHandler:(void(^)(NetworkResult networkResult, NSInteger rtnMsg, NSArray *array))handler;

//获取大流程下的小流程
- (void)getSmallWorkFlowById:(NSInteger)workId completeHandler:(void(^)(NetworkResult networkResult, NSInteger rtnMsg, NSArray *cellTitleArray, NSArray *data))handler;

//更具页数获取大流程下的小流程

- (void)getSmallWorkFLowById:(NSInteger)workId page:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSArray *cellTitleArray, NSArray *processStatus,NSArray *data, NSInteger totalCount))handler;

- (void)getSmallWorkFLowById:(NSInteger)workId page:(NSInteger)page dynamicParameter:(NSDictionary *)parsmetersDic completeHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSArray *cellTitleArray, NSArray *processStatus, NSArray *searchItems,NSArray *data, NSInteger totalCount))handler;

//办理流程
- (void)getSmallWorkFlowDetailById:(NSInteger)workId isFinish:(NSString *)flag activityId:(NSInteger)activityId completeHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSDictionary *formData, NSArray *recordArray, NSDictionary *dictionary, NSArray *agreeItems))handler;
//获取流程详情
- (void)getSmallWorkFlowDetailById:(NSInteger)workId isFinish:(NSString *)flag completeHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSDictionary *formData, NSArray *recordArray))handler;

//批示提交
- (void)postExecuteWorkFlow:(NSDictionary *)diction completer:(void(^)(NetworkResult networkResult, NSString *rtnMsg))handler;

//获取代办事宜大的
- (void)getAllWaiteWorkFlowHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSArray *array))handler;
//获取小的代办事宜
- (void)getSMallWaiteFlowById:(NSInteger)workId page:(NSInteger)page completeHandler:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSArray *array, NSInteger totalCount))handler;
//获取未读消息的数量
- (void)getMessageUnReadCount:(void(^)(NetworkResult networkResult, NSInteger count))handler;
//获取最近的未读消息
- (void)getLastUnReadMessage:(void(^)(NetworkResult networkResult, NSString *rtnMsg, id detail))handler;
//上传文件
- (void)upLoadFile:(NSString *)fileName complete:(void(^)(NetworkResult networkResult, NSString *rtnMsg, NSInteger fileId))handler;
//获取人员更新数据
- (void)updatePeopleDataComplete:(void(^)(NetworkResult networkResult, NSString *updateSql, NSString *dateTime))handler;

@end
