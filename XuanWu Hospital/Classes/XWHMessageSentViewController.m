//
//  XWHMessageSentViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/4.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHMessageSentViewController.h"
#import "XWHPopoverContentView.h"
#import "DXPopover.h"
#import "RefreshFooterView.h"
#import "RefreshHeaderView.h"
#import "XWHMessageListCell.h"
#import "XWHMessageDetailViewController.h"
#import "XWHMessageSendingViewController.h"
#import "XWHMessageSearchView.h"

@interface XWHMessageSentViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) NSInteger currentNumber;
@property (strong, nonatomic) RefreshHeaderView *refreshHeader;
@property (strong, nonatomic) RefreshFooterView *refreshFooter;
@property (assign, nonatomic) RefreshViewType refreshViewType;
@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;

@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) NSString *keyWords;
@property (strong, nonatomic) NSString *criteria;

@property (strong, nonatomic) XWHMessageSearchView *searchPopView;

@end

@implementation XWHMessageSentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavBgStyle2];
    [self setNavTitle:@"已发消息"];
    [self setNavBackBtn];
    [self setNavExtraBarItem];
    
    self.dataArray = [NSMutableArray array];
    [self.mTableView registerNib:[UINib nibWithNibName:@"XWHMessageListCell" bundle:nil] forCellReuseIdentifier:@"MessageListCell"];
    self.mTableView.hidden = YES;
    [self addHeader];
    self.currentNumber = 1;
    [self getSearchDataWithIndexPage:1];
    
    self.popoverView = [[DXPopover alloc] init];
    self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    NSArray *dataArray = @[@"删除消息", @"发布消息", @"已收消息"];
    self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 120, dataArray.count * POPOVER_CELL_HEIGHT) data:dataArray];
    __weak typeof(self) weakSelfReference = self;
    self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
        [weakSelfReference.popoverView dismiss];
        if (indexRow == 2) {//已收消息
            weakSelfReference.tabBarController.selectedIndex = 1;
            UINavigationController *nav = (UINavigationController *)weakSelfReference.tabBarController.selectedViewController;
            if ([nav isKindOfClass:[UINavigationController class]]) {
                [nav popToRootViewControllerAnimated:NO];
            }
        } else if (indexRow == 1) {//发布消息
            XWHMessageSendingViewController *sendingVC = [[XWHMessageSendingViewController alloc] init];
            [weakSelfReference.navigationController pushViewController:sendingVC animated:YES];
        } else if (indexRow == 0) {//删除消息
            [weakSelfReference.mTableView setEditing:YES animated:YES];
            weakSelfReference.tableViewBottomConstraint.constant = 88;
            weakSelfReference.bottomView.hidden = NO;
        }
    };
}

