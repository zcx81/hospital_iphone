//
//  XWHSearchPopView.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/5.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSearchPopView.h"
#import "XWHDatePickerView.h"

@interface XWHSearchPopView () <UITextFieldDelegate>

@property (strong, nonatomic) XWHDatePickerView *datePickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@end

@implementation XWHSearchPopView

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.searchTextFiled resignFirstResponder];
    if (self.datePickerView == nil) {
        self.datePickerView = [[[NSBundle mainBundle] loadNibNamed:@"XWHDatePickerView" owner:nil options:nil] firstObject];
        [self addSubview:self.datePickerView];
    }
//    [self.datePickerView initSelectData];
    [self.datePickerView initSelectDataWithStr:textField.text];
    __weak typeof(self) weakVC = self;
    __block __weak UITextField *weakTextField = textField;
    self.datePickerView.callBack = ^(BOOL flag, NSString *dateString) {
        weakVC.datePickerView.hidden = YES;
        if (flag == YES) {
            weakTextField.text = dateString;
        }
    };
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerView.hidden = NO;
        textField.text = @"";
    }];
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [touches anyObject];
//    if (touch.view != self.topView) {
//        [self hide];
//    }
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

@end
