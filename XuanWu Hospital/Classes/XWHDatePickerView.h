//
//  XWHPublicView.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/25.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackDate)(BOOL hide, NSString *date);

@interface XWHDatePickerView : UIView

@property (copy, nonatomic) CallBackDate callBack;

- (void)initSelectData;

- (void)initSelectDataWithStr:(NSString *)date;

@end
