//
//  XWHHttpClient.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/3.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHHttpClient.h"
#import "AFNetworking.h"
#import "XWHAppConfiguration.h"
#import "XWHBulletinModel.h"
#import "XWHBulletinDetailModel.h"
#import "XWHBulletinTypeModel.h"
#import "XWHDBManage.h"
#import "XWHMessageReceiveListModel.h"
#import "XWHMessageDetailModel.h"
#import "XWHMessageSendListModel.h"
#import "XWHUserModel.h"
#import "XWHWorkFlowBigModel.h"
#import "XWHWorkFlowSmallModel.h"
#import "XWHWorkFlowRecord.h"
#import "XWHProcessStatus.h"
#import "XWHProcessSearchItems.h"
#import "XWHProcessDetailAgreeItem.h"
#import "XWHTaskTokens.h"
#import "XWHDaiBanBigModel.h"
#import "XWHSmallScheduleModel.h"

//old http://124.254.56.94:8001/
//正式 http://114.255.80.180/
#if 0
#define BASEURL @"http://114.255.80.180/"
#else
#define BASEURL @"http://124.254.56.94:8001/"
#endif

#define ACTIONDO @"webToPhoneAndPad.do"

@interface XWHHttpClient ()

@property (strong, nonatomic) AFHTTPClient *httpClient;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation XWHHttpClient

+ (instancetype)sharedInstance
{
    static id shardInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shardInstance = [[self alloc] init];
    });
    return shardInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        self.httpClient.stringEncoding = enc;
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

/*
 {
 "USERID": 3920,
 "USERNAME": "test30",
 "HANDLERID": 4140,
 "o_id": 1,
 "directOfficeId": 236,
 "rtnMsg": "2",
 "USERROLE": [
 {
 "ROLE_ID": "149",
 "ROLE_NAME": "通知公告发布人"
 },
 {
 "ROLE_ID": "164",
 "ROLE_NAME": "科主任"
 }
 ]
 }
 */

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completeHandler:(LoginHandler)handler
{
    NSDictionary *diction = @{@"cmd":@"login",
                              @"login_name":userName,
                              @"login_pass":password
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil) {
            NSString *rtnMsg = [jsonData objectForKey:@"rtnMsg"];
            if ([rtnMsg integerValue] == 2) {
                NSString *userId = [NSString stringWithFormat:@"%d",[[jsonData objectForKey:@"USERID"] intValue]];
                NSString *handlerId = [NSString stringWithFormat:@"%d",[[jsonData objectForKey:@"HANDLERID"] intValue]];
                NSString *userName = [jsonData objectForKey:@"USERNAME"];
                [[XWHAppConfiguration sharedConfiguration] setUserID:userId];
                [[XWHAppConfiguration sharedConfiguration] setHandlerId:handlerId];
                [[XWHAppConfiguration sharedConfiguration] setUserName:userName];
            }
            handler(NetworkResultSuccess, [rtnMsg integerValue]);
        } else {
            handler(NetworkResultSuccess, -1);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], -1);
    }];
    
}

- (void)getBulletinListByPage:(NSInteger)page type:(BulletinType)type completeHandler:(GetBulletHandler)handler
{
    NSDictionary *diction = @{@"cmd":@"bullentinList",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[XWHAppConfiguration sharedConfiguration].handlerId,
                              @"page":[NSNumber numberWithInteger:page],
                              @"searchType":@"0",
                              @"ispub":(type==GONGGAO?@"1":@"2")
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger totalCount = [[jsonData valueForKey:@"record_count"] integerValue];
            if (totalCount != 0 && [jsonData valueForKey:@"bulletinList"] != nil) {
                NSArray *bulletinList = [jsonData valueForKey:@"bulletinList"];
                if ([bulletinList isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *diction in bulletinList) {
                        XWHBulletinModel *bulletinModel = [[XWHBulletinModel alloc] initWithDataDiction:diction];
                        [result addObject:bulletinModel];
                    }
                }
            }
            handler(NetworkResultSuccess, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, 0);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)getBulletDetailById:(NSInteger)bulletId completeHandler:(void (^)(NetworkResult, id))handler
{
    NSDictionary *diction = @{@"cmd":@"viewBullentin",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[XWHAppConfiguration sharedConfiguration].handlerId,
                              @"bulletinBoardId":@"102",
                              @"bulletinId":[NSNumber numberWithInteger:bulletId]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil) {
            XWHBulletinDetailModel *detail = [[XWHBulletinDetailModel alloc] initWithDataDiction:jsonData];
            handler(NetworkResultSuccess, detail);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil);
    }];
}

- (void)getBulletinKind:(void (^)(NetworkResult, NSArray *))handler
{
    NSDictionary *diction = @{@"cmd":@"getUser",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"flag":@"3"
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            for (NSDictionary *diction in jsonData) {
                XWHBulletinTypeModel *model = [[XWHBulletinTypeModel alloc] initWithDiction:diction];
                [result addObject:model];
            }
            [[XWHDBManage sharedInstance] insertBulletinType:result];
            handler(NetworkResultSuccess, result);
        } else {
            handler(NetworkResultSuccess, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil);
    }];
}

- (void)sendBulletinWithType:(BulletinType)kind title:(NSString *)title checkUser:(NSString *)checkUser typeId:(NSInteger)typeId content:(NSString *)content fileIdArray:(NSArray *)fileIdAr completehandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSString *fileAr = [fileIdAr componentsJoinedByString:@"@"];
    
    NSString *newTitle = [self chineseFormats:title];
    NSString *newContent = [self chineseFormats:content];
    NSDictionary *diction = @{@"cmd":@"addBullentin",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[XWHAppConfiguration sharedConfiguration].handlerId,
                              @"bulletinBoardId":@"102",
                              @"bulletinTypeId":[NSNumber numberWithInteger:typeId],
                              @"content":newContent,
                              @"title":newTitle,
                              @"checkUser":checkUser,
                              @"ispub":[NSNumber numberWithInteger:kind],
                              @"file_id":fileAr
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            handler(NetworkResultSuccess, rtnMsg);
        } else {
            handler(NetworkResultSuccess, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown,0);
    }];
}

