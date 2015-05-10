//
//  XWHBulletinModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/4.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHBulletinModel.h"

@implementation XWHBulletinModel

- (id)initWithDataDiction:(NSDictionary *)diction
{
    self = [super init];
    if (self != nil) {
        if ([diction isKindOfClass:[NSDictionary class]]) {
            self.bulletinId = [[diction objectForKey:@"bulletinId"] integerValue];
            self.bulletinUserId = [[diction objectForKey:@"bulletin_userId"] integerValue];
            self.bulletinTypeId = [[diction objectForKey:@"bulletinTypeId"] integerValue];
            if ([[diction objectForKey:@"is_link"] isEqualToString:@"Y"]) {
                self.isLink = YES;
            }
            self.title = [diction objectForKey:@"title"];
            self.bytes = [[diction objectForKey:@"bytes"] integerValue];
            self.updateTime = [diction objectForKey:@"update_time"];
            self.clickCount = [[diction objectForKey:@"clicks"] integerValue];
            self.judgeLevel = [[diction objectForKey:@"judgeLevel"] integerValue];
            self.userName = [diction objectForKey:@"user_name"];
            self.linkContent = [diction objectForKey:@"link_content"];
        }
    }
    return self;
}

@end
