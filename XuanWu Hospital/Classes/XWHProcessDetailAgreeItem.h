//
//  XWHProcessDetailAgreeItem.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/21.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHProcessDetailAgreeItem : NSObject

@property (assign, nonatomic) NSInteger agreeId;
@property (copy, nonatomic) NSString *agreeItemText;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
