//
//  XWHUserListViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/11.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHUserListViewController.h"
#import "XWHDBManage.h"
#import "XWHUserModel.h"

#define CELLIDENTIFY @"userCell"

@interface XWHUserListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation XWHUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavTitle:@"科室人员"];
    [self setNavBackBtn];
    
    self.selectedArray = [NSMutableArray array];
    self.dataArray = [[XWHDBManage sharedInstance] getUserByOfficeId:self.officeId];
    [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELLIDENTIFY];
    if (self.selectedType == singleSelected) {
        self.mTableView.allowsMultipleSelection = NO;
    } else {
        self.mTableView.allowsMultipleSelection = YES;
    }
    
    [self setBtnImage:self.backBtn];
    [self setBtnImage:self.okBtn];
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xuankuang"]];
    imageView.highlightedImage = [UIImage imageNamed:@"xuankuang_selected"];
    cell.accessoryView = imageView;
    XWHUserModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.userName;
    if ([self.selectedArray containsObject:model]) {
        imageView.highlighted = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    XWHUserModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if ([cell.accessoryView isKindOfClass:[UIImageView class]]) {
        ((UIImageView *)cell.accessoryView).highlighted = YES;
    }
    if (![self.selectedArray containsObject:model]) {
        [self.selectedArray addObject:model];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    XWHUserModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if ([cell.accessoryView isKindOfClass:[UIImageView class]]) {
        ((UIImageView *)cell.accessoryView).highlighted = NO;
    }
    if ([self.selectedArray containsObject:model]) {
        [self.selectedArray removeObject:model];
    }
}

- (UIImageView *)setAccessoryViewSelected:(BOOL)flag
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    if (flag) {
        imageView.image = [UIImage imageNamed:@"xuankxuankuang_selected"];
    } else {
        imageView.image = [UIImage imageNamed:@"xuankuang"];
    }
    return imageView;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
//    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
//    if ([vc isKindOfClass:NSClassFromString(@"XWHMessageSendingViewController")]) {
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
//    }
    NSInteger count = self.navigationController.viewControllers.count;
    if (count > 2) {
      [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-3] animated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedPeople" object:nil userInfo:@{@"people":self.selectedArray}];
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
