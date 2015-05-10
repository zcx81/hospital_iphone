//
//  XWHProcessDetailAgreeItem.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/21.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHProcessDetailAgreeItem.h"

@implementation XWHProcessDetailAgreeItem

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.agreeId = [[dic objectForKey:@"agreeId"] integerValue];
        self.agreeItemText = [dic objectForKey:@"agreeItemText"];
    }
    return self;
}

@end
