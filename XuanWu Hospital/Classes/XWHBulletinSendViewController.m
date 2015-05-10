//
//  XWHBulletinSendViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/10.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHBulletinSendViewController.h"
#import "XWHDBManage.h"
#import "DXPopover.h"
#import "XWHPopoverContentView.h"
#import "XWHBulletinTypeModel.h"
#import "XWHAttachmentViewController.h"

#define DEFAULT_TYPEID 15
#define FILE_NAME @"fileName"
#define FILE_ID @"fileId"
#define ISDOWNLOAD @"isDownload"
#define ATTACHFILE_ID @"FILE_ID"
#define ATTACHFILE_NAME @"FILE_NAME"
#define ATTACHFILE_EXT @"FILE_EXT"

@interface XWHBulletinSendViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextField *checkTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *kindlb;
@property (weak, nonatomic) IBOutlet UIImageView *kindImageView;
@property (weak, nonatomic) IBOutlet UILabel *kindKeylb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *attachmentScrollView;

@property (assign, nonatomic) CGFloat scrollViewBottomHeight;
@property (assign, nonatomic) CGFloat contentViewHeight;

@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;
@property (strong, nonatomic) XWHBulletinTypeModel *selectedBulletinType;
@property (strong, nonatomic) NSArray *typeArray;
@property (strong, nonatomic) NSMutableArray *attachmentArray;
@property (nonatomic, assign, readwrite, getter=isRegisteredNotificationObserver) BOOL registeredNotificationObserver;

@end

@implementation XWHBulletinSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.pageType == GONGSHI) {
        [self setNavTitle:@"发布公示"];
        self.kindKeylb.text = @"公示类型";
    } else if (self.pageType == GONGGAO) {
        [self setNavTitle:@"发布公告"];
        self.kindKeylb.text = @"公告类型";
    }
    [self setNavBackBtn];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initialStyle];
    
    self.attachmentArray = [NSMutableArray array];
    
    [self setBtnImage:self.cancelBtn];
    [self setBtnImage:self.confirmBtn];
    
    self.scrollViewBottomHeight = self.scrollViewBottomConstraint.constant;
    self.contentViewHeight = self.contentViewHeightConstraint.constant;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBgStyle2];
    [self registerNotifcations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self deregisterNotifcations];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialStyle
{
    self.contentTextView.layer.borderWidth = 1.0f;
    self.contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kindGesture:)];
    [self.kindImageView addGestureRecognizer:tapGesture];
    
    self.typeArray = [[XWHDBManage sharedInstance] getAllBulletinType];
    if (self.typeArray != nil && self.typeArray.count != 0) {
        XWHBulletinTypeModel *model = [self.typeArray firstObject];
        self.kindlb.text = model.typeName;
        self.selectedBulletinType = model;
        
        self.popoverView = [[DXPopover alloc] init];
        self.popoverView.cornerRadius = 3.0f;
        self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 120, self.typeArray.count * POPOVER_CELL_HEIGHT)];
        [self.popoverContentView setData:self.typeArray andHeight:250];
        __weak typeof(self) weakSelfReference = self;
        self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
            if ([data isKindOfClass:[XWHBulletinTypeModel class]]) {
                weakSelfReference.selectedBulletinType = data;
                weakSelfReference.kindlb.text = weakSelfReference.selectedBulletinType.typeName;
            }
            [weakSelfReference.popoverView dismiss];
        };
    }
}

