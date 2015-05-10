//
//  XWHMessageSendingViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/15.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageSendingViewController.h"
#import "XWHOfficeViewController.h"
#import "XWHUserModel.h"
#import "XWHAttachmentViewController.h"

@interface XWHMessageSendingViewController () <UITextViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sjrViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *sjrTextView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTexetField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *fjrlb;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewheightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *attachmentScrollView;

@property (strong, nonatomic) NSMutableArray *selectedPeopleArray;
@property (nonatomic, assign, readwrite, getter=isRegisteredNotificationObserver) BOOL registeredNotificationObserver;
@property (assign, nonatomic) CGFloat scrollViewBottomHeight;
@property (assign, nonatomic) CGFloat contentViewHeight;

@property (strong, nonatomic) NSMutableArray *attachmentArray;

@end

@implementation XWHMessageSendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavTitle:@"发布消息"];
    
    [self setNavBackBtn];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sjrTextView.textContainerInset =UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollViewBottomHeight = self.scrollViewBottomConstraint.constant;
    self.contentViewHeight = self.contentViewHeightConstraint.constant;
    [self setBtnImage:self.cancelBtn];
    [self setBtnImage:self.confirmBtn];
    
    self.fjrlb.text = [[XWHAppConfiguration sharedConfiguration] userName];
    self.contentScrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contentScrollView.layer.borderWidth = 1.0f;

    self.attachmentArray = [[NSMutableArray alloc] init];
    
    self.selectedPeopleArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPeople:) name:@"selectedPeople" object:nil];
    
    if (self.detailType == FW_GONGGAO || self.detailType == FW_GONGSHI) {
        self.subjectTexetField.text = [NSString stringWithFormat:@"Fw:%@",self.bulletionModel.title];
        self.webView.hidden = NO;
        [self.webView loadHTMLString:self.bulletionModel.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        [self.attachmentArray addObjectsFromArray:self.bulletionModel.attachFilesArray];
        [self addAttachmentLabel:self.attachmentArray];
    } else if (self.detailType == RE_MESSAGE) {
        XWHUserModel *model = [[XWHUserModel alloc] init];
        model.userId = self.model.fromUserId;
        model.userName = self.model.fromUserName;
        [self.selectedPeopleArray addObject:model];
        self.sjrTextView.text = model.userName;
        self.subjectTexetField.text = [NSString stringWithFormat:@"Re:%@",self.model.subject];
        self.webView.hidden = NO;
        [self.webView loadHTMLString:self.model.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    } else if (self.detailType == FW_MESSAGE) {
        self.subjectTexetField.text = [NSString stringWithFormat:@"Fw:%@",self.model.subject];
        self.webView.hidden = NO;
        [self.webView loadHTMLString:self.model.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        [self.attachmentArray addObjectsFromArray:self.model.attachFilesArray];
        [self addAttachmentLabel:self.attachmentArray];
    } else {
        self.webViewheightConstraint.constant = 0;
        self.textViewHeightConstraint.constant = 294;
    }
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
    [self.webView stopLoading];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPeopleAction:(id)sender {
    XWHOfficeViewController *officeVC = [[XWHOfficeViewController alloc] init];
    [self.navigationController pushViewController:officeVC animated:YES];
}

#pragma mark - UITextViewDelegate method

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = [textView.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.sjrTextView.frame), 600) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.sjrTextView.font} context:nil];
    if (textView == self.sjrTextView) {
       self.sjrViewHeightConstraint.constant = CGRectGetHeight(frame)+16;
    } else {
        if (self.detailType == RE_MESSAGE || self.detailType == FW_MESSAGE || self.detailType == FW_GONGGAO || self.detailType == FW_GONGSHI) {
          self.textViewHeightConstraint.constant = CGRectGetHeight(frame) + 30;
        }
    }
}

- (void)getPeople:(NSNotification *)notification
{
    NSMutableString *peopleStr = [[NSMutableString alloc] initWithString:self.sjrTextView.text];
    NSArray *array = [[notification userInfo] objectForKey:@"people"];
    for (XWHUserModel *obj in array) {
        BOOL flag = YES;
        for (XWHUserModel *model in self.selectedPeopleArray) {
            if (obj.userId == model.userId) {
                flag = NO;
                break;
            }
        }
        if (flag) {
            [self.selectedPeopleArray addObject:obj];
            [peopleStr appendFormat:@"%@, ",obj.userName];
//            NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:obj.userName attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
//            [self.receiveAtStr appendAttributedString:atrStr];
//            [self.receiveAtStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" , "]];
//            self.receivePeopleTextField.attributedText = self.receiveAtStr;
        }
    }
    self.sjrTextView.text = peopleStr;
    
    CGRect frame = [peopleStr boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.sjrTextView.frame), 600) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.sjrTextView.font} context:nil];
    self.sjrViewHeightConstraint.constant = CGRectGetHeight(frame)+16;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
    NSMutableArray *userId = [NSMutableArray array];
    for (XWHUserModel *model in self.selectedPeopleArray) {
        if ([self.sjrTextView.text rangeOfString:model.userName].location != NSNotFound) {
            [userId addObject:[NSNumber numberWithInteger:model.userId]];
        }
    }
    if (self.subjectTexetField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"标题不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else if (userId.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收件人不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSString *title = nil;
        NSString *subTitle = nil;
        if (self.detailType == SEND_MESSAGE) {
            title = @"发送中...";
            subTitle = @"发送成功!";
        } else if (self.detailType == FW_MESSAGE || self.detailType == FW_GONGSHI || self.detailType == FW_GONGGAO) {
            title = @"...";
            subTitle = @"转发成功!";
        } else if (self.detailType == RE_MESSAGE) {
            title = @"...";
            subTitle = @"回复成功!";
        }
        NSString *content = nil;
        if (self.detailType == FW_GONGSHI || self.detailType == FW_GONGGAO) {
            content = [NSString stringWithFormat:@"%@<br/>%@",self.contentTextView.text,self.bulletionModel.content];
        } else if(self.detailType == FW_MESSAGE || self.detailType == RE_MESSAGE) {
            content = [NSString stringWithFormat:@"%@<br/>%@",self.contentTextView.text,self.model.content];
        } else {
            content = self.contentTextView.text;
        }
        
        [self progressHUDShowWithTitle:@"发送中..."];
        [[XWHHttpClient sharedInstance] sendMessageToUser:userId subject:self.subjectTexetField.text content:content filesArray:self.attachmentArray completeHandler:^(NetworkResult networkResult, NSInteger rtnMsg) {
            if (networkResult == NetworkResultSuccess) {
                if (rtnMsg == 3) {
                    [self progressHUDCompleteHide:YES afterDelay:1 title:subTitle];
                    self.detailType = SEND_MESSAGE;
                    [self performSelector:@selector(toMessageList) withObject:nil afterDelay:1.0f];
                } else {
                    [self progressHUDHide:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                [self progressHUDHide:YES];
                [self showNetWorkError:networkResult];
            }
        }];
    }
}

- (void)toMessageList
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - webView delegate method

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSArray *arr = [webView subviews];
    UIScrollView *scrollView = [arr objectAtIndex:0];

    self.textViewHeightConstraint.constant = 100;
    self.webViewheightConstraint.constant = scrollView.contentSize.height;
//    self.middleScrollView.contentSize = CGSizeMake(self.middleScrollView.frame.size.width, self.contentTextView.frame.size.height+self.webView.frame.size.height);
}

- (IBAction)attachmentBtnAction:(id)sender {
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedPeople" object:nil];
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
