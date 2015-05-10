//
//  XWHSmallScheduleSearcView.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/19.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSmallScheduleSearcView.h"

@interface XWHSmallScheduleSearcView ()

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@end

@implementation XWHSmallScheduleSearcView

- (void)awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.criteriaImgView addGestureRecognizer:tapGesture];
    
    [self setBtnImage:self.cancelBtn];
    [self setBtnImage:self.searchBtn];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    self.handler(-1);
}

- (void)show
{
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = -frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(id)sender {
    [self hide];
}

- (IBAction)searchAction:(id)sender {
    self.handler(-2);
}

- (void)setBtnImage:(UIButton *)btn
{
    UIImage *normal_img = [UIImage imageNamed:@"xw_button_bg_normal"];
    normal_img = [normal_img stretchableImageWithLeftCapWidth:floorf(normal_img.size.width/2) topCapHeight:floorf(normal_img.size.height/2)];
    [btn setBackgroundImage:normal_img forState:UIControlStateNormal];
    
    UIImage *pressed_img = [UIImage imageNamed:@"xw_button_bg_pressed"];
    pressed_img = [pressed_img stretchableImageWithLeftCapWidth:floorf(pressed_img.size.width/2) topCapHeight:floorf(pressed_img.size.height/2)];
    [btn setBackgroundImage:pressed_img forState:UIControlStateHighlighted];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