- (void)setNavExtraBarItem
{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 32);
    [searchBtn setImage:[UIImage imageNamed:@"nav_search_normal"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"nav_search_selected"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(searchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30, 32);
    [moreBtn setImage:[UIImage imageNamed:@"nav_more_normal"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"nav_more_selected"] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreBarItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    self.navigationItem.rightBarButtonItems = @[moreBarItem, searchBarItem];
}

- (void)searchBtnAction:(id)sender
{
    if (self.searchPopView == nil) {
        self.searchPopView = [[[NSBundle mainBundle] loadNibNamed:@"XWHMessageSearchView" owner:nil options:nil] firstObject];
    }
    __weak typeof (self) weakSelfRefrence = self;
    self.searchPopView.handler = ^(NSInteger index){
        if (index == -2) {
            [weakSelfRefrence searhAction];
        }
    };
    if ([self.tabBarController.view.subviews containsObject:self.searchPopView]) {
        [self.searchPopView hide];
    } else {
        [self.tabBarController.view addSubview:self.searchPopView];
        [self.searchPopView show];
    }
}

- (void)moreBtnAction:(id)sender
{
    UIButton *btn = sender;
    CGPoint startPoint = CGPointMake(CGRectGetMidX(btn.frame), CGRectGetMaxY(btn.frame)+20);
    [self.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popoverContentView inView:self.tabBarController.view];
    self.popoverView.cornerRadius = 3.0f;
}

#pragma mark - UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XWHMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageListCell" forIndexPath:indexPath];
    
    XWHMessageReceiveListModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHMessageSendListModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    XWHMessageDetailViewController *detailVC = [[XWHMessageDetailViewController alloc] init];
    detailVC.type = SENT_MESSAGE;
    detailVC.messageId = model.messageRemindId;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)getSearchDataWithIndexPage:(NSInteger)page
{
    [self progressHUDShowWithTitle:@"正在加载..."];
    
    [[XWHHttpClient sharedInstance] searchSentMessageWithStartDate:self.startDate endDate:self.endDate keyWord:self.keyWords criteria:self.criteria page:page completeHandler:^(NetworkResult networkResult, NSArray *array, NSInteger totalCount) {
        [self progressHUDHide:YES];
        if (networkResult == NetworkResultSuccess) {
            if (array.count != 0) {
                if (page == 1) {
                    self.currentNumber = 1;
                    [self.dataArray removeAllObjects];
                }
                [self.dataArray addObjectsFromArray:array];
                [self.mTableView reloadData];
                self.mTableView.hidden = NO;
                [self.refreshFooter endRefreshing];
                [self.refreshHeader endRefreshing];
            } else {
                if (page == 1) {
                    self.mTableView.hidden = YES;
                }
            }
            if (self.dataArray.count < totalCount) {
                [self addFooter];
            } else {
                self.refreshFooter.hidden = YES;
            }
        } else {
                    
        }
    }];
}

- (void)addHeader
{
    if (self.refreshHeader) {
        self.refreshHeader.hidden = NO;
        return;
    }
    __weak typeof(self) weakSelfReference = self;
    RefreshHeaderView *header = [RefreshHeaderView headerWithTotalCount:0];
    header.scrollView = self.mTableView;
    header.beginRefreshingBlock = ^(RefreshBaseView *refreshView) {
        weakSelfReference.refreshViewType = RefreshViewTypeHeader;
        [self getSearchDataWithIndexPage:1];
    };
    header.endStateChangeBlock = ^(RefreshBaseView *refreshView) {
        [self.mTableView reloadData];
    };
    self.refreshHeader = header;
}

- (void)addFooter
{
    if (self.refreshFooter) {
        self.refreshFooter.hidden = NO;
        return;
    }
    __weak typeof(self) weakSelfReference = self;
    RefreshFooterView *footer = [RefreshFooterView footerWithTotalCount:0];
    footer.scrollView = self.mTableView;
    footer.beginRefreshingBlock = ^(RefreshBaseView *refreshView) {
        weakSelfReference.refreshViewType = RefreshViewTypeFooter;
        self.currentNumber += 1;
        [self getSearchDataWithIndexPage:self.currentNumber];
    };
    footer.endStateChangeBlock = ^(RefreshBaseView *refreshView) {
        [self.mTableView reloadData];
    };
    self.refreshFooter = footer;
}

- (void)searhAction
{
    self.keyWords = self.searchPopView.searchTextFiled.text;
    self.startDate = self.searchPopView.startDate.text;
    self.endDate = self.searchPopView.endDate.text;
    [self.searchPopView hide];
    [self getSearchDataWithIndexPage:1];
}

- (IBAction)cancelAction:(id)sender {
    
    [self.mTableView setEditing:NO animated:YES];
    self.tableViewBottomConstraint.constant = 8;
    self.bottomView.hidden = YES;
}

- (IBAction)confirmAction:(id)sender {
    
    NSArray *selectedRows = [self.mTableView indexPathsForSelectedRows];
    if (selectedRows == nil || selectedRows.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择要删除的消息！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除消息吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 110;
        [alertView show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 110) {
        if (buttonIndex == 1) {
            [self deleteMessage];
        }
    }
}

- (void)deleteMessage
{
    NSArray *selectedRows = [self.mTableView indexPathsForSelectedRows];
    NSMutableArray *array = [NSMutableArray array];
    for (NSIndexPath *indexPath in selectedRows) {
        XWHMessageSendListModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [array addObject:[NSNumber numberWithInteger:model.messageRemindId]];
    }
    [self progressHUDShowWithTitle:@"删除中..."];
    [[XWHHttpClient sharedInstance] deleteSendMessageByIdArray:array completeHandler:^(NetworkResult networkResult, NSInteger renMsg) {
        if (networkResult == NetworkResultSuccess) {
            if (renMsg == 9) {
                [self progressHUDCompleteHide:YES afterDelay:2 title:@"删除成功!"];
                NSMutableArray *tempArray = [NSMutableArray array];
                for (NSIndexPath *indexPath in selectedRows) {
                    [tempArray addObject:[self.dataArray objectAtIndex:indexPath.row]];
                }
                for (id obj in tempArray) {
                    if ([self.dataArray containsObject:obj]) {
                        [self.dataArray removeObject:obj];
                    }
                }
                [self.mTableView reloadData];
            } else {
                [self progressHUDHide:YES];
            }
        } else {
            [self progressHUDHide:YES];
            [self showNetWorkError:networkResult];
        }
    }];
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
