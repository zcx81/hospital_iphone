//
//  XWHAttachmentViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/28.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHViewController.h"

typedef void(^FilesHandler)(NSArray *filesArray);

@interface XWHAttachmentViewController : XWHViewController

@property (strong, nonatomic) FilesHandler handler;

@end
