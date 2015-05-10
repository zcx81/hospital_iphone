//
//  AppDelegate.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/30.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "AppDelegate.h"
#import "XWHDBManage.h"
#import "XWHHttpClient.h"
#import "XWHAppConfiguration.h"
#import "XWHMessageDetailModel.h"
#import "XWHMessageDetailViewController.h"

#define UpdateTime 5  //分钟

@interface AppDelegate ()  <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *appUpdateUrl;
@property (strong, nonatomic) NSMutableArray *unReadMessageIdArray;
@property (assign, nonatomic) BOOL currentStatus;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    int cacheSizeMemory = 1*1024*1024; // 4MB
    int cacheSizeDisk = 100*1024*1024; // 100MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:cacheSizeMemory];
    [[NSURLCache sharedURLCache] setDiskCapacity:cacheSizeDisk];
    //进行一些初始化工作
    [XWHAppConfiguration sharedConfiguration];
    //检查是否有新版本更新
    [[XWHHttpClient sharedInstance] checkUpdateStateHandler:^(NetworkResult networkResult, BOOL update, XWHAppUpdateModel *verModel) {
        if (networkResult == NetworkResultSuccess) {
            if (update && verModel != nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:verModel.verName message:verModel.descriptions delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 100;
                [alertView show];
                self.appUpdateUrl = verModel.url;
            }
        }
    }];
//    //更新人员信息
//    [[XWHHttpClient sharedInstance] updatePeopleDataComplete:^(NetworkResult networkResult, NSString *updateSql, NSString *dateTime) {
//        if (![[XWHAppConfiguration sharedConfiguration].peopleUpdateTime isEqualToString:dateTime]) {
//            [[XWHDBManage sharedInstance] updateDataWithSql:updateSql andDate:dateTime];
//        }
//    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    application.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self setTheUpdateTimer];
    return YES;
}

#pragma mark - UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:self.appUpdateUrl];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)setTheUpdateTimer
{
    self.unReadMessageIdArray = [NSMutableArray array];
    self.currentStatus = YES;
    [NSTimer scheduledTimerWithTimeInterval:UpdateTime*60 target:self selector:@selector(getTheLastOnReadMessage) userInfo:nil repeats:YES];
}

- (void)getTheLastOnReadMessage
{
    NSLog(@"请求有没有最新消息！");
    [[XWHHttpClient sharedInstance] getLastUnReadMessage:^(NetworkResult networkResult, NSString *rtnMsg, id detail) {
        if (networkResult == NetworkResultSuccess && detail != nil) {
            XWHMessageDetailModel *model = detail;
            if (![self.unReadMessageIdArray containsObject:[NSNumber numberWithInteger:model.messageRemindId]]) {
                [self.unReadMessageIdArray addObject:[NSNumber numberWithInteger:model.messageRemindId]];
                [self addLocalNotification:model];
            } else {
                NSLog(@"最新的消息一样！");
            }
        }
    }];
}

- (void)addLocalNotification:(XWHMessageDetailModel *)model
{
    NSLog(@"添加本地通知！");
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
        return;
    }
    
    localNotif.alertBody = model.subject;
    localNotif.userInfo = @{@"messageId":[NSNumber numberWithInteger:model.messageRemindId]};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    NSLog(@"本地通知添加完成");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"打开本地通知");
    if (notification != nil) {
        if (self.currentStatus == NO) {
            NSInteger messageId = [[notification.userInfo objectForKey:@"messageId"] integerValue];
            NSLog(@"messageId = %d", messageId);
            [self openNotification:messageId];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    }
}

- (void)openNotification:(NSInteger)messageId
{
    self.tabBarViewController.selectedIndex = 0;
    UINavigationController *navVC = (UINavigationController *)[self.tabBarViewController.viewControllers firstObject];
    XWHMessageDetailViewController *detailVC = [[XWHMessageDetailViewController alloc] init];
    detailVC.messageId = messageId;
    detailVC.type = RECEIVE_MESSAGE;
    [navVC pushViewController:detailVC animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.currentStatus = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.currentStatus = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
