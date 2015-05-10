//
//  XWHMessageDetailViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/14.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageDetailViewController.h"
#import "XWHMessageDetailModel.h"
#import <QuickLook/QuickLook.h>
#import "DXPopover.h"
#import "XWHPopoverContentView.h"
#import "XWHMessageSendingViewController.h"

#define FILE_NAME @"fileName"
#define FILE_ID @"fileId"
#define ISDOWNLOAD @"isDownload"

@interface XWHMessageDetailViewController ()<UIAlertViewDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource>

@property (weak, nonatomic) IBOutlet UILabel *sjrlb;
@property (weak, nonatomic) IBOutlet UILabel *fjrlb;
@property (weak, nonatomic) IBOutlet UILabel *subjectlb;
@property (weak, nonatomic) IBOutlet UILabel *datelb;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailBottomConstraint;

@property (strong, nonatomic) XWHMessageDetailModel *model;
@property (strong, nonatomic) NSMutableDictionary *attachmentDiction;
@property (strong, nonatomic) NSString *filePath;

@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;

@end

@implementation XWHMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavTitle:@"消息详情"];
    
    [self setNavBackBtn];
    [self setNavExtraBarItem];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.attachmentDiction = [[NSMutableDictionary alloc] init];
    
    [self progressHUDShowWithTitle:@"正在加载..."];
    if(self.type == RECEIVE_MESSAGE) {
        [[XWHHttpClient sharedInstance] readReceiveMessageById:self.messageId compltetHandler:^(NetworkResult networkResult, NSInteger renMsg, id detail) {
            [self progressHUDHide:YES];
            if (networkResult == NetworkResultSuccess) {
                if (renMsg == 9) {
                    self.model = detail;
                    
                    UIFont *lb = [UIFont boldSystemFontOfSize:13];
                    UIFont *value = [UIFont systemFontOfSize:12];
                    
                    NSMutableAttributedString *sjr = [[NSMutableAttributedString alloc] initWithString:@"收件人:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *sjrPeople = [[NSAttributedString alloc] initWithString:[XWHAppConfiguration sharedConfiguration].userName attributes:@{NSFontAttributeName: value}];
                    [sjr appendAttributedString:sjrPeople];
                    self.sjrlb.attributedText = sjr;
                    
                    NSMutableAttributedString *fjr = [[NSMutableAttributedString alloc] initWithString:@"发件人:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *fjrPeople = [[NSAttributedString alloc] initWithString:self.model.fromUserName attributes:@{NSFontAttributeName: value}];
                    [fjr appendAttributedString:fjrPeople];
                    self.fjrlb.attributedText = fjr;
                    
                    NSMutableAttributedString *subject = [[NSMutableAttributedString alloc] initWithString:@"主    题:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *subjectStr = [[NSAttributedString alloc] initWithString:self.model.subject attributes:@{NSFontAttributeName: value}];
                    [subject appendAttributedString:subjectStr];
                    self.subjectlb.attributedText = subject;
                    
                    NSMutableAttributedString *date = [[NSMutableAttributedString alloc] initWithString:@"日    期:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *dateStr = [[NSAttributedString alloc] initWithString:self.model.sendTime attributes:@{NSFontAttributeName: value}];
                    [date appendAttributedString:dateStr];
                    self.datelb.attributedText = date;
                    
                    [self.detailWebView loadHTMLString:self.model.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                    [self addAttachmentLabel:self.model.attachFilesArray];
                }
            } else {
                [self showNetWorkError:networkResult];
            }
        }];
    } else {
        [[XWHHttpClient sharedInstance] getSendMessageDetailById:self.messageId compltetHandler:^(NetworkResult networkResult, NSInteger renMsg, id detail) {
            [self progressHUDHide:YES];
            if (networkResult == NetworkResultSuccess) {
                if (renMsg == 9) {
                    self.model = detail;
                    
                    UIFont *lb = [UIFont boldSystemFontOfSize:13];
                    UIFont *value = [UIFont systemFontOfSize:12];
                    
                    NSMutableAttributedString *sjr = [[NSMutableAttributedString alloc] initWithString:@"收件人:  " attributes:@{NSFontAttributeName: lb}];
                    
                    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] init];
                    for (NSDictionary *diction in self.model.userList) {
                        NSString *userName = [diction objectForKey:USER_NAME];
                        BOOL flag = [[diction objectForKey:USER_READ] boolValue];
                        if (flag) {
                            [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName:[UIColor greenColor], NSFontAttributeName: value}]];
                        } else {
                            [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:userName attributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName: value}]];
                        }
                        [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"; " attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: value}]];
                    }
                    [sjr appendAttributedString:attriStr];
                    self.sjrlb.attributedText = sjr;
                    
                    NSMutableAttributedString *fjr = [[NSMutableAttributedString alloc] initWithString:@"发件人:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *fjrPeople = [[NSAttributedString alloc] initWithString:[XWHAppConfiguration sharedConfiguration].userName attributes:@{NSFontAttributeName: value}];
                    [fjr appendAttributedString:fjrPeople];
                    self.fjrlb.attributedText = fjr;
                    
                    NSMutableAttributedString *subject = [[NSMutableAttributedString alloc] initWithString:@"主    题:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *subjectStr = [[NSAttributedString alloc] initWithString:self.model.subject attributes:@{NSFontAttributeName: value}];
                    [subject appendAttributedString:subjectStr];
                    self.subjectlb.attributedText = subject;
                    
                    NSMutableAttributedString *date = [[NSMutableAttributedString alloc] initWithString:@"日    期:  " attributes:@{NSFontAttributeName: lb}];
                    NSAttributedString *dateStr = [[NSAttributedString alloc] initWithString:self.model.sendTime attributes:@{NSFontAttributeName: value}];
                    [date appendAttributedString:dateStr];
                    self.datelb.attributedText = date;
                    
                    [self.detailWebView loadHTMLString:self.model.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                    [self addAttachmentLabel:self.model.attachFilesArray];
                }
            } else {
                [self showNetWorkError:networkResult];
            }
        }];
    }
    
    self.popoverView = [[DXPopover alloc] init];
    NSArray *dataArray = nil;
    if (self.type == RECEIVE_MESSAGE) {
        dataArray = @[@"回复", @"转发"];
    } else if (self.type == SENT_MESSAGE) {
        dataArray = @[@"转发"];
    }
    self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 80, dataArray.count * POPOVER_CELL_HEIGHT) data:dataArray];
    __weak typeof(self) weakSelfReference = self;
    self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
        [weakSelfReference.popoverView dismiss];
        XWHMessageSendingViewController *sendingVC = [[XWHMessageSendingViewController alloc] init];
        sendingVC.model = weakSelfReference.model;
        if (indexRow == 0) {
            if (weakSelfReference.type == RECEIVE_MESSAGE) {
                sendingVC.detailType = RE_MESSAGE;
            } else if (weakSelfReference.type == SENT_MESSAGE) {
                sendingVC.detailType = FW_MESSAGE;
            }
        } else if (indexRow == 1) {
            sendingVC.detailType = FW_MESSAGE;
        }
        [weakSelfReference.navigationController pushViewController:sendingVC animated:YES];
    };
}

