//
//  XWHGongShiViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/4.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHGongShiViewController.h"
#import "RefreshFooterView.h"
#import "RefreshHeaderView.h"
#import "XWHBulletinTableViewCell.h"
#import "XWHBulletinTypeModel.h"
#import "XWHBulletinDetailViewController.h"
#import "DXPopover.h"
#import "XWHPopoverContentView.h"
#import "XWHSearchPopView.h"
#import "XWHDBManage.h"
#import "XWHBulletinSendViewController.h"

@interface XWHGongShiViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSString *startDateStr;
@property (strong, nonatomic) NSString *endDateStr;
@property (strong, nonatomic) NSString *keyWords;
@property (strong, nonatomic) NSString *criteria;
@property (strong, nonatomic) XWHBulletinTypeModel *selectedType;

@property (strong, nonatomic) RefreshHeaderView *refreshHeader;
@property (strong, nonatomic) RefreshFooterView *refreshFooter;
@property (assign, nonatomic) RefreshViewType refreshViewType;
@property (strong, nonatomic) DXPopover *popoverView;
@property (strong, nonatomic) XWHPopoverContentView *popoverContentView;

@property (assign, nonatomic) NSInteger currentNumber;
@property (strong, nonatomic) XWHSearchPopView *searchPopView;

@end

@implementation XWHGongShiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavBgStyle2];
    [self setNavTitle:@"公示列表"];
    [self setNavBackBtn];
    [self setNavExtraBarItem];
    
    self.dataArray = [NSMutableArray array];
    
    [self.mTableView registerNib:[UINib nibWithNibName:@"XWHBulletinTableViewCell" bundle:nil] forCellReuseIdentifier:@"BulletinListCell"];
    self.mTableView.hidden = YES;
    [self addHeader];
    self.currentNumber = 1;
    [self getSearchDataWithIndexPage:1];
    
    self.popoverView = [[DXPopover alloc] init];
    self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    NSArray *dataArray = @[@"发布公示"];
    self.popoverContentView = [[XWHPopoverContentView alloc] initWithFrame:CGRectMake(0, 0, 120, dataArray.count * POPOVER_CELL_HEIGHT) data:dataArray];
    __weak typeof(self) weakSelfReference = self;
    self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
        [weakSelfReference.popoverView dismiss];
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
        self.searchPopView = [[[NSBundle mainBundle] loadNibNamed:@"XWHSearchPopView" owner:nil options:nil] firstObject];
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[XWHDBManage sharedInstance] getAllBulletinType]];
    XWHBulletinTypeModel *model = [[XWHBulletinTypeModel alloc] init];
    model.typeName = @"全部类型";
    model.typeId = 0;
    [array insertObject:model atIndex:0];
    __weak typeof (self) weakRefSelf = self;
    self.searchPopView.handler = ^(NSInteger index){
        if (index == -1) { // popup
            [weakRefSelf.popoverContentView setData:array];
            
            UIImageView *view = weakRefSelf.searchPopView.criteriaImgView;
            CGPoint startPoint = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMaxY(view.frame)+60);
            [weakRefSelf.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:weakRefSelf.popoverContentView inView:weakRefSelf.tabBarController.view];
            weakRefSelf.popoverView.cornerRadius = 3.0f;
        } else if (index == -2) {// search
            [weakRefSelf searhAction];
        }
    };
    self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
        if ([data isKindOfClass:[XWHBulletinTypeModel class]]) {
            XWHBulletinTypeModel *model = data;
            weakRefSelf.searchPopView.kindLabel.text = model.typeName;
            weakRefSelf.selectedType = model;
        }
        [weakRefSelf.popoverView dismiss];
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
    [self.popoverContentView setData:@[@"发布公示"]];
    [self.popoverView showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popoverContentView inView:self.tabBarController.view];
    self.popoverView.cornerRadius = 3.0f;
    __weak typeof(self) weakSelfReference = self;
    self.popoverContentView.cellSelectHandler = ^(NSInteger indexRow, id data) {
        XWHBulletinSendViewController *sendVC = [[XWHBulletinSendViewController alloc] init];
        sendVC.pageType = GONGSHI;
        [weakSelfReference.navigationController pushViewController:sendVC animated:YES];
        [weakSelfReference.popoverView dismiss];
    };
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
    XWHBulletinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BulletinListCell" forIndexPath:indexPath];
    
    XWHBulletinModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHBulletinModel *model = [self.dataArray objectAtIndex:indexPath.row];
    XWHBulletinDetailViewController *detailVC = [[XWHBulletinDetailViewController alloc] init];
    detailVC.type = GONGSHI;
    detailVC.bulletinId = model.bulletinId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)getSearchDataWithIndexPage:(NSInteger)page
{
    [self progressHUDShowWithTitle:@"正在加载..."];
    [[XWHHttpClient sharedInstance] searchBulletinWithStartDate:self.startDateStr endDate:self.endDateStr keyWord:self.keyWords criteria:self.criteria kindId:self.selectedType==nil?0:self.selectedType.typeId page:page type:GONGSHI completeHandler:^(NetworkResult networkResult, NSArray *array, NSInteger totalCount) {
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
    self.criteria = @"主题";
    self.startDateStr = self.searchPopView.startDate.text;
    self.endDateStr = self.searchPopView.endDate.text;
    [self.searchPopView hide];
    [self getSearchDataWithIndexPage:1];
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