- (void)sendBulletinWithType:(BulletinType)kind title:(NSString *)title checkUser:(NSString *)checkUser typeId:(NSInteger)typeId content:(NSString *)content filesArray:(NSArray *)filesArray completehandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSMutableArray *fileIdArray = [NSMutableArray array];
    NSMutableString *addContent = [NSMutableString stringWithFormat:@"%@", content];
    __block NSInteger count = filesArray.count;
    for (NSDictionary *diction in filesArray) {
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", [diction objectForKey:ATTACHFILE_NAME], [diction objectForKey:ATTACHFILE_EXT]];
        [self upLoadFile:fileName complete:^(NetworkResult networkResult, NSString *rtnMsg, NSInteger fileId) {
            if (networkResult == NetworkResultSuccess && [rtnMsg isEqualToString:@"SUCCESS"] && fileId != -1) {
                [fileIdArray addObject:[NSNumber numberWithInteger:fileId]];
                NSString *temp = [NSString stringWithFormat:@"<A href='/fileIoAction.do?cmd=download&amp;file_id=%d' target=_blank>%@</A></br>", fileId,fileName];
                [addContent appendString:temp];
            }
            count--;
            if (count == 0) {
                [self sendBulletinWithType:kind title:title checkUser:checkUser typeId:typeId content:addContent fileIdArray:fileIdArray completehandler:handler];
            }
            
        }];
    }
}

- (void)getReceiveMessageByPage:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSArray *, NSInteger))handler
{
    NSDictionary *diction = @{@"cmd":@"receiveListMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"page":[NSNumber numberWithInteger:page]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger totalCount = [[[jsonData firstObject] objectForKey:@"record_count"] integerValue];
            if (totalCount != 0) {
                for (NSInteger index = 1; index < jsonData.count; index++) {
                    NSDictionary *diction = [jsonData objectAtIndex:index];
                    XWHMessageReceiveListModel *model = [[XWHMessageReceiveListModel alloc] initWithDiction:diction];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)readReceiveMessageById:(NSInteger)messageRemindId compltetHandler:(void (^)(NetworkResult, NSInteger, id))handler
{
    NSDictionary *diction = @{@"cmd":@"viewChangeState",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindId":[NSNumber numberWithInteger:messageRemindId]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger reMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            if (reMsg == 9) {
                XWHMessageDetailModel *detailModel = [[XWHMessageDetailModel alloc] initWithDiction:jsonData];
                handler(NetworkResultSuccess, 9, detailModel);
            } else {
                handler(NetworkResultSuccess, reMsg, nil);
            }
        } else {
            handler(NetworkResultSuccess, 0, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, 0, nil);
    }];
}

- (void)getSendMessageByPage:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSArray *, NSInteger))handler
{
    NSDictionary *diction = @{@"cmd":@"sendListMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"page":[NSNumber numberWithInteger:page]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger totalCount = [[[jsonData firstObject] objectForKey:@"record_count"] integerValue];
            if (totalCount != 0) {
                for (NSInteger index = 1; index < jsonData.count; index++) {
                    NSDictionary *diction = [jsonData objectAtIndex:index];
                    XWHMessageSendListModel *model = [[XWHMessageSendListModel alloc] initWithDiction:diction];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)getSendMessageDetailById:(NSInteger)messageRemindId compltetHandler:(void (^)(NetworkResult, NSInteger, id))handler
{
    NSDictionary *diction = @{@"cmd":@"msgview",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindId":[NSNumber numberWithInteger:messageRemindId]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger reMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            if (reMsg == 9) {
                XWHMessageDetailModel *detailModel = [[XWHMessageDetailModel alloc] initWithDiction:jsonData];
                handler(NetworkResultSuccess, 9, detailModel);
            } else {
                handler(NetworkResultSuccess, reMsg, nil);
            }
        } else {
            handler(NetworkResultSuccess, 0, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, 0, nil);
    }];
}

- (void)deleteReceiveMessageByIdArray:(NSArray *)messageReminIdArray completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSString *idString = [messageReminIdArray componentsJoinedByString:@"@"];
    NSDictionary *diction = @{@"cmd":@"delReceivMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindUserIdArrayStr":idString
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            handler(NetworkResultSuccess, rtnMsg);
        } else {
            handler(NetworkResultSuccess, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, 0);
    }];
}

- (void)sendMessageToUser:(NSArray *)userIdAr subject:(NSString *)subject content:(NSString *)content fileId:(NSArray *)fileIdAr completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSString *idStr = [userIdAr componentsJoinedByString:@"@"];
    NSString *fileAr = [fileIdAr componentsJoinedByString:@"@"];
    
    NSDictionary *diction = @{@"cmd":@"MessageRapidSend",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"TOUSER":idStr,
                              @"subject":[self chineseFormats:subject],
                              @"content":[self chineseFormats:content],
                              @"file_id":fileAr
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            handler(NetworkResultSuccess, rtnMsg);
        } else {
            handler(NetworkResultSuccess, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, -1);
    }];
}

