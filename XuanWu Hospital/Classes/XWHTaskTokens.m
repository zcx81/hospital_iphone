//
//  XWHTaskTokens.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/28.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHTaskTokens.h"

//{
//    "status": "A",
//    "name": "test75",
//    "color": "orange",
//    "dosId": "4274",
//    "cnt": "1"
//}

@implementation XWHTaskTokens

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.status = [dic objectForKey:@"status"];
        self.name = [dic objectForKey:@"name"];
        self.color = [dic objectForKey:@"color"];
        self.dosId = [[dic objectForKey:@"dosId"] integerValue];
        self.cnt = [[dic objectForKey:@"cnt"] integerValue];
    }
    return self;
}

@end
