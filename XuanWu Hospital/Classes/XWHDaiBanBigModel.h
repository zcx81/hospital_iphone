//
//  XWHDaiBanBigModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/2.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHDaiBanBigModel : NSObject

@property (copy, nonatomic) NSString *procdefName;
@property (assign, nonatomic) NSInteger procdefId;
@property (assign, nonatomic) NSInteger cnt;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
