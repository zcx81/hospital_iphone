//
//  XWHMainPageViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/9.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMainPageViewController.h"
#import "XWHMessageSendingViewController.h"
#import "XWHBulletinModel.h"
#import "XWHDaiBanBigModel.h"
#import "XWHBulletinDetailViewController.h"
#import "XWHMessageSentViewController.h"
#import "XWHGongShiViewController.h"
#import "XWHBulletinSendViewController.h"
#import "XWHSmallScheduleViewController.h"

#define TOP_DAIBAN_VIEW_HEIGHT 180
#define TOP_BULLETIN_VIEW_HEIGHT 145
#define TOP_LIST_FONT_SIZE 13 //下拉列表中 字体大小
#define TOP_LIST_MARGIN_X 25 //下拉列表中 内容 左间距
#define TOP_LIST_MARHIN_RIGHT 10 //下拉列表中内容 右间距

@interface XWHMainPageViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *daiBanImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bulletinImageView;
@property (weak, nonatomic) IBOutlet UILabel *daiBanTitlelb;
@property (weak, nonatomic) IBOutlet UILabel *bulletinTitlelb;
@property (weak, nonatomic) IBOutlet UILabel *unReadMessagelb;

@property (strong, nonatomic) NSMutableArray *noticeArray;
@property (strong, nonatomic) NSMutableArray *daiBanArray;

@property (assign, nonatomic) BulletinType clickBulletinType;
@property (assign, nonatomic) BOOL isCanClickBulletin;
@property (assign, nonatomic) BOOL isCanClickDaiBan;
@property (assign, nonatomic) BOOL buttletinStatus;
@property (assign, nonatomic) BOOL daiBanStatus;

@property (weak, nonatomic) IBOutlet UILabel *daiBanLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleViewTopLayout;

@property (strong, nonatomic) UIView *topBulletinListView;
@property (strong, nonatomic) UIScrollView *topDaibanListView;

@property (assign, nonatomic) NSInteger requestCount;

@end

@implementation XWHMainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.noticeArray = [NSMutableArray array];
    self.daiBanArray = [NSMutableArray array];
    
    self.noticeLabel.userInteractionEnabled = YES;
    self.daiBanLabel.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGesture:)];
    self.daiBanImageView.tag = 100;
    [self.daiBanImageView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGesture:)];
    [self.daiBanTitlelb addGestureRecognizer:tapGesture2];
    
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGesture:)];
    self.bulletinImageView.tag = 200;
    [self.bulletinImageView addGestureRecognizer:tapGesture3];
        UITapGestureRecognizer *tapGesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGesture:)];
    [self.bulletinTitlelb addGestureRecognizer:tapGesture4];
    
    [self hideTopView:YES];
    
    self.unReadMessagelb.layer.cornerRadius = 11.5f;
    self.unReadMessagelb.hidden = YES;
    self.unReadMessagelb.clipsToBounds = YES;
    
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateBtn.frame = CGRectMake(0, 0, 30, 30);
    [updateBtn setBackgroundImage: [UIImage imageNamed:@"mainPage_update"] forState:UIControlStateNormal];
    [updateBtn addTarget:self action:@selector(barBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *updateBar = [[UIBarButtonItem alloc] initWithCustomView:updateBtn];
    self.navigationItem.rightBarButtonItem = updateBar;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UITapGestureRecognizer *tapGesture5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topDataGesture:)];
    [self.noticeLabel addGestureRecognizer:tapGesture5];
    
    UITapGestureRecognizer *tapGesture6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topDataGesture:)];
    [self.daiBanLabel addGestureRecognizer:tapGesture6];
    
    self.requestCount = 3;
    
    [self setTopViewData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBgStyle1];
}

- (void)barBtnAction:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.requestCount == 0) {
        self.requestCount = 3;
        [self progressHUDShowWithTitle:@"正在刷新..."];
        [self setTopViewData];
    }
}

