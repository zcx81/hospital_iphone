//
//  RefreshBaseView.h
//  
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "RefreshBaseView.h"

@interface  RefreshBaseView()

@property (assign, nonatomic) BOOL hasInitInset;

// 合理的Y值
- (CGFloat)validY;
// view的类型
- (RefreshViewType)viewType;

@end

@implementation RefreshBaseView

#pragma mark - create UILabel
- (UILabel *)labelWithFontSize:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = ITCRefreshLabelTextColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.hasInitInset) {
        self.scrollViewInitInset = self.scrollView.contentInset;
    
        [self observeValueForKeyPath:ITCRefreshContentSize ofObject:nil change:nil context:nil];
        
        self.hasInitInset = YES;
        
        if (self.state == RefreshStateWillRefreshing) {
            [self setState:RefreshStateRefreshing];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame totalCount:(NSInteger)total{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:_statusLabel = [self labelWithFontSize:13]];

        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:arrowImage];
        _arrowImage = arrowImage;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = arrowImage.bounds;
        activityView.autoresizingMask = arrowImage.autoresizingMask;
        [self addSubview:activityView];
        _activityView = activityView;
        
        self.currentNumber = 1;
        self.totalCount = total;

        [self setState:RefreshStateNormal];
    }
    return self;
}

#pragma mark 设置frame
- (void)setFrame:(CGRect)frame
{
    frame.size.height = ITCRefreshViewHeight;
    [super setFrame:frame];
    
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    if (w == 0 || self.arrowImage.center.y == h * 0.5) return;
    
    CGFloat statusX = 0;
    CGFloat statusY = ITCRefreshViewHeight-30;
    CGFloat statusHeight = 20;
    CGFloat statusWidth = w;
    self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    
    CGFloat arrowX = w * 0.5 - 115;
    self.arrowImage.center = CGPointMake(arrowX, h * 0.5);
    self.activityView.center = self.arrowImage.center;
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size.height = ITCRefreshViewHeight;
    [super setBounds:bounds];
}

#pragma mark set scrollview
- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:ITCRefreshContentOffset context:nil];
    [scrollView addObserver:self forKeyPath:ITCRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
    _scrollView = scrollView;
    [_scrollView addSubview:self];
}

#pragma mark observe method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![ITCRefreshContentOffset isEqualToString:keyPath]) return;
    
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden
        || self.state == RefreshStateRefreshing) return;
    
    CGFloat offsetY = self.scrollView.contentOffset.y * self.viewType;
    CGFloat validY = self.validY;
    if (offsetY <= validY) return;
    
    if (self.scrollView.isDragging) {
        CGFloat validOffsetY = validY + ITCRefreshViewHeight;
        if (self.state == RefreshStatePulling && offsetY <= validOffsetY) {
            [self setState:RefreshStateNormal];
            if (self.refreshStateChangeBlock) {
                self.refreshStateChangeBlock(self, RefreshStateNormal);
            }
        } else if (self.state == RefreshStateNormal && offsetY > validOffsetY) {
            [self setState:RefreshStatePulling];
            if (self.refreshStateChangeBlock) {
                self.refreshStateChangeBlock(self, RefreshStatePulling);
            }
        }
    } else {
        if (self.state == RefreshStatePulling) {
            [self setState:RefreshStateRefreshing];
            if (self.refreshStateChangeBlock) {
                self.refreshStateChangeBlock(self, RefreshStateRefreshing);
            }
        }
    }
}

#pragma mark 设置状态
- (void)setState:(RefreshState)state
{
    if (self.state != RefreshStateRefreshing) {
        self.scrollViewInitInset = self.scrollView.contentInset;
    }
    if (self.state == state) return;
    switch (state) {
		case RefreshStateNormal:
            self.arrowImage.hidden = NO;
			[self.activityView stopAnimating];
            
            if (RefreshStateRefreshing == _state) {
                if (self.endStateChangeBlock) {
                    self.endStateChangeBlock(self);
                }
            }
			break;
        case RefreshStatePulling:
            break;
		case RefreshStateRefreshing:
			[self.activityView startAnimating];
			self.arrowImage.hidden = YES;
            self.arrowImage.transform = CGAffineTransformIdentity;
            if (self.beginRefreshingBlock) {
                self.beginRefreshingBlock(self);
            }
			break;
        default:
            break;
	}
    _state = state;
}

- (BOOL)isRefreshing
{
    return RefreshStateRefreshing == self.state;
}

- (void)beginRefreshing
{
    if (self.window) {
        [self setState:RefreshStateRefreshing];
    } else {
        self.state = RefreshStateWillRefreshing;
    }
}

- (void)endRefreshing
{
    double delayInSeconds = self.viewType == RefreshViewTypeFooter ? 0.3 : 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setState:RefreshStateNormal];
    });
}

#pragma mark - 随便实现
- (CGFloat)validY
{
    return 0;
}

- (RefreshViewType)viewType
{
    return RefreshViewTypeHeader;
}

- (void)free
{
    [self.scrollView removeObserver:self forKeyPath:ITCRefreshContentOffset];
}

- (void)removeFromSuperview
{
    [self free];
    self.scrollView = nil;
    [super removeFromSuperview];
}

- (void)endRefreshingWithoutIdle
{
    [self endRefreshing];
}

- (int)totalDataCountInScrollView
{
    int totalCount = 0;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        
        for (int section = 0; section<tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        for (int section = 0; section<collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}
@end