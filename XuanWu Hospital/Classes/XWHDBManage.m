//
//  XWHDBManage.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/6.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHDBManage.h"
#import "FMDatabase.h"
#import "XWHBulletinTypeModel.h"
#import "XWHOfficeModel.h"
#import "XWHUserModel.h"
#import "XWHAppConfiguration.h"

static NSString *const dataBaseName = @"XWHDB.db";
static NSString *const typeTableName = @"BulletinType";

@interface XWHDBManage ()

@property (strong, nonatomic) FMDatabase *dataBase;

@end

@implementation XWHDBManage

+ (instancetype)sharedInstance
{
    static id shardInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shardInstance = [[self alloc] init];
    });
    return shardInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.dataBase = [FMDatabase databaseWithPath:[self databasePath:dataBaseName]];
//        [self createTable];
    }
    return self;
}

- (NSString *)databasePath:(NSString *)dbName
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path firstObject];
    NSString *fileDocumentPath = [documentDirectory stringByAppendingPathComponent:dbName];
    return fileDocumentPath;
}

- (void)createTable
{
    if ([self.dataBase open]) {
        NSString *createKindTable = @"CREATE TABLE IF NOT EXISTS BulletinType (TYPE_ID INTEGER PRIMARY KEY NOT NULL, TYPE_NAME TEXT, CREATE_TIME TEXT, UPDATE_TIME TEXT, STATE TEXT, ORDERID INTEGER)";
        BOOL res = [self.dataBase executeUpdate:createKindTable];
        if (res) {
            NSLog(@"BulletinType 创建成功");
        } else {
            NSLog(@"BulletinType 创建失败");
        }
        [self.dataBase close];
    } else {
        NSLog(@"数据库打开失败！");
    }
}

- (void)insertBulletinType:(NSArray *)array
{
    if (array.count == 0) {
        return;
    }
    if ([self.dataBase open]) {
        [self.dataBase executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@",typeTableName]];
        [self.dataBase beginTransaction];
        for (XWHBulletinTypeModel *model in array) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (TYPE_ID, TYPE_NAME, CREATE_TIME, UPDATE_TIME, STATE, ORDERID) VALUES (%ld, '%@', '%@', '%@', '%@', '%ld')", typeTableName, model.typeId, model.typeName, model.createTime, model.updateTime, model.state, model.orderId];
            if (![self.dataBase executeUpdate:sql]) {
                NSLog(@"插入失败！！%@",model.typeName);
            }
        }
        [self.dataBase commit];
        [self.dataBase close];
    }
}