- (void)setTopViewData
{
//    if (self.noticeArray.count == 0) {
        [[XWHHttpClient sharedInstance] getBulletinListByPage:1 type:GONGGAO completeHandler:^(NetworkResult networkResult, NSArray *array, NSInteger totalCount) {
            if (networkResult == NetworkResultSuccess) {
                if (array.count != 0) {
                    self.isCanClickBulletin = YES;
                    [self.noticeArray removeAllObjects];
                    [self.noticeArray addObjectsFromArray:array];
                    XWHBulletinModel *model = [self.noticeArray firstObject];
                    self.noticeLabel.text = model.title;
                    self.noticeLabel.tag = model.bulletinId;
                }
            }
            self.requestCount--;
            [self updateFinished];
        }];
//    }
    
//    if (self.daiBanArray.count == 0) {
        [[XWHHttpClient sharedInstance] getAllWaiteWorkFlowHandler:^(NetworkResult networkResult, NSString *rtnMsg, NSArray *array) {
            if (networkResult == NetworkResultSuccess) {
                if (array.count != 0) {
                    self.isCanClickDaiBan = YES;
                    [self.daiBanArray removeAllObjects];
                    NSArray *workFlowId = @[@"164", @"185", @"159", @"211", @"183", @"195", @"191", @"196", @"160", @"163", @"203", @"199", @"187", @"158", @"161", @"186", @"201", @"162", @"149", @"151"];
                    for (NSString *wfId in workFlowId) {
                        for (XWHDaiBanBigModel *model in array) {
                            if (model.procdefId == [wfId integerValue]) {
                                [self.daiBanArray addObject:model];
                            }
                        }
                    }
                    XWHDaiBanBigModel *model = [self.daiBanArray firstObject];
                    self.daiBanLabel.tag = model.procdefId;
                    
                    NSMutableAttributedString *name = nil;
                    if (model.procdefName != nil && model.procdefName.length != 0) {
                        name = [[NSMutableAttributedString alloc] initWithString:model.procdefName];
                        if (model.cnt != 0) {
                            [name appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%ld)",(long)model.cnt] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
                        }
                    }
                    self.daiBanLabel.attributedText = name;
                    
                    [self hideTopView:NO];
                }
            }
            self.requestCount--;
            [self updateFinished];
        }];
//    }
    
    [[XWHHttpClient sharedInstance] getMessageUnReadCount:^(NetworkResult networkResult, NSInteger count) {
        //        NSLog(@"未读消息条数：%d", count);
        self.unReadMessagelb.hidden = YES;
        if (networkResult == NetworkResultSuccess && count != 0) {
            self.unReadMessagelb.hidden = NO;
            self.unReadMessagelb.text = [NSString stringWithFormat:@"%ld",(long)count];
        }
        self.requestCount--;
        [self updateFinished];
    }];
}