- (void)sendMessageToUser:(NSArray *)userIdAr subject:(NSString *)subject content:(NSString *)content filesArray:(NSArray *)filesArray completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    BOOL flag = YES;
    NSMutableArray *fileIdArray = [NSMutableArray array];
    __block NSInteger count = filesArray.count;
    for (NSDictionary *diction in filesArray) {
        NSInteger file_id = [[diction objectForKey:ATTACHFILE_ID] integerValue];
        if (file_id == -1) {
            flag = NO;
            NSString *fileName = [NSString stringWithFormat:@"%@.%@", [diction objectForKey:ATTACHFILE_NAME], [diction objectForKey:ATTACHFILE_EXT]];
            [self upLoadFile:fileName complete:^(NetworkResult networkResult, NSString *rtnMsg, NSInteger fileId) {
                if (networkResult == NetworkResultSuccess && [rtnMsg isEqualToString:@"SUCCESS"] && fileId != -1) {
                    [fileIdArray addObject:[NSNumber numberWithInteger:fileId]];
                }
                count--;
                if (count == 0) {
                    [self sendMessageToUser:userIdAr subject:subject content:content fileId:fileIdArray completeHandler:handler];
                }
                
            }];
        } else {
            [fileIdArray addObject:[diction objectForKey:ATTACHFILE_ID]];
            count--;
        }
    }
    if (flag) {
        [self sendMessageToUser:userIdAr subject:subject content:content fileId:fileIdArray completeHandler:handler];
        return;
    }
}

- (void)deleteSendMessageByIdArray:(NSArray *)messageIdArray completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSString *idString = [messageIdArray componentsJoinedByString:@"@"];
    NSDictionary *diction = @{@"cmd":@"delSendMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindIdStr":idString
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            handler(NetworkResultSuccess, rtnMsg);
        } else {
            handler(NetworkResultSuccess, -1);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, -1);
    }];
}

- (void)setMessageReadStatusByIdArray:(NSArray *)messageIdAr flag:(BOOL)flag completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    __block NSInteger count = messageIdAr.count;
    for (NSNumber *number in messageIdAr) {
        NSDictionary *diction = @{@"cmd":@"updateMsgState",
                                  @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                                  @"messageRemindId":number,
                                  @"isread":flag?@"Y":@"N"
                                  };
        [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
            count--;
            if (count == 0) {
                NSDictionary *jsonData = [self dataformatsWithData:responseObject];
                if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
                    NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
                    handler(NetworkResultSuccess, rtnMsg);
                }

            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            count--;
            if (count == 0) {
                handler(NetworkResultFailedUnknown, -1);
            }
        }];
    }
}

- (void)searchReceiveMessageWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria page:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSArray *, NSInteger))handler
{
    NSInteger searchType = 0;
    if ([criteria isEqualToString:@"主题"]) {
        searchType = 1;
    } else if ([criteria isEqualToString:@"内容"]) {
        searchType = 2;
    } else if ([criteria isEqualToString:@"发送者"]) {
        searchType = 3;
    }
    searchType = 1;
    NSDictionary *diction = @{@"cmd":@"receiveListMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"page":[NSNumber numberWithInteger:page],
                              @"searchType":[NSNumber numberWithInteger:searchType],
                              @"searchname":key==nil?@"":key,
                              @"start_date":start==nil?@"":start,
                              @"end_date":end==nil?@"":end
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger totalCount = [[[jsonData firstObject] objectForKey:@"record_count"] integerValue];
            if (totalCount != 0) {
                for (NSInteger index = 1; index < jsonData.count; index++) {
                    NSDictionary *diction = [jsonData objectAtIndex:index];
                    XWHMessageReceiveListModel *model = [[XWHMessageReceiveListModel alloc] initWithDiction:diction];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)searchSentMessageWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria page:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSArray *, NSInteger))handler
{
    NSInteger searchType = 0;
    if ([criteria isEqualToString:@"主题"]) {
        searchType = 1;
    } else if ([criteria isEqualToString:@"内容"]) {
        searchType = 2;
    }
    searchType = 1;
    NSDictionary *diction = @{@"cmd":@"sendListMsg",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"page":[NSNumber numberWithInteger:page],
                              @"searchType":[NSNumber numberWithInteger:searchType],
                              @"searchname":key==nil?@"":key,
                              @"start_date":start==nil?@"":start,
                              @"end_date":end==nil?@"":end
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger totalCount = [[[jsonData firstObject] objectForKey:@"record_count"] integerValue];
            if (totalCount != 0) {
                for (NSInteger index = 1; index < jsonData.count; index++) {
                    NSDictionary *diction = [jsonData objectAtIndex:index];
                    XWHMessageSendListModel *model = [[XWHMessageSendListModel alloc] initWithDiction:diction];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)searchBulletinWithStartDate:(NSString *)start endDate:(NSString *)end keyWord:(NSString *)key criteria:(NSString *)criteria kindId:(NSInteger)kind page:(NSInteger)page type:(BulletinType)type completeHandler:(void (^)(NetworkResult, NSArray *, NSInteger))handler
{
    NSInteger searchType = 0;
    if ([criteria isEqualToString:@"主题"]) {
        searchType = 1;
    } else if ([criteria isEqualToString:@"内容"]) {
        searchType = 2;
    }
    searchType = 1;
    NSDictionary *diction = @{@"cmd":@"bullentinList",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[XWHAppConfiguration sharedConfiguration].handlerId,
                              @"page":[NSNumber numberWithInteger:page],
                              @"bulletinTypeId":[NSNumber numberWithInteger:kind],
                              @"searchType":[NSNumber numberWithInteger:searchType],
                              @"searchName":key==nil?@"":key,
                              @"StartDate":start==nil?@"":start,
                              @"EndDate":end==nil?@"":end,
                              @"ispub":(type==GONGGAO?@"1":@"2")
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
        if (rtnMsg == 9) {
            if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *result = [NSMutableArray array];
                NSInteger totalCount = [[jsonData objectForKey:@"record_count"] integerValue];
                NSArray *bulletinList = [jsonData objectForKey:@"bulletinList"];
                if (totalCount != 0) {
                    for (NSDictionary *diction in bulletinList) {
                        XWHBulletinModel *bulletinModel = [[XWHBulletinModel alloc] initWithDataDiction:diction];
                        [result addObject:bulletinModel];
                    }
                }
                handler(NetworkResultSuccess, result, totalCount);
            } else {
                handler(NetworkResultSuccess, nil, 0);
            }
        } else {
            handler(NetworkResultSuccess, nil, rtnMsg);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)forwardMessageById:(NSInteger)messageId completeHandler:(void (^)(NetworkResult, NSInteger))handler
{
    NSDictionary *diction = @{@"cmd":@"forward",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindId":[NSNumber numberWithInteger:messageId],
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger rtnMsg = -1;
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
        }
        handler(NetworkResultSuccess, rtnMsg);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, -1);
    }];
}

- (void)replyMessageById:(NSInteger)messageId completeHandler:(GetRtnMsg)handler
{
    NSDictionary *diction = @{@"cmd":@"replay",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"messageRemindId":[NSNumber numberWithInteger:messageId],
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger rtnMsg = -1;
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
        }
        handler(NetworkResultSuccess, rtnMsg);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, -1);
    }];
}

