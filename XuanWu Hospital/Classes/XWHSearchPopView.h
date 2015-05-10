//
//  XWHSearchPopView.h
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/5.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBack)(NSInteger);

@interface XWHSearchPopView : UIView

@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UITextField *startDate;
@property (weak, nonatomic) IBOutlet UITextField *endDate;
@property (weak, nonatomic) IBOutlet UITextField *searchTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *constraintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *criteriaImgView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) CallBack handler;

- (void)show;
- (void)hide;

@end
