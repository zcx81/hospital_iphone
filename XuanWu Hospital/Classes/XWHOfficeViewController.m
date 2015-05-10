//
//  XWHOfficeViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/11.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHOfficeViewController.h"
#import "XWHDBManage.h"
#import "XWHOfficeModel.h"

#define CELLIDENTIFY @"officeCell"
NSString * const noPeopleDepartment = @"职能部门;临床科室;医技科室;其他科室;科研科室;下属单位";

@interface XWHOfficeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *officeArray;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation XWHOfficeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavTitle:@"科室"];
    [self setNavBackBtn];
    
    self.officeArray = [[XWHDBManage sharedInstance] getAllOffice];
    [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELLIDENTIFY];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBgStyle2];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.officeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    XWHOfficeModel *model = [self.officeArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.officeName;
    if ([noPeopleDepartment rangeOfString:model.officeName].location != NSNotFound) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XWHUserListViewController *userlistVC = [[XWHUserListViewController alloc] init];
    XWHOfficeModel *model = [self.officeArray objectAtIndex:indexPath.row];
    userlistVC.officeId = model.officeId;
    userlistVC.selectedType = self.selectedType;
    [self.navigationController pushViewController:userlistVC animated:YES];
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