- (void)setNavExtraBarItem
{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30, 32);
    [moreBtn setImage:[UIImage imageNamed:@"nav_more_normal"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"nav_more_selected"] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreBarItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    self.navigationItem.rightBarButtonItem = moreBarItem;
}

- (void)moreBtnAction:(id)sender
{
    UIButton *btn = sender;
    CGPoint startPoint = CGPointMake(CGRectGetMidX(btn.frame), CGRectGetMaxY(btn.frame)+20);
    [self.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popoverContentView inView:self.tabBarController.view];
    self.popoverView.cornerRadius = 3.0f;
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addAttachmentLabel:(NSArray *)attachmentArray
{
    if (attachmentArray.count != 0) {
        self.bottomView.hidden = NO;
    } else {
        self.bottomView.hidden = YES;
        self.detailBottomConstraint.constant = 57;
        return;
    }
    CGFloat allheight = 0;
    CGFloat margin = 40;
    CGFloat lbHeight = 20;
    NSInteger index = 0;
    
    UIView *toplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bottomView.frame), 1)];
    toplineView.backgroundColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:toplineView];
    
    UIView *bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bottomView.frame)-1, CGRectGetWidth(self.bottomView.frame), 1)];
    bottomlineView.backgroundColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:bottomlineView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fujian"]];
    imageView.frame = CGRectMake(8, 4, 12, 12);
    [self.bottomView addSubview:imageView];
    
    UILabel *numberlb = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 10, 15)];
    numberlb.font = [UIFont boldSystemFontOfSize:13];
    numberlb.textColor = [UIColor redColor];
    numberlb.backgroundColor = [UIColor clearColor];
    numberlb.text = [NSString stringWithFormat:@"(%ld):",attachmentArray.count];
    [numberlb sizeToFit];
    [self.bottomView addSubview:numberlb];
    
    for (NSDictionary *diction in attachmentArray) {
        NSString *fileName = [diction objectForKey:ATTACHFILE_NAME];
        NSString *fileExt = [diction objectForKey:ATTACHFILE_EXT];
        NSInteger fileId = [[diction objectForKey:ATTACHFILE_ID] integerValue];
        NSString *file = [NSString stringWithFormat:@"%@.%@",fileName,fileExt];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, lbHeight*index, CGRectGetWidth(self.bottomView.frame) - 40, lbHeight)];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12];
        label.tag = fileId;
        label.text = file;
        label.userInteractionEnabled = YES;
        NSDictionary *temp = nil;
        if ([[XWHAppConfiguration sharedConfiguration] isDownLoadWithId:fileId]) {
            label.textColor = [UIColor blackColor];
            temp = @{
                     FILE_NAME:file,
                     ISDOWNLOAD:[NSNumber numberWithBool:YES]
                     };
        } else {
            label.textColor = [UIColor redColor];
            temp = @{
                     FILE_NAME:file,
                     ISDOWNLOAD:[NSNumber numberWithBool:NO]
                     };
        }
        [self.attachmentDiction setObject:temp forKey:[NSNumber numberWithInteger:fileId]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [label addGestureRecognizer:tapGesture];
//        CGSize titleSize = [file boundingRectWithSize:CGSizeMake(200, height) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:label.font} context:nil].size;
//        label.frame = CGRectMake(x, 0, titleSize.width, height);
        [self.bottomView addSubview:label];
//        x += (titleSize.width+margin);
        ++index;
        allheight += lbHeight;
    }
    self.bottomView.contentSize = CGSizeMake(CGRectGetWidth(self.bottomView.frame), allheight);
}