- (void)updateFinished
{
    if (self.requestCount == 0) {
        [self progressHUDHide:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)hideTopView:(BOOL)flag
{
    if (flag) {// 显示topview
        self.topView.hidden = YES;
        self.middleViewTopLayout.constant = 64;
    } else {// 隐藏topview
        self.topView.hidden = NO;
        self.middleViewTopLayout.constant = 112;
    }
}

- (void)topDataGesture:(UITapGestureRecognizer *)tapGesture
{
    UILabel *lb = (UILabel *)tapGesture.view;
    if (lb == self.noticeLabel || (lb != self.daiBanLabel && self.clickBulletinType == GONGGAO)) {
        XWHBulletinDetailViewController *detailViewController = [[XWHBulletinDetailViewController alloc] init];
        detailViewController.bulletinId = lb.tag;
        detailViewController.type = GONGGAO;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        XWHSmallScheduleViewController *smallWorkFlow = [[XWHSmallScheduleViewController alloc] init];
        smallWorkFlow.kindArray = self.daiBanArray;
        
        XWHDaiBanBigModel *model = [[XWHDaiBanBigModel alloc] init];
        model.procdefId = lb.tag;
        for (XWHDaiBanBigModel *daiban in self.daiBanArray) {
            if (daiban.procdefId == lb.tag) {
                model.procdefName = daiban.procdefName;
                break;
            }
        }
        smallWorkFlow.bigModel = model;
        [self.navigationController pushViewController:smallWorkFlow animated:YES];
    }
    
}

- (IBAction)buttonAction:(id)sender {
    UIButton *btn = sender;
    switch (btn.tag) {
        case 101: //发布消息
        {
            XWHMessageSendingViewController *sendingVC = [[XWHMessageSendingViewController alloc] init];
            [self.navigationController pushViewController:sendingVC animated:YES];
        }
            break;
        case 102: //已发消息
        {
            XWHMessageSentViewController *sentVC = [[XWHMessageSentViewController alloc] init];
            [self.navigationController pushViewController:sentVC animated:YES];
        }
            break;
        case 103: //已收消息
        {
            self.tabBarController.selectedIndex = 1;
        }
            break;
        case 104: //流程管理
        {
            self.tabBarController.selectedIndex = 2;
        }
            break;
        case 105: //发布公告
        {
            XWHBulletinSendViewController *sendVC = [[XWHBulletinSendViewController alloc] init];
            sendVC.pageType = GONGGAO;
            [self.navigationController pushViewController:sendVC animated:YES];
        }
            break;
        case 106: //公告列表
        {
            self.tabBarController.selectedIndex = 3;
        }
            break;
        case 107: //发布公示
        {
            XWHBulletinSendViewController *sendVC = [[XWHBulletinSendViewController alloc] init];
            sendVC.pageType = GONGSHI;
            [self.navigationController pushViewController:sendVC animated:YES];
        }
            break;
        case 108: //公示列表
        {
            XWHGongShiViewController *gongShiVC = [[XWHGongShiViewController alloc] init];
            [self.navigationController pushViewController:gongShiVC animated:YES];
        }
            break;
        case 109: //退出
        {
            XWHCustomTabBarViewController *customTabBarVC = (XWHCustomTabBarViewController *)self.tabBarController;
            customTabBarVC.selectedKind = SelectedLogout;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - TopView detail data method

- (IBAction)arrowBtnAction:(id)sender {
    UIButton *button = sender;
    [self createTopListView];
    
    if (button.tag == 200) {//公告
        if (!self.isCanClickBulletin) {
            return;
        }
        button.enabled = NO;
        if (self.buttletinStatus == NO) {//显示
            CGRect frame = self.middleView.frame;
            CGRect dataFrame = self.topBulletinListView.frame;
            self.topBulletinListView.frame = CGRectMake(0, frame.origin.y+frame.size.height, dataFrame.size.width, 0);
            [self createTopBulletinListData];
            [UIView animateWithDuration:0.5f animations:^{
                self.topBulletinListView.hidden = NO;
                self.topBulletinListView.frame = CGRectMake(0, self.topBulletinListView.frame.origin.y, dataFrame.size.width, TOP_BULLETIN_VIEW_HEIGHT);
            } completion:^(BOOL finished) {
                button.enabled = YES;
            }];
            self.buttletinStatus = YES;
            self.clickBulletinType = GONGGAO;
        } else { //隐藏
            CGRect frame = self.topBulletinListView.frame;
            [UIView animateWithDuration:0.5f animations:^{
                self.topBulletinListView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
            } completion:^(BOOL finished) {
                button.enabled = YES;
                [self removeTopBulletinListData];
                self.topBulletinListView.hidden = YES;
            }];
            self.buttletinStatus = NO;
        }
    } else if (button.tag == 100) {//待办
        if (!self.isCanClickDaiBan) {
            return;
        }
        button.enabled = NO;
        self.clickBulletinType = GONGSHI;
        if (self.daiBanStatus == NO) {
            
            CGRect frame = self.topView.frame;
            CGRect dataFrame = self.topDaibanListView.frame;
            self.topDaibanListView.frame = CGRectMake(0, frame.origin.y+frame.size.height, dataFrame.size.width, 0);
            [self createTopDaiBanData];
            
            if (self.buttletinStatus) {
                CGRect frame = self.topBulletinListView.frame;
                frame.size.height = 0;
                [UIView animateWithDuration:0.5f animations:^{
                    self.topBulletinListView.frame = frame;
                } completion:^(BOOL finished) {
                    [self removeTopBulletinListData];
                    self.topBulletinListView.hidden = YES;
                    [UIView animateWithDuration:0.5f animations:^{
                        self.topDaibanListView.hidden = NO;
                        self.topDaibanListView.frame = CGRectMake(0, self.topDaibanListView.frame.origin.y, dataFrame.size.width, TOP_DAIBAN_VIEW_HEIGHT);
                    } completion:^(BOOL finished) {
                        button.enabled = YES;
                    }];
                }];
                self.buttletinStatus = NO;
            } else {
                [UIView animateWithDuration:0.5f animations:^{
                    self.topDaibanListView.hidden = NO;
                    self.topDaibanListView.frame = CGRectMake(0, self.topDaibanListView.frame.origin.y, dataFrame.size.width, TOP_DAIBAN_VIEW_HEIGHT);
                } completion:^(BOOL finished) {
                    button.enabled = YES;
                }];
            }
            self.daiBanStatus = YES;
        } else {
            CGRect frame = self.topDaibanListView.frame;
            frame.size.height= 0;
            [UIView animateWithDuration:0.5f animations:^{
                self.topDaibanListView.frame = frame;
            } completion:^(BOOL finished) {
                button.enabled = YES;
                [self removeDaiBanTopData];
                self.topDaibanListView.hidden = YES;
            }];
            self.daiBanStatus = NO;
        }
    }
}

- (void)createTopListView
{
    if (self.topBulletinListView == nil) {
        self.topBulletinListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.middleView.frame.size.width, 0)];
        self.topBulletinListView.hidden = YES;
        self.topBulletinListView.backgroundColor = GRAY_BACKGROUND_COLOR;
        [self.view addSubview:self.topBulletinListView];
        self.topBulletinListView.clipsToBounds = YES;
    }
    
    if (self.topDaibanListView == nil) {
        self.topDaibanListView = [[UIScrollView alloc] initWithFrame:self.topBulletinListView.frame];
        self.topDaibanListView.hidden = YES;
        self.topDaibanListView.backgroundColor = GRAY_BACKGROUND_COLOR;
        [self.view addSubview:self.topDaibanListView];
        self.topDaibanListView.clipsToBounds = YES;
    }
}

- (void)createTopBulletinListData
{
    CGFloat lbheight = 35;
    for (NSInteger index = 1; index < 5 && index < self.noticeArray.count; index++) {
        XWHBulletinModel *model = [self.noticeArray objectAtIndex:index];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TOP_LIST_MARGIN_X, lbheight*(index-1), self.topBulletinListView.frame.size.width-TOP_LIST_MARGIN_X-TOP_LIST_MARHIN_RIGHT, lbheight)];
        label.text = model.title;
        label.tag = model.bulletinId;
        label.font = [UIFont systemFontOfSize:TOP_LIST_FONT_SIZE];
//        label.backgroundColor = [UIColor yellowColor];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topDataGesture:)];
        [label addGestureRecognizer:tapGesture];
        [self.topBulletinListView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(label.frame)+label.frame.origin.y, CGRectGetWidth(self.topBulletinListView.frame) - 20, 1)];
        imageView.image = [UIImage imageNamed:@"xw_list_divider"];
        [self.topBulletinListView addSubview:imageView];
        
        UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.topBulletinListView.frame)-20, label.frame.origin.y+lbheight/2.0-5, 4, 10)];
        arrowImgView.image = [UIImage imageNamed:@"arrow_right"];
        [self.topBulletinListView addSubview:arrowImgView];
    }
}

