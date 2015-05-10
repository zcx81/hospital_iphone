//
//  XWHDBManage.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWHDBManage : NSObject

+ (instancetype)sharedInstance;
- (void)insertBulletinType:(NSArray *)array;
- (NSArray *)getAllBulletinType;
- (NSString *)getTypeNameById:(NSInteger)typeId;
- (NSArray *)getAllOffice;
- (NSArray *)getUserByOfficeId:(NSInteger)officeId;

- (void)updateDataWithSql:(NSString *)sql andDate:(NSString *)date;

@end
