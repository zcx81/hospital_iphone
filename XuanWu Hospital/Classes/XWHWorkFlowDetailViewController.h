//
//  XWHWorkFlowDetailViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/12.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHViewController.h"
#import "XWHWorkFlowSmallModel.h"
#import "XWHWorkFlowBigModel.h"

@interface XWHWorkFlowDetailViewController : XWHViewController

@property (strong, nonatomic) XWHWorkFlowBigModel *bigModel;
@property (strong, nonatomic) XWHWorkFlowSmallModel *smallModel;

@end
