//
//  XWHMessageSendingViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/15.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHViewController.h"
#import "XWHMessageDetailModel.h"
#import "XWHBulletinDetailModel.h"

typedef NS_ENUM(NSInteger, MESSAGEDETAILTYPE)
{
    SEND_MESSAGE = 0,
    RE_MESSAGE,
    FW_MESSAGE,
    FW_GONGGAO,
    FW_GONGSHI,
};

@interface XWHMessageSendingViewController : XWHViewController

@property (assign, nonatomic) MESSAGEDETAILTYPE detailType;
@property (strong, nonatomic) XWHBulletinDetailModel *bulletionModel;
@property (strong, nonatomic) XWHMessageDetailModel *model;

@end
