//
//  XWHPiShiView.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/20.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPlaceholderTextView.h"

typedef void(^CallBack)(NSInteger);

@interface XWHPiShiView : UIView

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *disAgreeBtn;
@property (weak, nonatomic) IBOutlet LPlaceholderTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *disagreeLabel;

@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *dateView;


@property (strong, nonatomic) CallBack callBack;

@end
