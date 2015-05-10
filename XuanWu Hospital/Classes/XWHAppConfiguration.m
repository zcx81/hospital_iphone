//
//  XWHAppConfiguration.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/3.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHAppConfiguration.h"

#define USERID @"userID"
#define USERNAME @"userName"
#define HANDLERID @"handlerId"
#define DOWNLOADID @"downLoadId"
#define ATTACHMENT_FILE_DIRECTORY @"Attachment"
#define DBNAME @"XWHDB"
#define LOGINNAME @"loginName"
#define LOGINPASSWORD @"loginPassword"
#define UPDATEPEOPLETIME @"updatePeopleTime"
#define OLDVERSIONINFRO @"oldVersionInfro"

@implementation XWHAppConfiguration

+ (instancetype)sharedConfiguration
{
    static XWHAppConfiguration *sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfig = [[XWHAppConfiguration alloc] init];
    });
    return sharedConfig;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self addAttachmentDirectory];
        [self moveData];
    }
    return self;
}

- (void)setUserID:(NSString *)userID
{
    if (![self.userID isEqualToString:userID]) {
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USERID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)userID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
}

- (void)setUserName:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
}

- (void)setHandlerId:(NSString *)handlerId
{
    if (![self.handlerId isEqualToString:handlerId]) {
        [[NSUserDefaults standardUserDefaults] setObject:handlerId forKey:HANDLERID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)handlerId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:HANDLERID];
}

- (void)setLoginName:(NSString *)loginName
{
    if (![self.loginName isEqualToString:loginName]) {
        [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:LOGINNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)loginName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LOGINNAME];
}

- (void)setLoginPassword:(NSString *)loginPassword
{
    if (![self.loginPassword isEqualToString:loginPassword]) {
        [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:LOGINPASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)loginPassword
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LOGINPASSWORD];
}

- (void)setPeopleUpdateTime:(NSString *)peopleUpdateTime
{
    if (![self.peopleUpdateTime isEqualToString:peopleUpdateTime]) {
        [[NSUserDefaults standardUserDefaults] setObject:peopleUpdateTime forKey:UPDATEPEOPLETIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)peopleUpdateTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:UPDATEPEOPLETIME];
}

- (NSString *)oldVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:OLDVERSIONINFRO];
}

- (void)setOldVersion:(NSString *)oldVersion
{
    if (![self.oldVersion isEqualToString:oldVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:oldVersion forKey:OLDVERSIONINFRO];
    }
}

- (NSString *)versionInfo
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

- (void)addDownLoadAttachmentId:(NSInteger)attId
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([self getDownLoadAttachmentId].count != 0) {
        [array addObjectsFromArray:[self getDownLoadAttachmentId]];
    }
    [array insertObject:[NSNumber numberWithInteger:attId] atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:DOWNLOADID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)getDownLoadAttachmentId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOADID];
}

- (BOOL)isDownLoadWithId:(NSInteger)attId
{
    for (NSNumber *n in [self getDownLoadAttachmentId]) {
        if (n.integerValue == attId) {
            return YES;
        }
    }
    return NO;
}

- (void)addAttachmentDirectory
{
    NSString *path = [self getAttachmentDirectory];
    NSError *error = nil;
    BOOL re = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (re == NO) {
//        LOG(@"创建目录失败,%@",error);
    }
//    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error
}

- (NSString *)getAttachmentDirectory
{
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[docs firstObject] stringByAppendingPathComponent:ATTACHMENT_FILE_DIRECTORY];
    NSString *path = [docs firstObject];
    return path;
}

- (void)moveData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:DBNAME ofType:@"db"];
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *newPath = [[docs firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",DBNAME]];
    
    if (![self.versionInfo isEqualToString:self.oldVersion]) {
        self.oldVersion = self.versionInfo;
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
            NSLog(@"旧数据库删除成功！");
        }
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:newPath error:&error];
        if (error == nil) {
            NSLog(@"数据库拷贝成功！");
        }
    }
}

- (void)clearData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HANDLERID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
