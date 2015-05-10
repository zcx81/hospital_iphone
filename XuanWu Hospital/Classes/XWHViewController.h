//
//  XWHViewController.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/30.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWHNetWorkResult.h"
#import "XWHHttpClient.h"
#import "XWHAppConfiguration.h"

#define RED_COLOR [UIColor colorWithRed:221/255.0 green:65/255.0 blue:53/255.0 alpha:1.0f]
#define FONTCOLOR [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1.0f]
#define GRAY_BACKGROUND_COLOR [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0f]
#define LINECOLOR [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1.0f]

@interface XWHViewController : UIViewController

/*!
 @brief 背景有文字
 */
- (void)setNavBgStyle1;
/*!
 @brief 纯红色背景
 */
- (void)setNavBgStyle2;

- (void)setNavTitle:(NSString *)title;
- (void)setNavBackBtn;
- (void)backButtonAction:(id)sender;

- (void)progressHUDShowWithTitle:(NSString *)title;
- (void)progressHUDCompleteHide:(BOOL)animated afterDelay:(NSTimeInterval)delay title:(NSString *)title;
- (void)progressHUDHide:(BOOL)animated;
- (void)progressHUDShowwithProgressTitle:(NSString *)title;
- (void)setProgressHUDPercent:(CGFloat)percent;
- (void)progressHUDSHowTitle:(NSString *)title afterDelay:(NSTimeInterval)delay;

- (void)showNetWorkError:(NetworkResult)result;

- (void)setBtnImage:(UIButton *)btn;

@end
