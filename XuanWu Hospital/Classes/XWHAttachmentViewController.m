//
//  XWHAttachmentViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/28.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHAttachmentViewController.h"

@interface XWHAttachmentViewController ()

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) NSMutableArray *filesNameArray;

@end

@implementation XWHAttachmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavBgStyle2];
    [self setNavTitle:@"列表"];
    [self setNavBackBtn];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    NSString *path = [[XWHAppConfiguration sharedConfiguration] getAttachmentDirectory];
    
    NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    self.filesNameArray = [NSMutableArray arrayWithCapacity:filesArray.count];
    for (NSString *name in filesArray) {
        if (![name isEqualToString:@".DS_Store"]) {
            [self.filesNameArray addObject:name];
        }
    }
    
    [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fileCell"];
    [self.mTableView setEditing:YES];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmAction:(id)sender {
    NSArray *selectedRows = [self.mTableView indexPathsForSelectedRows];
    NSMutableArray *fileNamesArray = [NSMutableArray arrayWithCapacity:selectedRows.count];
    for (NSIndexPath *indexPath in selectedRows) {
        [fileNamesArray addObject:[self.filesNameArray objectAtIndex:indexPath.row]];
    }
    self.handler(fileNamesArray);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filesNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.filesNameArray objectAtIndex:indexPath.row];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
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
