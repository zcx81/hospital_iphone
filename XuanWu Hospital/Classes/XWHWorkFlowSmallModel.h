//
//  XWHWorkFlowSmallModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/11.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHWorkFlowSmallModel : NSObject

@property (assign, nonatomic) NSInteger processId;
@property (assign, nonatomic) BOOL isFinish;
@property (strong, nonatomic) NSArray *valuesArray;
//流程状态
@property (copy, nonatomic) NSString *processStatus;
//当前处理人
@property (copy, nonatomic) NSString *currentPeople;

@property (strong, nonatomic) NSArray *taskTokens;

@property (assign, nonatomic) NSInteger activityId;

@property (assign, nonatomic) BOOL isCanBanli;

@end