- (void)getUserListByKeywords:(NSString *)key page:(NSInteger)page completeHandler:(GetBulletHandler)handler
{
    NSDictionary *diction = @{@"cmd":@"getUser",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"searchName":key==nil?@"":key,
                              @"flag":@"4",
                              @"page":[NSNumber numberWithInteger:page]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = [self dataformatsWithData:responseObject];
        NSInteger totalCount = 0;
        NSMutableArray *result = nil;
        if (jsonData != nil && [jsonData isKindOfClass:[NSArray class]]) {
            totalCount = [[[jsonData firstObject] objectForKey:@"record_count"] integerValue];
            if (totalCount != 0) {
                result = [NSMutableArray array];
                for (NSInteger index = 1; index < jsonData.count; index++) {
                    NSDictionary *diction = [jsonData objectAtIndex:index];
                    XWHUserModel *model = [[XWHUserModel alloc] initDataWithDiction:diction];
                    [result addObject:model];
                }
            }
        }
        handler(NetworkResultSuccess, result, totalCount);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, 0);
    }];
}

- (void)downLoadAttachmentById:(NSInteger)attachmentId fileName:(NSString *)fileName completeHandler:(void (^)(NetworkResult, NSInteger, CGFloat, NSString *))handler
{
    NSString *path = [[[XWHAppConfiguration sharedConfiguration] getAttachmentDirectory] stringByAppendingPathComponent:fileName];
    NSDictionary *diction = @{
                              @"cmd":@"downloadFileBox",
                              @"file_id":[NSNumber numberWithInteger:attachmentId]
                                  };
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:ACTIONDO parameters:diction];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat precent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        NSLog(@"下载进度%f", precent);
        handler(NetworkResultSuccess, 9, precent, path);
    }];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"下载成功");
        handler(NetworkResultSuccess, 500, 1, path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"下载失败");
        handler(NetworkResultFailedUnknown, 550, 0, path);
    }];
    [self.httpClient.operationQueue addOperation:op];
}

- (void)checkUpdateStateHandler:(void (^)(NetworkResult, BOOL, XWHAppUpdateModel *))handler
{
    NSDictionary *diction = @{@"cmd":@"getVersion",
                              @"tag":@"1",
                              @"versions":[[XWHAppConfiguration sharedConfiguration] versionInfo]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtnMsg = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            NSArray *updateArray = [jsonData objectForKey:@"verinfos"];
            BOOL flag = NO;
            if (rtnMsg == 2) {
                flag = YES;
            }
            if ([updateArray isKindOfClass:[NSArray class]] && updateArray.count != 0) {
                NSDictionary *obj = [updateArray firstObject];
                XWHAppUpdateModel *versionModel = [[XWHAppUpdateModel alloc] init];
                versionModel.verName = [obj objectForKey:@"VER_NAME"];
                versionModel.descriptions = [obj objectForKey:@"DES"];
                versionModel.url = [obj objectForKey:@"URL"];
                versionModel.size = [[obj objectForKey:@"SIZE1"] floatValue];
                versionModel.environment = [obj objectForKey:@"ENVIRONMENT"];
                versionModel.updateTime = [obj objectForKey:@"UPDATE_TIME"];
                handler(NetworkResultSuccess, flag, versionModel);
            } else {
                handler(NetworkResultSuccess, flag, nil);
            }
        } else {
            handler(NetworkResultSuccess, NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], NO, nil);
    }];
}

- (void)getAllWorkFlowHandler:(void (^)(NetworkResult, NSInteger, NSArray *))handler
{
    NSDictionary *diction = @{@"cmd":@"allWf",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[[XWHAppConfiguration sharedConfiguration] handlerId]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSInteger rtn = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            if (rtn == 1) {
                NSArray *officeLeftListArray = [jsonData objectForKey:@"officeList_L"];
                for (NSDictionary *obj in officeLeftListArray) {
                    NSString *officeName = [obj objectForKey:@"officeName"];
                    NSArray *progressArray = [obj objectForKey:@"procdefLists"];
                    for (NSDictionary *a in progressArray) {
                        XWHWorkFlowBigModel *model = [[XWHWorkFlowBigModel alloc] init];
                        model.officeName = officeName;
                        model.workFlowId = [[a objectForKey:@"procdefId"] integerValue];
                        model.workFlowName = [a objectForKey:@"processName"];
                        [result addObject:model];
                    }
                }
                NSArray *officeRightListArray = [jsonData objectForKey:@"officeList_R"];
                for (NSDictionary *obj in officeRightListArray) {
                    NSString *officeName = [obj objectForKey:@"officeName"];
                    NSArray *progressArray = [obj objectForKey:@"procdefLists"];
                    for (NSDictionary *a in progressArray) {
                        XWHWorkFlowBigModel *model = [[XWHWorkFlowBigModel alloc] init];
                        model.officeName = officeName;
                        model.workFlowId = [[a objectForKey:@"procdefId"] integerValue];
                        model.workFlowName = [a objectForKey:@"processName"];
                        [result addObject:model];
                    }
                }
            }
            handler(NetworkResultSuccess, rtn, result);
        } else {
            handler(NetworkResultSuccess, -1, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], -1, nil);
    }];
}


