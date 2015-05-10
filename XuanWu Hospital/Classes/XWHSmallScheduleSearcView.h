//
//  XWHSmallScheduleSearcView.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/19.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBack)(NSInteger);

@interface XWHSmallScheduleSearcView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *criteriaImgView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) CallBack handler;

- (void)show;
- (void)hide;

@end
