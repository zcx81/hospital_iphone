//
//  XWHProcessStatus.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/19.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHProcessStatus : NSObject

@property (assign, nonatomic) NSInteger activityId;
@property (strong, nonatomic) NSString *activityName;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
