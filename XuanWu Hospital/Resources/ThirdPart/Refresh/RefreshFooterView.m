//
//  RefreshFooterView.m
//  
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "RefreshFooterView.h"

@interface RefreshFooterView()

@property (assign, nonatomic) NSInteger lastRefreshCount;

@end

@implementation RefreshFooterView

+ (instancetype)footerWithTotalCount:(NSInteger)total
{
    return [[RefreshFooterView alloc] initWithFrame:CGRectZero totalCount:total];
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

#pragma mark set ScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    [self.scrollView removeObserver:self forKeyPath:ITCRefreshContentSize context:nil];
    [scrollView addObserver:self forKeyPath:ITCRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
    [super setScrollView:scrollView];
    [self adjustFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    if ([ITCRefreshContentSize isEqualToString:keyPath]) {
        [self adjustFrame];
    }
}

#pragma mark set frame
- (void)adjustFrame
{
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat scrollHeight = self.scrollView.frame.size.height - self.scrollViewInitInset.top - self.scrollViewInitInset.bottom;
    CGFloat y = MAX(contentHeight, scrollHeight);
    self.frame = CGRectMake(0, y, self.scrollView.frame.size.width, ITCRefreshViewHeight);
}

- (void)setState:(RefreshState)state
{
    if (self.state == state){
        return;
    }
    RefreshState oldState = self.state;
    [super setState:state];
	switch (state)
    {
		case RefreshStatePulling:
        {
            self.statusLabel.text = @"松开以便加载下一页";
            [UIView animateWithDuration:ITCRefreshAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.bottom = self.scrollViewInitInset.bottom;
                self.scrollView.contentInset = inset;
            }];
			break;
        }
		case RefreshStateNormal:
        {
            self.statusLabel.text = @"上拉以便显示下一页";
            CGFloat animDuration = ITCRefreshAnimationDuration;
            CGFloat deltaH = [self contentBreakView];
            CGPoint tempOffset = CGPointZero;
            
            int currentCount = [self totalDataCountInScrollView];
            if (RefreshStateRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
                tempOffset = self.scrollView.contentOffset;
                animDuration = 0;
            }
            
            [UIView animateWithDuration:animDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.bottom = self.scrollViewInitInset.bottom;
                self.scrollView.contentInset = inset;
            }];
            
            if (animDuration == 0) {
                self.scrollView.contentOffset = tempOffset;
            }
			break;
        }
            
        case RefreshStateRefreshing:
        {
            // 记录刷新前的数量
            self.lastRefreshCount = [self totalDataCountInScrollView];
            self.statusLabel.text = @"正在加载...";
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView animateWithDuration:ITCRefreshAnimationDuration animations:^{
                UIEdgeInsets inset = self.scrollView.contentInset;
                CGFloat bottom = ITCRefreshViewHeight + self.scrollViewInitInset.bottom;
                CGFloat deltaH = [self contentBreakView];
                if (deltaH < 0) { // 如果内容高度小于view的高度
                    bottom -= deltaH;
                }
                inset.bottom = bottom;
                self.scrollView.contentInset = inset;
            }];
			break;
        }
        default:
            break;
	}
}

#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)contentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewInitInset.bottom - self.scrollViewInitInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark - 在父类中用得上
// 合理的Y值(刚好看到上拉刷新控件时的contentOffset.y，取相反数)
- (CGFloat)validY
{
    CGFloat deltaH = [self contentBreakView];
    if (deltaH > 0) {
        return deltaH -self.scrollViewInitInset.top;
    } else {
        return -self.scrollViewInitInset.top;
    }
}

- (RefreshViewType)viewType
{
    return RefreshViewTypeFooter;
}

- (void)free
{
    [super free];
    [self.scrollView removeObserver:self forKeyPath:ITCRefreshContentSize];
}
@end