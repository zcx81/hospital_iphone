//
//  RefreshFooterView.h
//  
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "RefreshBaseView.h"

@interface RefreshFooterView : RefreshBaseView
+ (instancetype)footerWithTotalCount:(NSInteger)total;
@end