- (void)getSmallWorkFlowById:(NSInteger)workId completeHandler:(void (^)(NetworkResult, NSInteger, NSArray *, NSArray *))handler
{
    NSDictionary *diction = @{@"cmd":@"search",
                              @"SESSION":[XWHAppConfiguration sharedConfiguration].userID,
                              @"HANDLERID":[[XWHAppConfiguration sharedConfiguration] handlerId],
                              @"procdef_id":[NSString stringWithFormat:@"%ld",(long)workId]
                              };
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSInteger rtn = [[jsonData objectForKey:@"rtnMsg"] integerValue];
            if (rtn == 2) {
                NSArray *titleArray = [jsonData objectForKey:@"list_items"];
                NSMutableArray *title = [NSMutableArray array];
                for (NSDictionary *obj in titleArray) {
                    [title addObject:[obj objectForKey:@"item_label"]];
                }
                NSMutableArray *progressArray = [NSMutableArray array];
                for (NSDictionary *temp in [jsonData objectForKey:@"ProcessLists"]) {
                    XWHWorkFlowSmallModel *model = [[XWHWorkFlowSmallModel alloc] init];
                    model.processId = [[temp objectForKey:@"process_id"] integerValue];
                    model.isFinish = [[temp objectForKey:@"is_finish"] isEqualToString:@"F"]?YES:NO;
                    NSMutableArray *tempArray = [NSMutableArray array];
                    for (NSDictionary *dictionary in [temp objectForKey:@"ProcessItems"]) {
                        [tempArray addObject:[dictionary objectForKey:@"ctntValue"]];
                    }
                    model.valuesArray = tempArray;
                    [progressArray addObject:model];
                }
                handler(NetworkResultSuccess, rtn, title, progressArray);
            } else {
                handler(NetworkResultSuccess, rtn, nil, nil);
            }
        } else {
            handler(NetworkResultSuccess, -1, nil, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], -1, nil, nil);
    }];
}

- (void)getSmallWorkFLowById:(NSInteger)workId page:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSString *, NSArray *, NSArray *, NSArray *, NSInteger))handler
{
    NSDictionary *dictionary = @{@"cmd":@"search",
                                 @"tag":@"phone",
                                 @"procdef_id":[NSString stringWithFormat:@"%ld",workId],
                                 @"page":[NSString stringWithFormat:@"%ld",page]};
    [self postPath:@"wfMenuAction.do" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSInteger count = [[jsonData objectForKey:@"record_count"] integerValue];
                NSArray *titleArray = [jsonData objectForKey:@"list_items"];
                NSMutableArray *title = [NSMutableArray array];
                [title addObject:@"流程序号"];
                for (NSDictionary *obj in titleArray) {
                    [title addObject:[obj objectForKey:@"item_label"]];
                }
                [title addObjectsFromArray:@[@"流程状态",@"当前处理人",@"操作"]];
                
                NSMutableArray *progressArray = [NSMutableArray array];
                for (NSDictionary *temp in [jsonData objectForKey:@"ProcessLists"]) {
                    XWHWorkFlowSmallModel *model = [[XWHWorkFlowSmallModel alloc] init];
                    model.processId = [[temp objectForKey:@"process_id"] integerValue];
                    model.isFinish = [[temp objectForKey:@"is_finish"] isEqualToString:@"F"]?YES:NO;
                    if (!model.isFinish) {
                        NSDictionary *d = [[temp objectForKey:@"ProcessTasks"] firstObject];
                        model.processStatus = [d objectForKey:@"task_name"] == nil?@"流程异常":[d objectForKey:@"task_name"];
                        NSMutableArray *tokensArray = [NSMutableArray array];
                        NSMutableString *people = [[NSMutableString alloc] init];
                        for (NSDictionary *temp in [d objectForKey:@"TaskTokens"]) {
                            XWHTaskTokens *obj = [[XWHTaskTokens alloc] initWithDictionary:temp];
                            [tokensArray addObject:obj];
                            [people appendString:obj.name];
                        }
                        model.currentPeople = people;
                        model.taskTokens = tokensArray;
                    } else {
                        model.processStatus = @"已完成";
                        model.currentPeople = @"已完成";
                    }
                    NSMutableArray *tempArray = [NSMutableArray array];
                    [tempArray addObject:[NSString stringWithFormat:@"%ld",(NSInteger)model.processId]];
                    for (NSDictionary *dictionary in [temp objectForKey:@"ProcessItems"]) {
                        [tempArray addObject:[dictionary objectForKey:@"ctntValue"]];
                    }
                    [tempArray addObject:model.processStatus];
                    [tempArray addObject:model.currentPeople];
                    model.valuesArray = tempArray;
                    [progressArray addObject:model];
                }
                NSMutableArray *statusArray = [NSMutableArray array];
                for (NSDictionary *obj in [jsonData objectForKey:@"processStatusRF"]) {
                    XWHProcessStatus *status = [[XWHProcessStatus alloc] initWithDictionary:obj];
                    [statusArray addObject:status];
                }
                handler(NetworkResultSuccess, rtn, title, statusArray,progressArray, count);
            } else {
                handler(NetworkResultSuccess, rtn, nil, nil, nil, 0);
            }
        } else {
            handler(NetworkResultSuccess, nil, nil, nil, nil,0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil, nil, nil, 0);
    }];
}

