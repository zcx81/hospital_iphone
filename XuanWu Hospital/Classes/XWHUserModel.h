//
//  XWHUserModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/14.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
//{
//    "USER_ID": "171",
//    "USER_NAME": "张建",
//    "TOTALTITLE": "宣武医院/院领导",
//    "SPACE": "3072"
//}

@interface XWHUserModel : NSObject

@property (assign, nonatomic) NSInteger userId;
@property (assign, nonatomic) NSInteger space;
@property (assign, nonatomic) NSInteger listOrder;
@property (assign, nonatomic) NSInteger officeId;

@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *totalTitle;

- (id)initDataWithDiction:(NSDictionary *)diction;

@end