#pragma mark - webView delegate method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked &&
        ![[request URL] isFileURL])
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    UILabel *fileLabel = (UILabel *)gesture.view;
    NSInteger tag = fileLabel.tag;
    NSDictionary *temp = [self.attachmentDiction objectForKey:[NSNumber numberWithInteger:tag]];
    NSString *fileName = [temp objectForKey:FILE_NAME];
    [self progressHUDShowwithProgressTitle:@"下载中..."];
    [[XWHHttpClient sharedInstance] downLoadAttachmentById:tag fileName:fileName completeHandler:^(NetworkResult networkResult, NSInteger rtnMsg, double precent, NSString *path) {
        if (networkResult == NetworkResultSuccess) {
            [self setProgressHUDPercent:precent];
            if (rtnMsg == 500) {
                //                    [self progressHUDCompleteHide:YES afterDelay:1.5f title:@"下载完成"];
                fileLabel.textColor = [UIColor blackColor];
                [self progressHUDHide:YES];
                [[XWHAppConfiguration sharedConfiguration] addDownLoadAttachmentId:tag];
                self.filePath = path;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下载完成" message:@"是否打开?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                alertView.delegate = self;
                alertView.tag = 100;
                [alertView show];
            }
        } else {
            
        }
    }];
}

#pragma mark - UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.delegate = self;
            previewController.dataSource = self;
            previewController.currentPreviewItemIndex = 0;
            [self presentViewController:previewController animated:YES completion:NULL];
        }
    }
}


#pragma mark - QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    return fileURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
