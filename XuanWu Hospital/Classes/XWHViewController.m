//
//  XWHViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/11/30.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHViewController.h"
#import "MBProgressHUD.h"

@interface XWHViewController ()

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation XWHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavBgStyle1
{
    UIImage *image = [UIImage imageNamed:@"nav_bg"];
    UIImage *stretchedImage = [image stretchableImageWithLeftCapWidth:1 topCapHeight:5];
    [self.navigationController.navigationBar setBackgroundImage:stretchedImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setNavBgStyle2
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_redBg"] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.translucent = YES;
}

- (void)setNavTitle:(NSString *)title
{
//    CGFloat margin = 100;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
//    titleLabel.backgroundColor = [UIColor yellowColor];
    self.navigationItem.titleView = titleLabel;
}

- (void)setNavBackBtn
{
    if (self.navigationController != nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 24)];
        UIButton *backButon = [UIButton buttonWithType:UIButtonTypeCustom];
        backButon.frame = view.bounds;
        [backButon setImage:[UIImage imageNamed:@"nav_backArrow_normal"] forState:UIControlStateNormal];
        [backButon setImage:[UIImage imageNamed:@"nav_backArrow_selected"] forState:UIControlStateHighlighted];
        [backButon addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:backButon];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:view];
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

- (void)backButtonAction:(id)sender
{
    UINavigationController *nav = [self.tabBarController.viewControllers firstObject];
    if (nav.viewControllers.count > 1) {
        [nav popToRootViewControllerAnimated:YES];
    }
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - MBProgressHUD method

- (MBProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_progressHUD];
    } else {
        [self.view bringSubviewToFront:_progressHUD];
    }
    return _progressHUD;
}

- (void)progressHUDCompleteHide:(BOOL)animated afterDelay:(NSTimeInterval)delay title:(NSString *)title
{
    self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.progressHUD.labelText = title;
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    [self.progressHUD show:YES];
    [self.progressHUD hide:animated afterDelay:delay];
}

- (void)progressHUDSHowTitle:(NSString *)title afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = title;
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:delay];
}

- (void)progressHUDShowWithTitle:(NSString *)title
{
    self.progressHUD.labelText = title;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
}

- (void)progressHUDHide:(BOOL)animated
{
    [self.progressHUD hide:animated];
}

- (void)progressHUDShowwithProgressTitle:(NSString *)title
{
    self.progressHUD.labelText = title;
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    [self.progressHUD show:YES];
}

- (void)setProgressHUDPercent:(CGFloat)percent
{
    self.progressHUD.progress = percent;
}

- (void)showNetWorkError:(NetworkResult)result
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络链接异常,请重试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)setBtnImage:(UIButton *)btn
{
    UIImage *normal_img = [UIImage imageNamed:@"xw_button_bg_normal"];
    normal_img = [normal_img stretchableImageWithLeftCapWidth:floorf(normal_img.size.width/2) topCapHeight:floorf(normal_img.size.height/2)];
    [btn setBackgroundImage:normal_img forState:UIControlStateNormal];
    
    UIImage *pressed_img = [UIImage imageNamed:@"xw_button_bg_pressed"];
    pressed_img = [pressed_img stretchableImageWithLeftCapWidth:floorf(pressed_img.size.width/2) topCapHeight:floorf(pressed_img.size.height/2)];
    [btn setBackgroundImage:pressed_img forState:UIControlStateHighlighted];
    
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