- (void)getSmallWorkFLowById:(NSInteger)workId page:(NSInteger)page dynamicParameter:(NSDictionary *)parsmetersDic completeHandler:(void (^)(NetworkResult, NSString *, NSArray *, NSArray *, NSArray *, NSArray *, NSInteger))handler
{
    NSDictionary *dictionary = @{@"cmd":@"search",
                                 @"tag":@"phone",
                                 @"procdef_id":[NSString stringWithFormat:@"%ld",workId],
                                 @"page":[NSString stringWithFormat:@"%ld",page]};
    NSMutableDictionary *allPars = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    if (parsmetersDic != nil && parsmetersDic.count != 0) {
        [allPars addEntriesFromDictionary:parsmetersDic];
    }
    
    [self postPath:@"wfMenuAction.do" parameters:allPars success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSInteger count = [[jsonData objectForKey:@"record_count"] integerValue];
                NSArray *titleArray = [jsonData objectForKey:@"list_items"];
                NSMutableArray *title = [NSMutableArray array];
                [title addObject:@"流程序号"];
                NSInteger peopleIndex = 0;
                NSInteger timeIndex = 0;
                for (NSInteger index = 0; index < titleArray.count; index++) {
                    NSDictionary *obj = [titleArray objectAtIndex:index];
                    NSString *temp = [obj objectForKey:@"item_label"];
                    [title addObject:temp];
                    if ([temp rangeOfString:@"申请人"].location != NSNotFound || [temp rangeOfString:@"姓名"].location != NSNotFound) {
                        peopleIndex = index;
                    } else if ([temp rangeOfString:@"申请时间"].location != NSNotFound || [temp rangeOfString:@"申请日期"].location != NSNotFound) {
                        timeIndex = index;
                    }
                
                }
                [title addObjectsFromArray:@[@"流程状态",@"当前处理人",@"操作"]];
                
                NSMutableArray *progressArray = [NSMutableArray array];
                for (NSDictionary *temp in [jsonData objectForKey:@"ProcessLists"]) {
                    XWHWorkFlowSmallModel *model = [[XWHWorkFlowSmallModel alloc] init];
                    model.processId = [[temp objectForKey:@"process_id"] integerValue];
                    model.isFinish = [[temp objectForKey:@"is_finish"] isEqualToString:@"F"]?YES:NO;
                    if (!model.isFinish) {
                        NSDictionary *d = [[temp objectForKey:@"ProcessTasks"] firstObject];
                        model.processStatus = [d objectForKey:@"task_name"] == nil?@"流程异常":[d objectForKey:@"task_name"];
                        NSMutableArray *tokensArray = [NSMutableArray array];
                        NSMutableString *people = [[NSMutableString alloc] init];
                        BOOL flag = NO;
                        for (NSDictionary *temp in [d objectForKey:@"TaskTokens"]) {
                            XWHTaskTokens *obj = [[XWHTaskTokens alloc] initWithDictionary:temp];
                            [tokensArray addObject:obj];
                            [people appendString:obj.name];
                            [people appendString:@" "];
                            if (([obj.name isEqualToString:[XWHAppConfiguration sharedConfiguration].userName] || [obj.name rangeOfString:[XWHAppConfiguration sharedConfiguration].userName].location != NSNotFound) && obj.cnt > 0) {
                                flag = YES;
                            }
                        }
                        model.isCanBanli = flag;
                        model.currentPeople = people;
                        model.taskTokens = tokensArray;
                        
                        NSInteger activityId = [[d objectForKey:@"activity_id"] integerValue];
                        model.activityId = activityId;
                    } else {
                        model.processStatus = @"已完成";
                        model.currentPeople = @" ";
                    }
                    NSMutableArray *tempArray = [NSMutableArray array];
//                    [tempArray addObject:[NSString stringWithFormat:@"%ld",model.processId]];
                    NSArray *processItems = [temp objectForKey:@"ProcessItems"];
                    if (processItems.count > peopleIndex) {
                        [tempArray addObject:[[[processItems objectAtIndex:peopleIndex] objectForKey:@"ctntValue"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""]];
                    }
                    if (processItems.count > timeIndex) {
                        [tempArray addObject:[[[processItems objectAtIndex:timeIndex] objectForKey:@"ctntValue"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""]];
                    }
                    
//                    for (NSDictionary *dictionary in [temp objectForKey:@"ProcessItems"]) {
//                        NSString *temp = [[dictionary objectForKey:@"ctntValue"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
//                        [tempArray addObject:temp];
//                    }
//                    NSLog(@"model progressStatus = %@, currentPeople = %@",model.processStatus, model.currentPeople);
                    [tempArray addObject:model.processStatus];
                    [tempArray addObject:model.currentPeople];
                    model.valuesArray = tempArray;
                    [progressArray addObject:model];
                }
                NSMutableArray *statusArray = [NSMutableArray array];
                for (NSDictionary *obj in [jsonData objectForKey:@"processStatusRF"]) {
                    XWHProcessStatus *status = [[XWHProcessStatus alloc] initWithDictionary:obj];
                    [statusArray addObject:status];
                }
                NSMutableArray *parsArray = [NSMutableArray array];
                for (NSDictionary *obj in [jsonData objectForKey:@"processSeachItems"]) {
                    NSInteger typeId = [[obj objectForKey:@"item_type_id"] integerValue];
                    if (typeId == 11) {//申请人
                        XWHProcessSearchItems *item = [[XWHProcessSearchItems alloc] init];
                        item.itemName = [obj objectForKey:@"item_name"];
                        item.itemTypeId = [[obj objectForKey:@"item_type_id"] integerValue];
                        item.itemId = [obj objectForKey:@"item_id"];
                        [parsArray addObject:item];
                    } else if (typeId == 13) {//申请时间
                        XWHProcessSearchItems *item = [[XWHProcessSearchItems alloc] init];
                        item.itemName = [obj objectForKey:@"item_name"];
                        item.itemTypeId = [[obj objectForKey:@"item_type_id"] integerValue];
                        item.minItemId = [obj objectForKey:@"min_item_id"];
                        item.maxItemId = [obj objectForKey:@"max_item_id"];
                        [parsArray addObject:item];
                    }
                }
                handler(NetworkResultSuccess, rtn, title, statusArray, parsArray,progressArray, count);
            } else {
                handler(NetworkResultSuccess, rtn, nil, nil, nil, nil, 0);
            }
        } else {
            handler(NetworkResultSuccess, nil, nil, nil, nil, nil,0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil, nil, nil, nil,0);
    }];
}

