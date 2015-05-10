//
//  XWHWorkFlowViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/9.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHWorkFlowViewController.h"
#import "XWHWorkFlowBigModel.h"
#import "XWHSmallWorkFlowViewController.h"

#define CELLIDENTIFY @"workFlowCell"

@interface XWHWorkFlowViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation XWHWorkFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavBgStyle2];
    [self setNavTitle:@"流程管理"];
    [self setNavBackBtn];
    
    self.dataArray = [NSMutableArray array];
    [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELLIDENTIFY];
    self.mTableView.hidden = YES;
    [self progressHUDShowWithTitle:@"正在加载..."];
    [[XWHHttpClient sharedInstance] getAllWorkFlowHandler:^(NetworkResult networkResult, NSInteger rtnMsg, NSArray *array) {
        [self progressHUDHide:YES];
        if (networkResult == NetworkResultSuccess) {
            if (rtnMsg == 1) {
                [self.dataArray addObjectsFromArray:array];
                [self removeOtherWorkFlow];
                [self.mTableView reloadData];
                self.mTableView.hidden = NO;
            }
        }
    }];
}

- (void)removeOtherWorkFlow
{
    NSArray *workFlowId = @[@"164", @"163", @"195", @"191", @"160", @"186", @"196", @"211", @"201", @"162", @"151", @"149", @"185", @"159", @"203", @"199", @"187", @"158", @"161", @"183",
                            @"182", @"148", @"213", @"212", @"197", @"215", @"202", @"207"];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *workId in workFlowId) {
        for (XWHWorkFlowBigModel *model in self.dataArray) {
            if (model.workFlowId == [workId integerValue]) {
                [temp addObject:model];
            }
        }
    }
    NSMutableArray *removeArray = [NSMutableArray array];
    for (XWHWorkFlowBigModel *model in temp) {
        if ((model.workFlowId == 160 || model.workFlowId == 186) && [model.officeName isEqualToString:@"党委办公室"]) {
            [removeArray addObject:model];
        }
    }
    for (id obj in removeArray) {
        if ([temp containsObject:obj]) {
            [temp removeObject:obj];
        }
    }
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:temp];
}

#pragma mark - UITableViewDelegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"workFlow"];
    XWHWorkFlowBigModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.workFlowName;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHSmallWorkFlowViewController *smallVC = [[XWHSmallWorkFlowViewController alloc] init];
    XWHWorkFlowBigModel *model = [self.dataArray objectAtIndex:indexPath.row];
    smallVC.bigModel = model;
    [self.navigationController pushViewController:smallVC animated:YES];
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
