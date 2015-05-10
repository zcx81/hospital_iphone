//
//  RefreshBaseView.h
//  
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ONEPAGENUMBER 10
#define ITCRefreshViewHeight 64.0
#define ITCRefreshAnimationDuration 0.25
#define ITCRefreshContentOffset @"contentOffset"
#define ITCRefreshContentSize @"contentSize"
#define ITCRefreshLabelTextColor [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]

typedef NS_ENUM(NSInteger, RefreshState) {
	RefreshStatePulling = 1,
	RefreshStateNormal = 2,
	RefreshStateRefreshing = 3,
    RefreshStateWillRefreshing = 4
};

typedef NS_ENUM(NSInteger, RefreshViewType) {
    RefreshViewTypeHeader = -1,
    RefreshViewTypeFooter = 1
};

@class RefreshBaseView;

typedef void (^BeginRefreshingBlock)(RefreshBaseView *refreshView);
typedef void (^EndRefreshingBlock)(RefreshBaseView *refreshView);
typedef void (^RefreshStateChangeBlock)(RefreshBaseView *refreshView, RefreshState state);

@interface RefreshBaseView : UIView

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;

@property (nonatomic, copy) BeginRefreshingBlock beginRefreshingBlock;
@property (nonatomic, copy) RefreshStateChangeBlock refreshStateChangeBlock;
@property (nonatomic, copy) EndRefreshingBlock endStateChangeBlock;

@property (nonatomic, assign) UIEdgeInsets scrollViewInitInset;
@property (nonatomic, assign) RefreshState state;

@property (assign, nonatomic) NSInteger currentNumber;
@property (assign, nonatomic) NSInteger totalCount;
@property (weak, nonatomic) UIActivityIndicatorView *activityView;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)free;

- (void)setState:(RefreshState)state;
- (int)totalDataCountInScrollView;

- (instancetype)initWithFrame:(CGRect)frame totalCount:(NSInteger)total;
@end