//获取流程详情
- (void)getSmallWorkFlowDetailById:(NSInteger)workId isFinish:(NSString *)flag completeHandler:(void (^)(NetworkResult, NSString *, NSDictionary *, NSArray *))handler
{
    NSDictionary *dictionary = @{@"cmd":@"viewWf",
                                 @"process_id":[NSString stringWithFormat:@"%ld",workId],
                                 @"is_finish":flag};
    [self postPath:ACTIONDO parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSDictionary *formInfo = [[jsonData objectForKey:@"formInfos"] firstObject];
                NSArray *record = [jsonData objectForKey:@"attitudeRecord"];
                NSMutableArray *recordArray = [NSMutableArray array];
                for (NSDictionary *obj in record) {
                    XWHWorkFlowRecord *temp = [[XWHWorkFlowRecord alloc] initWithDictionary:obj];
                    [recordArray addObject:temp];
                }
                handler(NetworkResultSuccess, rtn, formInfo, recordArray);
            } else {
              handler(NetworkResultSuccess, rtn, nil,nil);
            }
        } else {
            handler(NetworkResultSuccess, nil, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil, nil);
    }];
}

- (void)getSmallWorkFlowDetailById:(NSInteger)workId isFinish:(NSString *)flag activityId:(NSInteger)activityId completeHandler:(void (^)(NetworkResult, NSString *, NSDictionary *, NSArray *, NSDictionary *, NSArray *))handler
{
    NSDictionary *dic = @{@"cmd":@"preExecute",
                                 @"processId":[NSString stringWithFormat:@"%ld",workId],
                                 @"activityId":[NSString stringWithFormat:@"%ld",activityId],
                                 @"is_finish":flag};
    [self postPath:ACTIONDO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSDictionary *formInfo = [[jsonData objectForKey:@"formInfos"] firstObject];
                NSArray *record = [jsonData objectForKey:@"attitudeRecord"];
                NSMutableArray *recordArray = [NSMutableArray array];
                for (NSDictionary *obj in record) {
                    XWHWorkFlowRecord *temp = [[XWHWorkFlowRecord alloc] initWithDictionary:obj];
                    [recordArray addObject:temp];
                }
                NSMutableArray *agreeItemAry = [NSMutableArray array];
                for (NSDictionary *obj in [jsonData objectForKey:@"AgreeItem"]) {
                    XWHProcessDetailAgreeItem *item = [[XWHProcessDetailAgreeItem alloc] initWithDictionary:obj];
                    [agreeItemAry addObject:item];
                }
                NSMutableDictionary *diction = [[NSMutableDictionary alloc] init];
                [diction setObject:[jsonData objectForKey:@"activityId"] forKey:@"activityId"];
                [diction setObject:[jsonData objectForKey:@"ownsId"] forKey:@"ownsId"];
                [diction setObject:[jsonData objectForKey:@"procdef_id"] forKey:@"procdef_id"];
                [diction setObject:[jsonData objectForKey:@"processId"] forKey:@"processId"];
                
                handler(NetworkResultSuccess, rtn, formInfo, recordArray, diction, agreeItemAry);
            } else {
                handler(NetworkResultSuccess, rtn, nil, nil, nil, nil);
            }
        } else {
            handler(NetworkResultSuccess, nil, nil, nil, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil, nil,nil, nil);
    }];
}

- (void)postExecuteWorkFlow:(NSDictionary *)diction completer:(void (^)(NetworkResult, NSString *))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"phone" forKey:@"tag"];
    [dic setValue:@"postExecute" forKey:@"cmd"];
    [dic addEntriesFromDictionary:diction];
    
    [self postPath:@"waitDealAction.do" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            handler (NetworkResultSuccess, rtn);
        } else {
            handler(NetworkResultSuccess, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil);
    }];
}

- (void)getAllWaiteWorkFlowHandler:(void (^)(NetworkResult, NSString *, NSArray *))handler
{
    NSDictionary *diction = @{@"cmd":@"waitWf"};
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSArray *daiBanListArray = [jsonData objectForKey:@"waitwfs"];
                for (NSDictionary *obj in daiBanListArray) {
                    XWHDaiBanBigModel *model = [[XWHDaiBanBigModel alloc] initWithDictionary:obj];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, rtn, result);
        } else {
            handler(NetworkResultSuccess, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil);
    }];

}

