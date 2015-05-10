//
//  XWHPiShiView.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/20.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHPiShiView.h"

@interface XWHPiShiView ()

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation XWHPiShiView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.placeholderText = @"请在此输入批示意见";
    
    self.agreeLabel.textColor = [UIColor greenColor];
    self.disagreeLabel.textColor = [UIColor redColor];
    
    self.monthTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.dayTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self setBtnImage:self.submitBtn];
    [self setBtnImage:self.backBtn];
    
}

- (IBAction)agreeBtnAction:(id)sender {
    self.agreeBtn.selected = !self.agreeBtn.selected;
    self.disAgreeBtn.selected = NO;
}

- (IBAction)disAgreeBtnAction:(id)sender {
    self.disAgreeBtn.selected = !self.disAgreeBtn.selected;
    self.agreeBtn.selected = NO;
}

- (IBAction)submitAction:(id)sender {
    self.callBack(1);
}

- (IBAction)backAction:(id)sender {
    self.callBack(2);
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
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
