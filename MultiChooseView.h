//
//  MultiChooseView.h
//  XuanWu Hospital
//
//  Created by apple on 15/5/9.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultiChooseDelegate <NSObject>

-(void)chooseItem:(NSDictionary*)dic;

@end

@interface MultiChooseView : UIView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSArray *infoArray;
@property(nonatomic,weak) id<MultiChooseDelegate> delegate;

@end