- (void)kindGesture:(UITapGestureRecognizer *)gesture
{
    [self regignTextField];
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.kindImageView.frame), CGRectGetMaxY(self.kindImageView.frame)+60);
    [self.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popoverContentView inView:self.tabBarController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
    
    if (self.subjectTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"标题不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else if (self.checkTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"审核人不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else if ([self.checkTextField.text isEqualToString:[XWHAppConfiguration sharedConfiguration].userName]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"审核人不能为本人!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else if (self.contentTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"内容不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSInteger typeId = DEFAULT_TYPEID;
        if (self.typeArray.count != 0) {
            typeId = self.selectedBulletinType.typeId;
        }
        [self progressHUDShowWithTitle:@"正在发布..."];
        [[XWHHttpClient sharedInstance] sendBulletinWithType:self.pageType
                                                       title:self.subjectTextField.text
                                                   checkUser:self.checkTextField.text
                                                      typeId:typeId
                                                     content:self.contentTextView.text
                                                  filesArray:self.attachmentArray
                                             completehandler:^(NetworkResult networkResult, NSInteger rtnMsg) {
                                                 [self progressHUDHide:YES];
                                                 if (networkResult == NetworkResultSuccess) {
                                                     if (rtnMsg == 1) {
                                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"错误!您没有权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                         [alertView show];
                                                     } else if (rtnMsg == 3) {
                                                         NSString *message = self.pageType == GONGGAO?@"发表公告成功":@"发表公示成功";
                                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                         alertView.tag = 100;
                                                         [alertView show];
                                                     } else if (rtnMsg == 2) {
                                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据库操作错误插入数据失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                         [alertView show];
                                                     } else {
                                                         NSString *message = self.pageType == GONGGAO?@"发表公告失败":@"发表公示失败";
                                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                         [alertView show];
                                                     }
                                                 } else {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络原因导致发布失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                     [alertView show];
                                                 }
                                             }];
    }
    
}

#pragma mark - UITextField delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)regignTextField
{
    [self.subjectTextField resignFirstResponder];
    [self.checkTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}

#pragma mark - NotificationCenter

- (void)registerNotifcations
{
    if (!self.isRegisteredNotificationObserver)
    {
        self.registeredNotificationObserver = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)deregisterNotifcations
{
    if (self.isRegisteredNotificationObserver)
    {
        self.registeredNotificationObserver = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
}

#pragma mark - Keyboard

- (void)willShowKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.0
                        options:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                     animations:^(void) {
                         self.contentViewHeightConstraint.constant = 120;
                         self.scrollViewBottomConstraint.constant = 250;
                     }
                     completion:NULL];
}

- (void)willHideKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.0
                        options:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                     animations:^(void) {
                         self.contentViewHeightConstraint.constant = self.contentViewHeight;
                         self.scrollViewBottomConstraint.constant = self.scrollViewBottomHeight;
                     }
                     completion:NULL];
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)attachmentBtnAction:(id)sender
{
    XWHAttachmentViewController *attachmentVC = [[XWHAttachmentViewController alloc] init];
    attachmentVC.handler = ^(NSArray *filesArray) {
        NSMutableArray *attachmentArray = [NSMutableArray array];
        for (NSString *name in filesArray) {
            NSArray *temp = [name componentsSeparatedByString:@"."];
            NSMutableArray *array = [NSMutableArray arrayWithArray:temp];
            [array removeLastObject];
            
            NSDictionary *dic = @{ATTACHFILE_NAME:[array componentsJoinedByString:@"."], ATTACHFILE_EXT:[temp lastObject], ATTACHFILE_ID:@"-1"};
            [attachmentArray addObject:dic];
            if ([self isHasAdded:name] == NO) {
                [self.attachmentArray addObject:dic];
            }
        }
        [self clearAttachment];
        
        [self addAttachmentLabel:self.attachmentArray];
    };
    [self.navigationController pushViewController:attachmentVC animated:YES];
}

- (BOOL)isHasAdded:(NSString *)fileName
{
    BOOL flag = NO;
    for (NSDictionary *diction in self.attachmentArray) {
        NSString *name = [diction objectForKey:ATTACHFILE_NAME];
        NSString *fileExt = [diction objectForKey:ATTACHFILE_EXT];
        NSString *file = [NSString stringWithFormat:@"%@.%@",name,fileExt];
        if ([file isEqualToString:fileName]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (void)clearAttachment
{
    for (UIView *v in self.attachmentScrollView.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
}

- (void)addAttachmentLabel:(NSArray *)attachmentArray
{
    if (attachmentArray.count == 0) {
        return;
    }
    CGFloat allheight = 0;
    CGFloat margin = 5;
    CGFloat lbHeight = 20;
    NSInteger index = 0;
    
    for (NSDictionary *diction in attachmentArray) {
        NSString *fileName = [diction objectForKey:ATTACHFILE_NAME];
        NSString *fileExt = [diction objectForKey:ATTACHFILE_EXT];
        NSInteger fileId = [[diction objectForKey:ATTACHFILE_ID] integerValue];
        NSString *file = [NSString stringWithFormat:@"%@.%@",fileName,fileExt];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, lbHeight*index, CGRectGetWidth(self.attachmentScrollView.frame) - 40, lbHeight)];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12];
        label.tag = fileId;
        label.text = file;
        [self.attachmentScrollView addSubview:label];
        ++index;
        allheight += lbHeight;
    }
    self.attachmentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.attachmentScrollView.frame), allheight);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
