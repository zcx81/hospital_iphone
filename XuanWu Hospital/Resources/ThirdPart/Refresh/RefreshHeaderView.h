//
//  RefreshHeaderView.h
//
//
//  Created by Mingyang on 14/5/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "RefreshBaseView.h"

@interface RefreshHeaderView : RefreshBaseView
+ (instancetype)headerWithTotalCount:(NSInteger)total;
@end