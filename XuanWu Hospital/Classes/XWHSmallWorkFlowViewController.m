//
//  XWHSmallWorkFlowViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/11.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSmallWorkFlowViewController.h"
#import "RefreshFooterView.h"
#import "RefreshHeaderView.h"
#import "XWHSmallWorkFlowCell.h"
#import "XWHWorkFlowSearchView.h"
#import "DXPopover.h"
#import "XWHPopoverContentView.h"
#import "XWHProcessStatus.h"
#import "XWHProcessSearchItems.h"
#import "XWHUserModel.h"
#import "XWHWorkFlowDetailViewController.h"
#import "XWHOfficeViewController.h"

#define CELLIDENTIFY @"smallWorkFlowCell"

@interface XWHSmallWorkFlowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *topTitlelb;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) NSDictionary *parsDic;
@property (strong, nonatomic) RefreshHeaderView *refreshHeader;
@property (strong, nonatomic) RefreshFooterView *refreshFooter;
@property (assign, nonatomic) RefreshViewType refreshViewType;
@property (strong, nonatomic) XWHWorkFlowSearchView *searchPopView;
@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;
@property (strong, nonatomic) NSArray *statusArray;
@property (strong, nonatomic) NSString *namePars;
@property (strong, nonatomic) NSString *minDatePars;
@property (strong, nonatomic) NSString *maxDatePars;
@property (strong, nonatomic) XWHProcessStatus *selectedStatus;
@property (strong, nonatomic) XWHUserModel *selectedPeople;

@property (assign, nonatomic) NSInteger currentPage;

@end