- (NSArray *)getAllBulletinType
{
    NSMutableArray *array = [NSMutableArray array];
    if ([self.dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ORDERID ASC", typeTableName];
        FMResultSet *rs = [self.dataBase executeQuery:sql];
        while ([rs next]) {
            NSInteger typeId = [rs intForColumn:@"TYPE_ID"];
            NSString *typeName = [rs stringForColumn:@"TYPE_NAME"];
            NSString *createTime = [rs stringForColumn:@"CREATE_TIME"];
            NSString *updateTime = [rs stringForColumn:@"UPDATE_TIME"];
            NSString *state = [rs stringForColumn:@"STATE"];
            NSInteger orderId = [rs intForColumn:@"ORDERID"];
            XWHBulletinTypeModel *model = [[XWHBulletinTypeModel alloc] init];
            model.typeId = typeId;
            model.typeName = typeName;
            model.createTime = createTime;
            model.updateTime = updateTime;
            model.state = state;
            model.orderId = orderId;
            [array addObject:model];
        }
        [self.dataBase close];
    }
    
    return array;
}

- (NSString *)getTypeNameById:(NSInteger)typeId
{
    NSString *name = nil;
    if ([self.dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT TYPE_NAME FROM %@ WHERE TYPE_ID = %ld", typeTableName, typeId];
        FMResultSet *rs = [self.dataBase executeQuery:sql];
        while ([rs next]) {
            name = [rs stringForColumn:@"TYPE_NAME"];
        }
        [self.dataBase close];
    }
    return name;
}

- (NSArray *)getAllOffice
{
    NSMutableArray *array = [NSMutableArray array];
    if ([self.dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE OFFICE_STATE = 'A' ORDER BY LIST_ORDER ASC", @"TBL_OFFICE"];
        FMResultSet *rs = [self.dataBase executeQuery:sql];
        while ([rs next]) {
            NSInteger officeId = [rs intForColumn:@"OFFICE_ID"];
            NSString *typeName = [rs stringForColumn:@"OFFICE_TYPE"];
            NSString *officeName = [rs stringForColumn:@"OFFICE_NAME"];
            XWHOfficeModel *model = [[XWHOfficeModel alloc] init];
            model.officeId = officeId;
            model.officeName = officeName;
            model.officeType = typeName;
            [array addObject:model];
        }
        [self.dataBase close];
    }
    return array;
}

- (NSArray *)getUserByOfficeId:(NSInteger)officeId
{
    NSMutableArray *array = [NSMutableArray array];
    if ([self.dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from (select 0 seq,(select totaltitle from tbl_office  where office_id=a.DIRECT_OFFICE_ID and office_state!='D') totaltitle,a.*,b.list_order listorder from tbl_user a, tbl_user_office b where a.user_state!='D' and a.user_id=b.user_id  and b.office_id=%ld and a.direct_office_id=%ld union all select 1 seq,(select totaltitle from tbl_office  where office_id=a.DIRECT_OFFICE_ID and office_state!='D') totaltitle,a.*,b.list_order listorder from tbl_user a, tbl_user_office b where a.user_state!='D' and a.user_id=b.user_id  and b.office_id=%ld and a.direct_office_id!=%ld ) a  order by listorder asc ,user_name asc ",officeId,officeId,officeId,officeId];
        FMResultSet *rs = [self.dataBase executeQuery:sql];
        while ([rs next]) {
            NSInteger userId = [rs intForColumn:@"USER_ID"];
            NSString *userName = [rs stringForColumn:@"USER_NAME"];
            NSInteger listOrder = [rs intForColumn:@"list_order"];
            NSInteger officeId = [rs intForColumn:@"direct_office_id"];
            XWHUserModel *model = [[XWHUserModel alloc] init];
            model.userId = userId;
            model.userName = userName;
            model.listOrder = listOrder;
            model.officeId = officeId;
            [array addObject:model];
        }
        [self.dataBase close];
    }
//    NSArray *sortArray = nil;
//    if (array.count != 0) {
//        sortArray = [[[array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            XWHUserModel *model1 = obj1;
//            XWHUserModel *model2 = obj2;
//            return [model1.userName localizedCompare:model2.userName];
//        }] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            XWHUserModel *model1 = obj1;
//            XWHUserModel *model2 = obj2;
//            return model1.listOrder > model2.listOrder;
//        }] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            XWHUserModel *model1 = obj1;
//            XWHUserModel *model2 = obj2;
//            return model1.officeId > model2.officeId;
//        }];
//    }
//    return sortArray;
    return array;
}

- (void)updateDataWithSql:(NSString *)sql andDate:(NSString *)date
{
    if (sql != nil && sql.length != 0) {
        if ([self.dataBase open]) {
            [self.dataBase beginTransaction];
            NSArray *sqlArray = [sql componentsSeparatedByString:@";"];
            for (NSString *temp in sqlArray) {
                if ((temp != nil && temp.length != 0) &&![self.dataBase executeUpdate:temp]) {
                    NSLog(@"更新失败！");
                }
            }
            [self.dataBase commit];
            [XWHAppConfiguration sharedConfiguration].peopleUpdateTime = date;
            [self.dataBase close];
        }        
    }
}

@end
