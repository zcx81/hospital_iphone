//
//  XWHPopoverContentView.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/22.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define POPOVER_CELL_HEIGHT 40

typedef void(^CellHandler)(NSInteger indexRow, id data);

@interface XWHPopoverContentView : UIView

@property (strong, nonatomic) CellHandler cellSelectHandler;

- (id)initWithFrame:(CGRect)frame data:(NSArray *)data;

- (void)setData:(NSArray *)array;

- (void)setData:(NSArray *)array andHeight:(CGFloat)height;

@end
