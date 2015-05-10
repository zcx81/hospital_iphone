//
//  XWHSmallScheduleModel.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/10.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import <Foundation/Foundation.h>
//{
//    "process_id": "8808",
//    "proc_label": "123",
//    "procdef_name": "实验室加班申请",
//    "user_name": "test3",
//    "create_time": "2014/12/23 10:56:40",
//    "task_name": "备案",
//    "activityId": "8",
//    "is_finish": "S",
//    "Taskusers": [
//                  {
//                      "color": "red",
//                      "user_name": "9060110"
//                  },
//                  {
//                      "color": "red",
//                      "user_name": "0840187"
//                  },
//                  {
//                      "color": "orange",
//                      "user_name": "系统管理员"
//                  }
//                  ]
//}

@interface XWHSmallScheduleModel : NSObject

@property (assign, nonatomic) NSInteger process_id;
@property (copy, nonatomic) NSString *proc_label;
@property (copy, nonatomic) NSString *procdef_name;
@property (copy, nonatomic) NSString *user_name;
@property (copy, nonatomic) NSString *create_time;
@property (copy, nonatomic) NSString *task_name;
@property (copy, nonatomic) NSString *taskUsers;
@property (assign, nonatomic) NSInteger activityId;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
