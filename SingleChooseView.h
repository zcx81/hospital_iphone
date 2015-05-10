//
//  SingleChooseView.h
//  XuanWu Hospital
//
//  Created by apple on 15/5/9.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleChooseDelegate <NSObject>

-(void)chooseItem:(NSString*)key;

@end

@interface SingleChooseView : UIView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSArray *infoArray;
@property(nonatomic,weak) id<SingleChooseDelegate> delegate;

@end
