//
//  XWHTaskTokens.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/28.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    "status": "A",
//    "name": "test75",
//    "color": "orange",
//    "dosId": "4274",
//    "cnt": "1"
//}

@interface XWHTaskTokens : NSObject

@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *color;
@property (assign, nonatomic) NSInteger dosId;
@property (assign, nonatomic) NSInteger cnt;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