- (void)getSMallWaiteFlowById:(NSInteger)workId page:(NSInteger)page completeHandler:(void (^)(NetworkResult, NSString *, NSArray *, NSInteger))handler
{
    NSDictionary *diction = @{@"cmd":@"userWD",
                              @"tag":@"phone",
                              @"flag":@"1",
                              @"procdef_id":[NSString stringWithFormat:@"%d", workId],
                              @"page":[NSString stringWithFormat:@"%d", page]};
    [self postPath:@"waitDealAction.do" parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *result = [NSMutableArray array];
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            NSInteger totalCount = 0;
            if ([rtn isEqualToString:@"SUCCESS"]) {
                totalCount = [[jsonData objectForKey:@"totalCount"] integerValue];
                NSArray *daiBanListArray = [jsonData objectForKey:@"Processes"];
                for (NSDictionary *obj in daiBanListArray) {
                    XWHSmallScheduleModel *model = [[XWHSmallScheduleModel alloc] initWithDictionary:obj];
                    [result addObject:model];
                }
            }
            handler(NetworkResultSuccess, rtn, result, totalCount);
        } else {
            handler(NetworkResultSuccess, nil, nil, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil, 0);
    }];
}

- (void)getMessageUnReadCount:(void (^)(NetworkResult networkResult, NSInteger))handler
{
    NSDictionary *diction = @{@"cmd":@"noReadMsg"};
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            NSInteger count = 0;
            if ([rtn isEqualToString:@"SUCCESS"]) {
                count = [[jsonData objectForKey:@"cnt"] integerValue];
            }
            handler(NetworkResultSuccess, count);
        } else {
            handler(NetworkResultSuccess, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], 0);
    }];
}

- (void)getLastUnReadMessage:(void (^)(NetworkResult, NSString *, id))handler
{
    NSDictionary *diction = @{@"cmd":@"noReadMsgNotice"};
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                XWHMessageDetailModel *model = [[XWHMessageDetailModel alloc] initWithDiction:jsonData];
                handler(NetworkResultSuccess, rtn, model);
            } else {
                handler(NetworkResultSuccess, rtn, nil);
            }
        } else {
            handler(NetworkResultSuccess, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil);
    }];
}

- (void)upLoadFile:(NSString *)fileName complete:(void (^)(NetworkResult, NSString *, NSInteger))handler
{
    NSString *filePath = [[[XWHAppConfiguration sharedConfiguration] getAttachmentDirectory] stringByAppendingPathComponent:fileName];
    
    NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"webToPhoneAndPad.do?cmd=updateFile" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:@"htm/doc/docx/xls/xlsx"];
    }];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *rtn = [jsonData objectForKey:@"rtnMsg"];
            if ([rtn isEqualToString:@"SUCCESS"]) {
                NSInteger file_id = [[jsonData objectForKey:@"file_id"] integerValue];
                handler(NetworkResultSuccess, rtn, file_id);
            } else {
                handler(NetworkResultSuccess, rtn, -1);
            }
        } else {
            handler(NetworkResultSuccess, nil, -1);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NetworkResultFailedUnknown, nil, -1);
    }];
    [self.httpClient.operationQueue addOperation:op];
}

- (void)updatePeopleDataComplete:(void (^)(NetworkResult, NSString *, NSString *))handler
{
    
    NSString *updateTime = [XWHAppConfiguration sharedConfiguration].peopleUpdateTime;
    NSDictionary *diction = @{@"cmd":@"updateDate",
                              @"updateTime":updateTime==nil?@"0":updateTime};
    [self postPath:ACTIONDO parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = [self dataformatsWithData:responseObject];
        if (jsonData != nil && [jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *sql = [jsonData objectForKey:@"updateSql"];
            NSString *date = [jsonData objectForKey:@"updateTime"];
            handler(NetworkResultSuccess, sql, date);
        } else {
            handler(NetworkResultSuccess, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler([self errorcode:error.code], nil, nil);
    }];
}

#pragma mark -

- (id)dataformatsWithData:(NSData *)data
{
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *strReceive = [[NSString alloc] initWithData:data encoding:strEncode];
    NSString *temp = [strReceive stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    id jsonData = [NSJSONSerialization JSONObjectWithData:[temp dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return jsonData;
}

- (id)dataFormatsCustom:(NSData *)data
{
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *strReceive = [[NSString alloc] initWithData:data encoding:strEncode];
    NSString *temp = [strReceive stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    NSString *formStr = @"\"formInfos\":[{";
    NSString *endFormStr = @"}],\"attitudeRecord";
    NSRange formRange = [temp rangeOfString:formStr];
    NSRange formEndRange = [temp rangeOfString:endFormStr];
    
    
    NSString *dataStr = [temp substringFromIndex:(formRange.location+formRange.length)];
    
    NSRange endFormRange = [dataStr rangeOfString:endFormStr];
    
    NSString *temp1 = [[NSMutableString alloc] initWithFormat:@"%@", [dataStr substringToIndex:endFormRange.location]];
    
    NSString *temp2 = [[temp1 componentsSeparatedByString:@"\",\""] componentsJoinedByString:@"\"}],[{\""];
    
    NSString *temp3 = [NSString stringWithFormat:@"[{%@}]", temp2];
    
    NSString *temp4 = [temp stringByReplacingCharactersInRange:NSMakeRange(formRange.location+formRange.length-1, formEndRange.location-formRange.location-formRange.length+2) withString:temp3];
    
    id jsonData = [NSJSONSerialization JSONObjectWithData:[temp4 dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return jsonData;
}

- (NSString *)chineseFormats:(NSString *)str
{
    return str;
    
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *retStr =[str stringByAddingPercentEscapesUsingEncoding:enc];
//    return retStr;
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:path parameters:parameters];
    [request setTimeoutInterval:120.0f];
	AFHTTPRequestOperation *operation = [self.httpClient HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

- (NetworkResult)errorcode:(NSInteger)code
{
    switch (code) {
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorNotConnectedToInternet:
            return NetworkResultFailedNoConnection;
            break;
        case NSURLErrorTimedOut:
            return NetworkResultFailedTimeout;
        default:
            return NetworkResultFailedUnknown;
    }
}

@end
