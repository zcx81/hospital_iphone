//
//  RefreshHeaderView.m
//  
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "RefreshHeaderView.h"

@interface RefreshHeaderView()

@end

@implementation RefreshHeaderView

+ (instancetype)headerWithTotalCount:(NSInteger)total
{
    return [[RefreshHeaderView alloc] initWithFrame:CGRectZero totalCount:total];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat h = frame.size.height;
    if (self.statusLabel.center.y != h * 0.5) {
        CGFloat w = frame.size.width;
        self.statusLabel.center = CGPointMake(w * 0.5, h * 0.5);
    }
}

#pragma mark - UIScrollView相关
#pragma mark 重写设置ScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    [super setScrollView:scrollView];
    self.frame = CGRectMake(0, - ITCRefreshViewHeight, scrollView.frame.size.width, ITCRefreshViewHeight);
}

#pragma mark 设置状态
- (void)setState:(RefreshState)state
{
    if (self.state == state) {
        return;
    }
    [super setState:state];
	switch (state) {
		case RefreshStatePulling:
        {
            self.statusLabel.text = @"松开以便加载上一页";
            [UIView animateWithDuration:ITCRefreshAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.top = self.scrollViewInitInset.top;
                self.scrollView.contentInset = inset;
            }];
			break;
        }
		case RefreshStateNormal:
        {
            self.statusLabel.text = @"下拉以便显示上一页";
            [UIView animateWithDuration:ITCRefreshAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.top = self.scrollViewInitInset.top;
                self.scrollView.contentInset = inset;
            }];
			break;
        }
		case RefreshStateRefreshing:
        {
            self.statusLabel.text = @"正在加载...";
            [UIView animateWithDuration:ITCRefreshAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 1.增加65的滚动区域
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.top = self.scrollViewInitInset.top + ITCRefreshViewHeight;
                self.scrollView.contentInset = inset;
                // 2.设置滚动位置
                self.scrollView.contentOffset = CGPointMake(0, - self.scrollViewInitInset.top - ITCRefreshViewHeight);
            }];
			break;
        }
            
        default:
            break;
	}
}

#pragma mark - 在父类中用得上
// 合理的Y值(刚好看到下拉刷新控件时的contentOffset.y，取相反数)
- (CGFloat)validY
{
    return self.scrollViewInitInset.top;
}

// view的类型
- (RefreshViewType)viewType
{
    return RefreshViewTypeHeader;
}
@end