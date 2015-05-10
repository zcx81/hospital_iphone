//
//  XWHCustomTabBarViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/9.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TabBarSelectedKind)
{
    SelectedMainPage = 0,
    SelectedMessageList,
    SelectedWorkFlow,
    SelectedBulletinList,
    SelectedLogout,
};

@interface XWHCustomTabBarViewController : UITabBarController

@property (assign, nonatomic) TabBarSelectedKind selectedKind;
@property (assign, nonatomic) TabBarSelectedKind oldSelectedKind;

@end