@implementation XWHSmallWorkFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavBgStyle2];
    [self setNavTitle:@"流程列表"];
    [self setNavBackBtn];
    [self setNavExtraBarItem];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.topTitlelb.text = self.bigModel.workFlowName;
    self.dataArray = [NSMutableArray array];
    
    [self.mTableView registerNib:[UINib nibWithNibName:@"XWHSmallWorkFlowCell" bundle:nil] forCellReuseIdentifier:CELLIDENTIFY];
    [self addHeader];
    self.currentPage = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPeople:) name:@"selectedPeople" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"PISHISUCCESS" object:nil];
    
    self.popoverView = [[DXPopover alloc] init];
    
    [self getSearchDataWithIndexPage:1];
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
        self.searchPopView = [[[NSBundle mainBundle] loadNibNamed:@"XWHWorkFlowSearchView" owner:nil options:nil] firstObject];
    }
    __weak typeof (self) weakSelfRefrence = self;
    self.searchPopView.handler = ^(NSInteger index){
        if (index == -2) {
            [weakSelfRefrence.searchPopView hide];
            [weakSelfRefrence searhAction];
        } else if (index == -3) {// add people
            XWHOfficeViewController *officeVC = [[XWHOfficeViewController alloc] init];
            officeVC.selectedType = singleSelected;
            [weakSelfRefrence.navigationController pushViewController:officeVC animated:YES];
        } else if (index == -1) {
            [weakSelfRefrence.searchPopView.searchTextFiled resignFirstResponder];
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

#pragma mark - UITableView delegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XWHSmallWorkFlowCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    XWHWorkFlowSmallModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setData:model];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 1.0f;
    UILabel *sqrlb = [self createLabelWithFrame:CGRectMake(0, -1, 79, 31)];
    sqrlb.text = @"申请人";
    UILabel *datelb = [self createLabelWithFrame:CGRectMake(78, -1, 89, 31)];
    datelb.text = @"申请时间";
    UILabel *statuslb = [self createLabelWithFrame:CGRectMake(166, -1, 160, 31)];
    statuslb.text = @"流程状态";
    [view addSubview:sqrlb];
    [view addSubview:datelb];
    [view addSubview:statuslb];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHWorkFlowSmallModel *model = [self.dataArray objectAtIndex:indexPath.row];
    XWHWorkFlowDetailViewController *detailVC = [[XWHWorkFlowDetailViewController alloc] init];
    detailVC.smallModel = model;
    detailVC.bigModel = self.bigModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)getSearchDataWithIndexPage:(NSInteger)page
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self progressHUDShowWithTitle:@"正在加载...."];
    [[XWHHttpClient sharedInstance] getSmallWorkFLowById:self.bigModel.workFlowId page:page dynamicParameter:self.parsDic completeHandler:^(NetworkResult networkResult, NSString *rtnMsg, NSArray *cellTitleArray, NSArray *processStatus, NSArray *searchItems, NSArray *data, NSInteger totalCount) {
        [self progressHUDHide:YES];
        if (networkResult == NetworkResultSuccess) {
            if (self.statusArray == nil && processStatus != nil) {
                self.statusArray = processStatus;
                for (XWHProcessSearchItems *item in searchItems) {
                    if (item.itemTypeId == 11) {
                        self.namePars = item.itemId;
                    } else if (item.itemTypeId == 13) {
                        self.minDatePars = item.minItemId;
                        self.maxDatePars = item.maxItemId;
                    }
                }
            }
            if (data.count != 0) {
                if (page == 1) {
                    self.currentPage = 1;
                    [self.dataArray removeAllObjects];
                }
                [self.dataArray addObjectsFromArray:data];
                [self.mTableView reloadData];
                self.mTableView.hidden = NO;
                [self.refreshFooter endRefreshing];
                [self.refreshHeader endRefreshing];
            } else {
                if (page == 1) {
                    self.mTableView.hidden = YES;
                }
                
                [self progressHUDSHowTitle:@"无数据" afterDelay:1.0f];
            }
            if (self.dataArray.count < totalCount) {
                [self addFooter];
            } else {
                self.refreshFooter.hidden = YES;
            }
        } else {
            
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
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
        self.currentPage += 1;
        [self getSearchDataWithIndexPage:self.currentPage];
    };
    footer.endStateChangeBlock = ^(RefreshBaseView *refreshView) {
        [self.mTableView reloadData];
    };
    self.refreshFooter = footer;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame
{
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.font = [UIFont systemFontOfSize:14];
    lb.layer.borderColor = [UIColor grayColor].CGColor;
    lb.layer.borderWidth = 1.0f;
    lb.textAlignment = NSTextAlignmentCenter;
    return lb;
}

- (void)searhAction
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.namePars != nil && self.namePars.length != 0 && self.selectedPeople != nil)
    {
        if ([self.selectedPeople.userName isEqualToString:self.searchPopView.searchTextFiled.text]) {
            [dic setObject:[NSString stringWithFormat:@"%ld", self.selectedPeople.userId] forKey:self.namePars]; 
        }
    }
    if (self.minDatePars != nil && self.minDatePars.length != 0 && self.searchPopView.startDate.text != nil && self.searchPopView.startDate.text.length != 0) {
        [dic setObject:self.searchPopView.startDate.text forKey:self.minDatePars];
    }
    if (self.maxDatePars != nil && self.maxDatePars.length != 0 && self.searchPopView.endDate.text != nil && self.searchPopView.endDate.text.length != 0) {
        [dic setObject:self.searchPopView.endDate.text forKey:self.maxDatePars];
    }
    if (self.selectedStatus != nil) {
        [dic setObject:[NSNumber numberWithInteger:self.selectedStatus.activityId] forKey:@"activityId"];
    }
    self.parsDic = dic;
    [self getSearchDataWithIndexPage:1];
}

- (void)getPeople:(NSNotification *)notification
{
    NSArray *array = [[notification userInfo] objectForKey:@"people"];
    XWHUserModel *user = [array firstObject];
    if (user != nil) {
        self.searchPopView.searchTextFiled.text = user.userName;
        self.selectedPeople = user;
    }
}

- (void)showPopUpView
{
    if (self.popoverContentView == nil && self.statusArray != nil) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.statusArray];
        XWHProcessStatus *obj1 = [[XWHProcessStatus alloc] init];
        obj1.activityId = 0;
        obj1.activityName = @"全部";
        XWHProcessStatus *obj2 = [[XWHProcessStatus alloc] init];
        obj2.activityId = -1;
        obj2.activityName = @"已完成";
        [array insertObject:obj1 atIndex:0];
        [array addObject:obj2];
        
        self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 160, array.count *POPOVER_CELL_HEIGHT) data:array];
        __weak typeof(self) weakSelfReference = self;
        self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
            if ([data isKindOfClass:[XWHProcessStatus class]]) {
                weakSelfReference.selectedStatus = data;
                weakSelfReference.searchPopView.statusLabel.text = weakSelfReference.selectedStatus.activityName;
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
    [self getSearchDataWithIndexPage:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedPeople" object:nil];
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
