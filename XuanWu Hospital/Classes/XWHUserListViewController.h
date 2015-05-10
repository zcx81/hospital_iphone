//
//  XWHUserListViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/11.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHViewController.h"

typedef NS_ENUM(NSInteger, SelectedType)
{
    multipleSelected,
    singleSelected,
};

@interface XWHUserListViewController : XWHViewController

@property (assign, nonatomic) NSInteger officeId;
@property (assign, nonatomic) SelectedType selectedType;

@end
