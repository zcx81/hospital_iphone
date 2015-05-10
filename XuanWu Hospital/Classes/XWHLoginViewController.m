//
//  XWHLoginViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/30.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHLoginViewController.h"
#import "XWHCustomTabBarViewController.h"
#import "XWHMessageListViewController.h"
#import "XWHWorkFlowViewController.h"
#import "XWHBulletinViewController.h"
#import "XWHMainPageViewController.h"
#import "AppDelegate.h"
#import "XWHDBManage.h"

@interface XWHLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *loginTitlelb;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation XWHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"nav_bg"];
    UIImage *stretchedImage = [image stretchableImageWithLeftCapWidth:1 topCapHeight:5];
    [self.navigationController.navigationBar setBackgroundImage:stretchedImage forBarMetrics:UIBarMetricsDefault];
    
    self.loginTitlelb.textColor = RED_COLOR;
    
    UIImage *btnBgImg = [UIImage imageNamed:@"loginbutton_bg"];
    [self.loginBtn setBackgroundImage:[btnBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:RED_COLOR forState:UIControlStateNormal];
    
    self.userNameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.userNameTextField.layer.borderWidth = 1.0f;
    self.userNameTextField.layer.cornerRadius = 8.0f;
    
    self.passWordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.passWordTextField.layer.borderWidth = 1.0f;
    self.passWordTextField.layer.cornerRadius = 8.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userNameTextField.text = @"";
    self.passWordTextField.text = @"";
    
//    self.userNameTextField.text = @"admin";
//    self.passWordTextField.text = @"111111";
    
//    self.userNameTextField.text = @"test001";
//    self.passWordTextField.text = @"111111";
    
//    self.userNameTextField.text = @"admin";
//    self.passWordTextField.text = @"xwyyoa123";
    
//    self.userNameTextField.text = @"test16";
//    self.passWordTextField.text = @"111111";

}

- (IBAction)loginBtnAction:(id)sender {
    
    if (self.userNameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else if (self.passWordTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [self login];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.userNameTextField resignFirstResponder];
        [self.passWordTextField resignFirstResponder];
    }
}

- (void)login
{
    [self progressHUDShowWithTitle:@"正在登录..."];
    [[XWHHttpClient sharedInstance] loginWithUserName:self.userNameTextField.text password:self.passWordTextField.text completeHandler:^(NetworkResult networkResult, NSInteger status) {
        [self progressHUDHide:YES];
        if (networkResult == NetworkResultSuccess) {
            if (status == 2) {
                [XWHAppConfiguration sharedConfiguration].loginName = self.userNameTextField.text;
                [XWHAppConfiguration sharedConfiguration].loginPassword = self.passWordTextField.text;
                [[XWHHttpClient sharedInstance] getBulletinKind:^(NetworkResult networkResult, NSArray *array) {
                    NSLog(@"更新公告类型成功");
                }];
                //更新人员信息
                [[XWHHttpClient sharedInstance] updatePeopleDataComplete:^(NetworkResult networkResult, NSString *updateSql, NSString *dateTime) {
                    if (updateSql != nil && updateSql.length != 0) {
                        [[XWHDBManage sharedInstance] updateDataWithSql:updateSql andDate:dateTime];
                    }
                }];
                [self pushNewViewController];
            } else if (status == 5) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账户不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            } else if (status == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"口令错误，请重新输入！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络链接异常,请重试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)pushNewViewController
{
    XWHCustomTabBarViewController *tabBarViewController = [[XWHCustomTabBarViewController alloc] init];
    
    XWHMainPageViewController *mainPageVC = [[XWHMainPageViewController alloc] init];
    XWHMessageListViewController *messageVC = [[XWHMessageListViewController alloc] init];
    XWHWorkFlowViewController *workFlowVC = [[XWHWorkFlowViewController alloc] init];
    XWHBulletinViewController *bulletinVC = [[XWHBulletinViewController alloc] init];
    bulletinVC.pageType = GONGGAO;
    
    NSArray *views = @[mainPageVC, messageVC, workFlowVC, bulletinVC];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (UIViewController *viewController in views) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [viewControllers addObject:nav];
    }
    tabBarViewController.viewControllers = viewControllers;
    tabBarViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).tabBarViewController = tabBarViewController;
    
    [self presentViewController:tabBarViewController animated:YES completion:nil];
}

#pragma markt UITextField delegate method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.passWordTextField && self.userNameTextField.text.length == 0) {
        self.passWordTextField.returnKeyType = UIReturnKeyNext;
    } else {
        self.passWordTextField.returnKeyType = UIReturnKeyGo;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.userNameTextField) {
        [self.passWordTextField becomeFirstResponder];
    } else if (textField == self.passWordTextField)
    {
        if ([self.userNameTextField.text length] > 0)
        {
            [self login];
        } else {
            [self.userNameTextField becomeFirstResponder];
        }
    }
    return YES;
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