- (void)removeTopBulletinListData
{
    for (XWHBulletinModel *model in self.noticeArray) {
        UIView *v = [self.topBulletinListView viewWithTag:model.bulletinId];
        if (v != nil) {
            [v removeFromSuperview];
        }
    }
}

- (void)createTopDaiBanData
{
    CGFloat height = 35;
    CGFloat allHeight = 0;
    for (NSInteger index = 1; index < self.daiBanArray.count; index++) {
        XWHDaiBanBigModel *model = [self.daiBanArray objectAtIndex:index];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TOP_LIST_MARGIN_X, height*(index-1), self.topBulletinListView.frame.size.width-TOP_LIST_MARGIN_X-TOP_LIST_MARHIN_RIGHT, height)];
        label.tag = model.procdefId;
        label.font = [UIFont systemFontOfSize:TOP_LIST_FONT_SIZE];
        //        label.backgroundColor = [UIColor yellowColor];
        NSMutableAttributedString *name = nil;
        if (model.procdefName != nil && model.procdefName.length != 0) {
            name = [[NSMutableAttributedString alloc] initWithString:model.procdefName];
            if (model.cnt != 0) {
                [name appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%ld)",(long)model.cnt] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
            }
        }
        label.attributedText = name;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topDataGesture:)];
        [label addGestureRecognizer:tapGesture];
        [self.topDaibanListView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(label.frame)+label.frame.origin.y, CGRectGetWidth(self.topBulletinListView.frame) - 20, 1)];
        imageView.image = [UIImage imageNamed:@"xw_list_divider"];
        [self.topDaibanListView addSubview:imageView];
        
        UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.topBulletinListView.frame)-20, label.frame.origin.y+height/2.0 - 5, 4, 10)];
        arrowImgView.image = [UIImage imageNamed:@"arrow_right"];
        [self.topDaibanListView addSubview:arrowImgView];
        
        allHeight += height;
    }
    if (allHeight > TOP_DAIBAN_VIEW_HEIGHT) {
        self.topDaibanListView.contentSize = CGSizeMake(CGRectGetWidth(self.topDaibanListView.bounds), allHeight);
    }
    self.topDaibanListView.contentOffset = CGPointZero;
}

- (void)removeDaiBanTopData
{
    for (XWHDaiBanBigModel *model in self.daiBanArray) {
        UIView *v = [self.topDaibanListView viewWithTag:model.procdefId];
        if (v != nil) {
            [v removeFromSuperview];
        }
    }
}

- (void)imageViewTapGesture:(UITapGestureRecognizer *)gesture
{
    UIView *v = gesture.view;
    if (v.tag == 100) { // 待办事宜点击
        if (self.daiBanArray != nil && self.daiBanArray.count != 0) {
            XWHSmallScheduleViewController *smallWorkFlow = [[XWHSmallScheduleViewController alloc] init];
            smallWorkFlow.kindArray = self.daiBanArray;
            
            XWHDaiBanBigModel *model = [[XWHDaiBanBigModel alloc] init];
            model.procdefId = 0;
            model.procdefName = @"全部类型";
            smallWorkFlow.bigModel = model;
            [self.navigationController pushViewController:smallWorkFlow animated:YES];
        }
    } else if (v.tag == 200) { //最新公告点击
        self.tabBarController.selectedIndex = 3;
    }
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
