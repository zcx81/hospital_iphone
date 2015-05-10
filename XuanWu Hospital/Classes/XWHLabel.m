//
//  XWHLabel.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/13.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHLabel.h"

@interface XWHLabel ()

@property(nonatomic) UIEdgeInsets insets;

@end

@implementation XWHLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andInsets:(UIEdgeInsets)insets {
    self = [super initWithFrame:frame];
    if(self){
        self.insets = insets;
    }
    return self; 
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    return [super drawTextInRect:CGRectMake(rect.origin.x + self.font.pointSize/2, rect.origin.y, rect.size.width - self.font.pointSize, rect.size.height)];
    // Drawing code
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end
