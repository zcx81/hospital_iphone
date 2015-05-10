//
//  XWHCustomTabBarViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/9.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHCustomTabBarViewController.h"
#define BOTTOM_VIEW_HEIGHT 57

@interface XWHCustomTabBarViewController () <UIAlertViewDelegate>

//@property (strong, nonatomic) UIImageView *bottomImageView;

@end

@implementation XWHCustomTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBar.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTabBarView];
}

#pragma mark - Create TabBar view

- (void)createTabBarView
{
    UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-BOTTOM_VIEW_HEIGHT, CGRectGetWidth(self.view.bounds), BOTTOM_VIEW_HEIGHT)];
    bottomImageView.image = [UIImage imageNamed:@"tabBar_bg"];
    bottomImageView.userInteractionEnabled = YES;
    [self.view addSubview:bottomImageView];
    
    NSArray *buttonNormalImg = @[@"tab_message_normal", @"tab_workFlow_normal", @"tab_bulletin_notmal", @"tab_logout_normal"];
    NSArray *buttonSelectedImg = @[@"tab_message_selected", @"tab_workFlow_selected", @"tab_bulletin_selected", @"tab_logout_selected"];
    
    CGFloat margin = 20;
    CGFloat imageHeight = 35;
    CGFloat imageWidth = 50;
    CGFloat space = (CGRectGetWidth(self.view.bounds) - 2*margin - imageWidth*4)/3;
    
    for (NSInteger index = 0; index < 4; index++) {
        NSString *normalImg = buttonNormalImg[index];
        NSString *selectedImg = buttonSelectedImg[index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index + 1;
        button.frame = CGRectMake(margin + (imageWidth+space)*index, (BOTTOM_VIEW_HEIGHT-imageHeight)/2.0, imageWidth, imageHeight);
        [button setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateHighlighted];
        if (index == 3) {
            [button addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        }
        [bottomImageView addSubview:button];
    }
}

#pragma mark - bottom button aciton

- (void)selectedTab:(UIButton *)button
{
    self.selectedIndex = button.tag;
    UINavigationController *nav = (UINavigationController *)self.selectedViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        [nav popToRootViewControllerAnimated:NO];
    }
}

- (void)logoutAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出当前登录账号吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    alertView.tag = 100;
    [alertView show];
}

#pragma mark - UIAlertView delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)setSelectedKind:(TabBarSelectedKind)selectedKind
{
    
    if (selectedKind == SelectedLogout) {
        [self logoutAction];
    } else {
        self.oldSelectedKind = _selectedKind;
        _selectedKind = selectedKind;
        self.selectedIndex = selectedKind;
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
