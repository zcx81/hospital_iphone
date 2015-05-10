//
//  XWHSmallScheduleViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/19.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSmallScheduleViewController.h"
#import "RefreshFooterView.h"
#import "RefreshHeaderView.h"
#import "XWHWorkFlowDetailViewController.h"
#import "XWHSmallScheduleSearcView.h"
#import "DXPopover.h"
#import "XWHPopoverContentView.h"
#import "XWSmallScheduleTableViewCell.h"

#define CELLIDENTIFY @"smallScheduleCell"

@interface XWHSmallScheduleViewController ()

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (assign, nonatomic) NSInteger currentPage;

@property (strong, nonatomic) RefreshHeaderView *refreshHeader;
@property (strong, nonatomic) RefreshFooterView *refreshFooter;
@property (assign, nonatomic) RefreshViewType refreshViewType;

@property (strong, nonatomic) XWHDaiBanBigModel *selectedScheduleModel;

@property (strong, nonatomic) XWHSmallScheduleSearcView *searchPopView;
@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;

@end

@implementation XWHSmallScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavBgStyle2];
    [self setNavTitle:@"待办事宜"];
    [self setNavBackBtn];
    [self setNavExtraBarItem];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.selectedScheduleModel = self.bigModel;
    self.dataArray = [NSMutableArray array];
    
    [self addHeader];
    self.currentPage = 1;
    
    self.mTableView.hidden = YES;
    
    [self.mTableView registerNib:[UINib nibWithNibName:@"XWSmallScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:CELLIDENTIFY];
    
    self.popoverView = [[DXPopover alloc] init];
    [self getSearchDataWithIndexPage:1 andWorkFlowId:self.bigModel.procdefId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"PISHISUCCESS" object:nil];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavExtraBarItem
{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 32);
    [searchBtn setImage:[UIImage imageNamed:@"nav_search_normal"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"nav_search_selected"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(searchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    self.navigationItem.rightBarButtonItem = searchBarItem;
}

- (void)searchBtnAction:(id)sender
{
    if (self.searchPopView == nil) {
        self.searchPopView = [[[NSBundle mainBundle] loadNibNamed:@"XWHSmallScheduleSearcView" owner:nil options:nil] firstObject];
    }
    
    self.searchPopView.statusLabel.text = self.selectedScheduleModel.procdefName;
    __weak typeof (self) weakSelfRefrence = self;
    self.searchPopView.handler = ^(NSInteger index){
        if (index == -2) {
            [weakSelfRefrence.searchPopView hide];
            [weakSelfRefrence getSearchDataWithIndexPage:1 andWorkFlowId:weakSelfRefrence.selectedScheduleModel.procdefId];
        } else if (index == -1) {
            [weakSelfRefrence showPopUpView];
        }
    };
    if ([self.view.subviews containsObject:self.searchPopView]) {
        [self.searchPopView hide];
    } else {
        [self.view addSubview:self.searchPopView];
        [self.searchPopView show];
    }
}

- (void)getSearchDataWithIndexPage:(NSInteger)page andWorkFlowId:(NSInteger)workId
{
    [self progressHUDShowWithTitle:@"正在加载...."];
    
    [[XWHHttpClient sharedInstance] getSMallWaiteFlowById:workId page:page completeHandler:^(NetworkResult networkResult, NSString *rtnMsg, NSArray *array, NSInteger totalCount) {
        [self progressHUDHide:YES];
        if (networkResult == NetworkResultSuccess) {
            if (array.count != 0) {
                if (page == 1) {
                    self.currentPage = 1;
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
            [self showNetWorkError:networkResult];
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
        [self getSearchDataWithIndexPage:1 andWorkFlowId:self.selectedScheduleModel.procdefId];
        
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
        self.currentPage += 1;
        [self getSearchDataWithIndexPage:self.currentPage andWorkFlowId:self.selectedScheduleModel.procdefId];
    };
    footer.endStateChangeBlock = ^(RefreshBaseView *refreshView) {
        [self.mTableView reloadData];
    };
    self.refreshFooter = footer;
}

#pragma mark - UITableView delegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XWSmallScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    XWHSmallScheduleModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHSmallScheduleModel *model = [self.dataArray objectAtIndex:indexPath.row];
    XWHWorkFlowDetailViewController *detailVC = [[XWHWorkFlowDetailViewController alloc] init];
    XWHWorkFlowSmallModel *smallModel = [[XWHWorkFlowSmallModel alloc] init];
    smallModel.processId = model.process_id;
    smallModel.activityId = model.activityId;
    smallModel.isCanBanli = YES;
    detailVC.smallModel = smallModel;
    
    XWHWorkFlowBigModel *workBigModel = [[XWHWorkFlowBigModel alloc] init];
    workBigModel.workFlowId = self.bigModel.procdefId;
    workBigModel.workFlowName = self.bigModel.procdefName;
    detailVC.bigModel = workBigModel;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)showPopUpView
{
    if (self.popoverContentView == nil && self.kindArray != nil) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.kindArray];
        
        XWHDaiBanBigModel *model = [[XWHDaiBanBigModel alloc] init];
        model.procdefId = 0;
        model.procdefName = @"全部类型";
        [array insertObject:model atIndex:0];
        
        self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 160, array.count *POPOVER_CELL_HEIGHT)];
        [self.popoverContentView setData:array];
        
        __weak typeof(self) weakSelfReference = self;
        self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
            if ([data isKindOfClass:[XWHDaiBanBigModel class]]) {
                weakSelfReference.selectedScheduleModel = data;
                weakSelfReference.searchPopView.statusLabel.text = weakSelfReference.selectedScheduleModel.procdefName;
            }
            [weakSelfReference.popoverView dismiss];
        };
    }
    
    if (self.popoverContentView) {
        UIImageView *view = self.searchPopView.criteriaImgView;
        CGPoint startPoint = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMaxY(view.frame)+60);
        [self.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popoverContentView inView:self.tabBarController.view];
        self.popoverView.cornerRadius = 3.0f;
    }
}

- (void)updateData
{
    [self getSearchDataWithIndexPage:1 andWorkFlowId:self.bigModel.procdefId];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PISHISUCCESS" object:nil];
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
