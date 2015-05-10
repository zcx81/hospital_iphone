//
//  XWHAppConfiguration.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/3.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHAppConfiguration : NSObject

/*!
 @brief 用户id
*/
@property (strong, nonatomic) NSString *userID;

/*!
 @brief 用户权限控制id
*/
@property (strong, nonatomic) NSString *handlerId;

/*!
 @brief 用户名
 */
@property (strong, nonatomic) NSString *userName;

/*!
 @brief 人员数据库更新时间
 */
@property (strong, nonatomic) NSString *peopleUpdateTime;

@property (strong, nonatomic) NSString *loginName;
@property (strong, nonatomic) NSString *loginPassword;
@property (strong, nonatomic) NSString *oldVersion;
@property (strong, nonatomic, readonly) NSString *versionInfo;

+ (instancetype)sharedConfiguration;

- (void)clearData;
- (NSString *)getAttachmentDirectory;
- (void)addDownLoadAttachmentId:(NSInteger)attId;
- (NSArray *)getDownLoadAttachmentId;
- (BOOL)isDownLoadWithId:(NSInteger)attId;

@end
