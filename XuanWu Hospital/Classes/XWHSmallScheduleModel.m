//
//  XWHSmallScheduleModel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/10.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSmallScheduleModel.h"

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

@implementation XWHSmallScheduleModel

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self != nil) {
        self.process_id = [[dic objectForKey:@"process_id"] integerValue];
        self.proc_label = [dic objectForKey:@"proc_label"];
        self.procdef_name = [dic objectForKey:@"procdef_name"];
        self.user_name = [dic objectForKey:@"user_name"];
        self.create_time = [dic objectForKey:@"create_time"];
        self.task_name = [dic objectForKey:@"task_name"];
        self.activityId = [[dic objectForKey:@"activityId"] integerValue];
        NSArray *temp = [dic objectForKey:@"Taskusers"];
        NSMutableString *users = [[NSMutableString alloc] init];
        for (NSDictionary *dic in temp) {
            [users appendString:[NSString stringWithFormat:@"%@, ", [dic objectForKey:@"user_name"]]];
        }
        self.taskUsers = users;
    }
    return self;
}

@end
