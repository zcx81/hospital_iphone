//
//  XWHProcessSearchItems.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/20.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHProcessSearchItems : NSObject

@property (assign, nonatomic) NSInteger itemTypeId;
@property (strong, nonatomic) NSArray *parsArray;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *minItemId;
@property (strong, nonatomic) NSString *maxItemId;

@end
