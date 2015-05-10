//
//  XWHWorkFlowRecord.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/16.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHWorkFlowRecord : NSObject
/*!
 @brief 任务名称
 */
@property (copy, nonatomic) NSString *taskName;
/*!
 @brief 操作人
 */
@property (copy, nonatomic) NSString *ownerName;
/*!
 @brief 操作时间
 */
@property (copy, nonatomic) NSString *executeTime;
/*!
 @brief 批示
 */
@property (copy, nonatomic) NSString *agreeNameRecord;
/*!
 @brief 签章值
 */
@property (copy, nonatomic) NSString *ownerKeyPic;
/*!
 @brief 批示意见
 */
@property (copy, nonatomic) NSString *attTextRecord;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
