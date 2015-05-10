//
//  XWHAppUpdateModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/10/11.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHAppUpdateModel : NSObject

@property (copy, nonatomic) NSString *verName;
@property (copy, nonatomic) NSString *descriptions;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *updateTime;
@property (copy, nonatomic) NSString *environment;

@property (assign, nonatomic) double size;

@end
