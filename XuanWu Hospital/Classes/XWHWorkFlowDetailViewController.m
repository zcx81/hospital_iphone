//
//  XWHWorkFlowDetailViewController.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/12.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHWorkFlowDetailViewController.h"
#import "XWHLabel.h"
#import "XWHWorkFlowRecord.h"
#import "XWHProcessDetailAgreeItem.h"
#import "XWHPiShiView.h"
#import "MultiChooseView.h"
#import "SingleChooseView.h"

#define CELLHEIGHT 32
#define LEFT_MARGIN 8
#define FONTSIZE 13

@interface XWHWorkFlowDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIButton *pishiBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (strong, nonatomic) NSDictionary *parsDictionary;
@property (strong, nonatomic) UIView *detailView;
@property (assign, nonatomic) CGFloat detailHeight;
@property (strong, nonatomic) UIView *pishiView;
@property (assign, nonatomic) CGFloat pishiViewHeight;

@property (strong, nonatomic) XWHPiShiView *psView;
@property (nonatomic, assign, readwrite, getter=isRegisteredNotificationObserver) BOOL registeredNotificationObserver;
@property (strong, nonatomic) NSString *monthParId;
@property (strong, nonatomic) NSString *dayParId;
@property (strong, nonatomic) NSString *numberParId;

@property (assign, nonatomic) BOOL monthCanEdit;
@property (assign, nonatomic) BOOL dayCanEdit;
@property (assign, nonatomic) BOOL numberCanEdit;

@property (strong, nonatomic) NSMutableArray *ghParArray;
@property (strong, nonatomic) UIView *extraViewForPS;
@property (strong, nonatomic) NSMutableDictionary *extraParmDic;

@property (strong, nonatomic) NSString *barParId;

@end

@implementation XWHWorkFlowDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavBgStyle2];
    [self setNavTitle:@"流程详情"];
    [self setNavBackBtn];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topLabel.textColor = [UIColor colorWithRed:230/255.0 green:0 blue:10/255.0 alpha:1.0];
//    if (self.bigModel.officeName != nil || self.bigModel.officeName.length != 0) {
//        self.topLabel.text = [NSString stringWithFormat:@"[%@]%@",self.bigModel.officeName,self.bigModel.workFlowName];
//    } else {
//        self.topLabel.text = [NSString stringWithFormat:@"%@",self.bigModel.workFlowName];
//    }
    self.topLabel.text = [NSString stringWithFormat:@"%@",self.bigModel.workFlowName];
    self.detailBtn.selected = YES;
    self.detailBtn.backgroundColor = [UIColor redColor];
    self.detailView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.detailView];
    self.scrollView.hidden = YES;
    [self progressHUDShowWithTitle:@"正在加载..."];
    if (self.smallModel.isCanBanli == NO) { //look
        [[XWHHttpClient sharedInstance] getSmallWorkFlowDetailById:self.smallModel.processId isFinish:@"S" completeHandler:^(NetworkResult networkResult, NSString *rtnMsg, NSDictionary *formData, NSArray *recordArray) {
            [self progressHUDHide:YES];
            if (networkResult == NetworkResultSuccess) {
                if (recordArray != nil) {
                    [self createPishiView:recordArray showInput:NO item:nil];
                }
                if (formData != nil) {
                     //add anchang 返回数据不是dic时，转换为dic
                    if ( [formData isKindOfClass:[NSDictionary class]] || [formData isKindOfClass:[NSMutableDictionary class]] ) {
                        [self setFormData:formData];
                    }else{
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:formData,@"otherOBJ", nil];
                        [self setFormData:dic];
                    }
                    
                    self.scrollView.hidden = NO;
                }
            }
        }];
    } else { //办理
        [[XWHHttpClient sharedInstance] getSmallWorkFlowDetailById:self.smallModel.processId isFinish:@"S" activityId:self.smallModel.activityId completeHandler:^(NetworkResult networkResult, NSString *rtnMsg, NSDictionary *formData, NSArray *recordArray, NSDictionary *dictionary, NSArray *agreeItems) {
            [self progressHUDHide:YES];
            if (networkResult == NetworkResultSuccess) {
                if ([rtnMsg isEqualToString:@"SUCCESS"]) {
                    if (recordArray != nil) {
                        [self createPishiView:recordArray showInput:YES item:agreeItems];
                    }
                    if (formData != nil) {
                        self.scrollView.hidden = NO;
                        //add anchang 返回数据不是dic时，转换为dic
                        if ( [formData isKindOfClass:[NSDictionary class]] || [formData isKindOfClass:[NSMutableDictionary class]] ) {
                            [self setFormData:formData];
                        }else{
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:formData,@"otherOBJ", nil];
                            [self setFormData:dic];
                        }
                    }
                    self.parsDictionary = dictionary;
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:rtnMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                [self showNetWorkError:networkResult];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifcations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self deregisterNotifcations];
}

- (void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)detailAction:(id)sender {
    UIButton *btn = sender;
    if (btn.selected == NO) {
        btn.selected = YES;
        btn.backgroundColor = [UIColor redColor];
        self.pishiBtn.selected = NO;
        self.pishiBtn.backgroundColor = [UIColor lightGrayColor];
        self.detailView.hidden = NO;
        self.pishiView.hidden = YES;
        [self.psView.textView resignFirstResponder];
        [self updateScrollViewContentSize:self.detailHeight];
    }
}

- (IBAction)pishiAction:(id)sender {
    UIButton *btn = sender;
    if (btn.selected == NO) {
        btn.selected = YES;
        btn.backgroundColor = [UIColor redColor];
        self.detailBtn.selected = NO;
        self.detailBtn.backgroundColor = [UIColor lightGrayColor];
        self.detailView.hidden = YES;
        self.pishiView.hidden = NO;
        [self updateScrollViewContentSize:self.pishiViewHeight];
    }
}

- (void)setFormData:(NSDictionary *)formData
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:formData
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSLog(@"____________jsonString = %@",jsonString);
    NSMutableDictionary *diction = [[NSMutableDictionary alloc ] initWithDictionary:formData];
    if (self.bigModel.workFlowId == 185 || self.bigModel.workFlowId == 159) {//科主任出国申请, 正式在编职工出国申请
        if(!self.smallModel.isCanBanli) {
            NSString *month = [diction objectForKey:@"备注月"];
            if (month == nil || month.length == 0) {
                month = @" ";
            }
            NSString *day = [diction objectForKey:@"备注日"];
            if (day == nil || day.length == 0) {
                day = @" ";
            }
            NSString *number = [diction objectForKey:@"备注房间号"];
            if (number == nil || number.length == 0) {
                number = @" ";
            }
            NSString *key = @"备注";
            NSString *value = [NSString stringWithFormat:@"%@月%@日到人事处%@房间办理手续",month, day, number];
            [diction removeObjectForKey:@"备注月"];
            [diction removeObjectForKey:@"备注日"];
            [diction removeObjectForKey:@"备注房间号"];
            [diction setObject:value forKey:key];
        } else {
            NSDictionary *month = [[diction objectForKey:@"备注月"] firstObject];
            NSDictionary *day = [[diction objectForKey:@"备注日"] firstObject];
            NSDictionary *number = [[diction objectForKey:@"备注房间号"] firstObject];
//            [self setMonth:month day:day number:number];
            
            NSString *monthStr = [month objectForKey:@"item_id_value"];
            NSString *dayStr = [day objectForKey:@"item_id_value"];
            NSString *numberStr = [number objectForKey:@"item_id_value"];
        
            
            if ([[month objectForKey:@"ifReadOnly"] isEqualToString:@"true"] && [[day objectForKey:@"ifReadOnly"] isEqualToString:@"true"] && [[number objectForKey:@"ifReadOnly"] isEqualToString:@"true"]) {

                if (monthStr == nil || monthStr.length == 0) {
                    monthStr = @" ";
                }
                if (dayStr == nil || dayStr.length == 0) {
                    dayStr = @" ";
                }
                if (numberStr == nil || numberStr.length == 0) {
                    numberStr = @" ";
                }
                NSString *key = @"备注";
                NSString *value = [NSString stringWithFormat:@"%@月%@日到人事处%@房间办理手续",monthStr, dayStr, numberStr];
                [diction setObject:value forKey:key];
                
            } else {
                
                self.psView.monthTextField.text = monthStr;
                self.psView.dayTextField.text = dayStr;
                self.psView.numberTextField.text = numberStr;
                
                self.psView.monthTextField.enabled = YES;
                self.monthCanEdit = YES;
                self.monthParId = [month objectForKey:@"item_id"];
                
                self.psView.dayTextField.enabled = YES;
                self.dayCanEdit = YES;
                self.dayParId = [day objectForKey:@"item_id"];
                
                self.psView.numberTextField.enabled = YES;
                self.numberCanEdit = YES;
                self.numberParId = [number objectForKey:@"item_id"];
                self.psView.dateView.hidden = NO;
                self.psView.textViewTopConstraint.constant = 34;
    
                self.pishiViewHeight += CGRectGetHeight(self.psView.dateView.frame);
            }
        }
    } else if (self.bigModel.workFlowId == 187) {//首次开通HIS系统权限申请单（执业护士）
        NSArray *array = [diction objectForKey:@"人员"];
        NSMutableString *allStr = [[NSMutableString alloc] init];
        NSString *symbol = @"";
        if (!self.smallModel.isCanBanli) {
            for (NSDictionary *temp in array) {
                NSString *name = [temp objectForKey:@"姓名"];
                NSString *zyzsbm = [temp objectForKey:@"执业证书编码"];
                NSString *gh = [temp objectForKey:@"工号"];
                NSString *ywxt = [temp objectForKey:@"业务系统"];
//                if ((name == nil || name.length == 0) && (zyzsbm == nil || zyzsbm.length == 0) && (gh == nil || gh.length == 0) && (ywxt == nil || ywxt.length == 0 || [ywxt stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)) {
//                }
                if (name == nil || name.length == 0 || [name stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
                    
                } else {
                    NSString *tempStr = [NSString stringWithFormat:@"姓名:%@ 职业证书编号:%@ 工号:%@ 业务系统:%@", name, zyzsbm, gh, ywxt];
                    [allStr appendString:symbol];
                    [allStr appendString:tempStr];
                    symbol = @"\n";
                }
            }
            [diction setObject:allStr forKey:@"人员"];
        } else {
            NSMutableArray *nameArray = [NSMutableArray array];
            for (NSDictionary *temp in array) {
                NSString *name = [temp objectForKey:@"姓名"];
                NSString *zyzsbm = [temp objectForKey:@"执业证书编码"];
                NSDictionary *ghDic = [[temp objectForKey:@"工号"] firstObject];
                NSString *gh = [ghDic objectForKey:@"item_id_value"];
                NSString *ywxt = [temp objectForKey:@"业务系统"];
                if (name == nil || name.length == 0 || [name stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
                    
                } else {
                    NSString *tempStr = [NSString stringWithFormat:@"姓名:%@ 职业证书编号:%@ 工号:%@ 业务系统:%@", name, zyzsbm, gh, ywxt];
                    [allStr appendString:symbol];
                    [allStr appendString:tempStr];
                    symbol = @"\n";
                    
                    BOOL flag = [[ghDic objectForKey:@"ifReadOnly"] isEqualToString:@"true"];
                    if (!flag && name != nil) {
                        [nameArray addObject:name];
                        NSString *parmId = [ghDic objectForKey:@"item_id"];
                        [self.ghParArray addObject:parmId];
                    }
                }
            }
            if (nameArray.count != 0) {
                [self createGHWithArray:nameArray];
            }
            [diction setObject:allStr forKey:@"人员"];
        }
    } else if (self.bigModel.workFlowId == 199) {//首次开通HIS系统权限申请单（执业医师）
        NSString *mzysz = [diction objectForKey:@"门诊医生站出诊科室"];
        NSString *jzysz = [diction objectForKey:@"急诊医生站出诊科室"];
        NSString *smxt = [diction objectForKey:@"麻方权"];
        if (smxt != nil && [smxt isKindOfClass:[NSString class]] && [smxt isEqualToString:@"有"]) {
            smxt = @"麻方权（有）";
            [diction setObject:smxt forKeyedSubscript:@"手麻系统"];
        }
        if (mzysz != nil) {
            [diction setObject:mzysz forKey:@"门诊医生站"];
        }
        if (jzysz != nil) {
            [diction setObject:jzysz forKey:@"急诊医生站"];
        }
    } else if (self.bigModel.workFlowId == 183) {//血源性病原体职业暴露处理
        
    } else if (self.bigModel.workFlowId == 186) {//实验室加班申请
        NSArray *array = [diction objectForKey:@"加班人员"];
        NSMutableString *allStr = [[NSMutableString alloc] init];
        NSString *symbol = @"";
        for (NSDictionary *temp in array) {
            NSString *name = [temp objectForKey:@"姓名"];
            NSString *sfzh = [temp objectForKey:@"身份证号"];
            NSString *jbdd = [temp objectForKey:@"加班地点"];
            NSString *lxfs = [temp objectForKey:@"联系方式"];
            if ((name == nil || name.length == 0) && (sfzh == nil || sfzh.length == 0) && (jbdd == nil || jbdd.length == 0) && (lxfs == nil || lxfs.length == 0)) {
            } else {
                NSString *tempStr = [NSString stringWithFormat:@"姓名:%@ 身份证号:%@ 加班地点:%@ 联系方式:%@", name, sfzh, jbdd, lxfs];
                [allStr appendString:symbol];
                [allStr appendString:tempStr];
                symbol = @"\n";
            }
        }
        [diction setObject:allStr forKey:@"加班人员"];
    } else if (self.bigModel.workFlowId == 151) {//打印申请
        NSArray *array = [diction objectForKey:@"项目"];
        NSMutableString *allStr = [[NSMutableString alloc] init];
        NSString *symbol = @"";
        for (NSDictionary *temp in array) {
            NSString *name = [temp objectForKey:@"名称"];
            NSString *number = [temp objectForKey:@"数量"];
            NSString *zzdx = [temp objectForKey:@"纸张大小"];
            if (number == nil || number.length == 0) {
            } else {
                NSString *tempStr = [NSString stringWithFormat:@"名称:%@ 数量:%@ 纸张大小:%@", name, number, zzdx];
                [allStr appendString:symbol];
                [allStr appendString:tempStr];
                symbol = @"\n";
            }
        }
        [diction setObject:allStr forKey:@"项目"];
    } else if (self.bigModel.workFlowId == 149) {//刻字申请
        NSArray *array = [diction objectForKey:@"项目"];
        NSMutableString *allStr = [[NSMutableString alloc] init];
        NSString *symbol = @"";
        for (NSDictionary *temp in array) {
            NSString *name = [temp objectForKey:@"名称"];
            NSString *number = [temp objectForKey:@"数量"];
            NSString *place = [temp objectForKey:@"使用地点"];
            NSString *date = [temp objectForKey:@"使用时间"];
            if (number == nil || number.length == 0) {
            } else {
                NSString *tempStr = [NSString stringWithFormat:@"名称:%@ 数量:%@ 使用地点:%@ 使用时间:%@", name, number, place, date];
                [allStr appendString:symbol];
                [allStr appendString:tempStr];
                symbol = @"\n";
            }
        }
        [diction setObject:allStr forKey:@"项目"];
    } else if (self.bigModel.workFlowId == 164) {//科主任请假申请
        if(!self.smallModel.isCanBanli) {
            id number = [diction objectForKey:@"备案人"];
            if ([number isKindOfClass:[NSString class]]) {
                NSInteger index = [number integerValue];
                if (index == 1) {
                    [diction setObject:@"医务处" forKey:@"备案人"];
                } else if (index == 2) {
                    [diction setObject:@"门诊部" forKey:@"备案人"];
                } else if (index == 3) {
                    [diction setObject:@"不备案" forKey:@"备案人"];
                }
            }
        } else {
            NSDictionary *dictionary = [[formData objectForKey:@"option"] firstObject];
            if (dictionary != nil) {
                NSString *name = [dictionary objectForKey:@"item_name"];
                NSString *value = [dictionary objectForKey:@"item_id_value"];
                NSString *readOnly = [dictionary objectForKey:@"ifReadOnly"];
                if ([readOnly isEqualToString:@"true"] && name != nil) {
                    [diction setObject:value forKey:name];
                } else {
                    self.barParId = [dictionary objectForKey:@"item_id"];
                    [self createBARView:dictionary];
                }
            }
        }
    } else if (self.bigModel.workFlowId == 182) {//职能部门用印申请
        int y=0;
        NSArray *array = [diction objectForKey:@"otherOBJ"];
        for(int i=0 ; i<[array count] ;i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            NSString *key = [dic objectForKey:@"input_name"];
            NSString *value = [dic objectForKey:@"input_value"];
            if ([value isKindOfClass:[NSString class]]) {
                UIView *v = [self createViewWithKey:key andValue:value];
                v.frame = CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(v.frame), CGRectGetHeight(v.frame));
                [self.detailView addSubview:v];
                y += CGRectGetHeight(v.frame) + 2;
                //多选
                if ( [[dic objectForKey:@"input_type"] isEqualToString:@"checkbox"] ) {
                    NSArray *array = [dic objectForKey:@"options"];
                    MultiChooseView *view = [[MultiChooseView alloc] init];
                    view.infoArray = array;
                    view.frame = CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(self.scrollView.frame) - 2*LEFT_MARGIN, CGRectGetHeight(view.frame));
                    [self.detailView addSubview:view];
                    y += CGRectGetHeight(view.frame) + 2;
                }
                //单选
                if ( [[dic objectForKey:@"input_type"] isEqualToString:@"radio"] ) {
                    NSArray *array = [dic objectForKey:@"options"];
                    SingleChooseView *view = [[SingleChooseView alloc] init];
                    view.infoArray = array;
                    view.frame = CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(self.scrollView.frame) - 2*LEFT_MARGIN, CGRectGetHeight(view.frame));
                    [self.detailView addSubview:view];
                    y += CGRectGetHeight(view.frame) + 2;
                }
            }
        }
        self.detailHeight = y;
        [self updateScrollViewContentSize:self.detailHeight];
        return ;
    }
    
    CGFloat y = 0;
    NSArray *keyArray = [self workFlowKeys:self.bigModel.workFlowId];
//    if ( self.bigModel.workFlowId == 182 ) {
//        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
//       
//    }
    for (NSString *key in keyArray) {
        NSString *value = [diction objectForKey:key];
        if (self.bigModel.workFlowId == 160) {//门禁卡申请、补办
            if ([key rangeOfString:@"办卡人姓名"].location != NSNotFound || [key rangeOfString:@"办卡人所在部门"].location != NSNotFound) {
                if ([value isKindOfClass:[NSString class]] && value.length == 0) {
                    continue;
                }
            }
        } else if (self.bigModel.workFlowId == 199) {//首次开通HIS系统权限申请单（执业医师）
            if ([key isEqualToString:@"申请开放权限"]) {
                XWHLabel *keylb = [[XWHLabel alloc] initWithFrame: CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(self.scrollView.frame) - 2*LEFT_MARGIN, CELLHEIGHT)];
                keylb.font = [UIFont boldSystemFontOfSize:FONTSIZE];
                keylb.backgroundColor = [UIColor lightGrayColor];
                keylb.text = key;
                keylb.numberOfLines = 0;
                keylb.textAlignment = NSTextAlignmentCenter;
                [self.detailView addSubview:keylb];
                y += (CELLHEIGHT+2);
                
                XWHLabel *key2lb = [[XWHLabel alloc] initWithFrame: CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(keylb.frame)/3.0, CELLHEIGHT)];
                key2lb.font = [UIFont boldSystemFontOfSize:FONTSIZE];
                key2lb.backgroundColor = [UIColor lightGrayColor];
                key2lb.text = @"权限";
                key2lb.numberOfLines = 0;
                key2lb.textAlignment = NSTextAlignmentRight;
                [self.detailView addSubview:key2lb];
                
                CGRect oldValueFrame = CGRectMake(key2lb.frame.origin.x + CGRectGetWidth(key2lb.frame) + 1, y, keylb.frame.size.width - key2lb.frame.size.width - 1, CELLHEIGHT);
                XWHLabel *valuelb = [[XWHLabel alloc] initWithFrame: oldValueFrame];
                valuelb.font = [UIFont boldSystemFontOfSize:FONTSIZE];;
                valuelb.backgroundColor = [UIColor lightGrayColor];
                valuelb.text = @"门诊科室";
                valuelb.numberOfLines = 0;
                valuelb.textAlignment = NSTextAlignmentLeft;
                [self.detailView addSubview:valuelb];
                
                y += (CELLHEIGHT+2);
                continue;
            }
        }
        if ([value isKindOfClass:[NSString class]]) {
            UIView *v = [self createViewWithKey:key andValue:value];
            v.frame = CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(v.frame), CGRectGetHeight(v.frame));
            [self.detailView addSubview:v];
            y += CGRectGetHeight(v.frame) + 2;
        }
    }
    self.detailHeight = y;
    [self updateScrollViewContentSize:self.detailHeight];
}

- (UIView *)createViewWithKey:(NSString *)key andValue:(NSString *)value
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, CGRectGetWidth(self.scrollView.frame) - 2*LEFT_MARGIN, CELLHEIGHT)];
    CGRect oldKeyFrame = CGRectMake(0, 0, CGRectGetWidth(v.frame)/3.0, CELLHEIGHT);
    XWHLabel *keylb = [[XWHLabel alloc] initWithFrame: oldKeyFrame];
    keylb.font = [UIFont boldSystemFontOfSize:FONTSIZE];
    keylb.backgroundColor = [UIColor lightGrayColor];
    keylb.text = [key stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    keylb.numberOfLines = 0;
    keylb.textAlignment = NSTextAlignmentRight;
    [v addSubview:keylb];
    
    CGRect newKeyFrame = [key boundingRectWithSize:CGSizeMake(keylb.frame.size.width, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:keylb.font} context:nil];
    CGRect newValueFrame = CGRectZero;
    
    CGRect oldValueFrame = CGRectMake(keylb.frame.origin.x + CGRectGetWidth(keylb.frame) + 1, 0, v.frame.size.width - keylb.frame.size.width - 1, CELLHEIGHT);
    
    UIView *valueView = nil;
    UIFont *font = [UIFont systemFontOfSize:FONTSIZE];
    if (self.bigModel.workFlowId == 183 && [key isEqualToString:@"暴露类型"]) {
        UITextView *textView = [[UITextView alloc] initWithFrame:oldValueFrame];
        textView.font = font;
        textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [v addSubview:textView];
        CGFloat height = [self setBllxText:value view:textView];
        newKeyFrame = CGRectMake(0, 0, CGRectGetWidth(textView.frame), height);
        valueView = textView;
    } else if ((self.bigModel.workFlowId == 151 || self.bigModel.workFlowId == 149) && [key isEqualToString:@"项目"]) {//151打印申请 149 刻章申请
        UITextView *textView = [[UITextView alloc] initWithFrame:oldValueFrame];
        textView.font = font;
        textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [v addSubview:textView];
        CGFloat height = [self setTextViewText:value view:textView];
        newKeyFrame = CGRectMake(0, 0, CGRectGetWidth(textView.frame), height);
        valueView = textView;
    } else if (self.bigModel.workFlowId == 187 && [key isEqualToString:@"人员"]) {//执业护士
        UITextView *textView = [[UITextView alloc] initWithFrame:oldValueFrame];
        textView.font = font;
        textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [v addSubview:textView];
        CGFloat height = [self setTextViewText:value view:textView];
        newKeyFrame = CGRectMake(0, 0, CGRectGetWidth(textView.frame), height);
        valueView = textView;
    } else {
        XWHLabel *valuelb = [[XWHLabel alloc] initWithFrame: oldValueFrame];
        valuelb.font = font;
        valuelb.backgroundColor = [UIColor groupTableViewBackgroundColor];
        valuelb.text = [value stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        valuelb.numberOfLines = 0;
        valuelb.textAlignment = NSTextAlignmentLeft;
        [v addSubview:valuelb];
        valueView = valuelb;
        newValueFrame = [value boundingRectWithSize:CGSizeMake(valueView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    }
    
    CGFloat height = CELLHEIGHT;
    if (newKeyFrame.size.height > height) {
        height = newKeyFrame.size.height;
    }
    if (newValueFrame.size.height > height) {
        height = newValueFrame.size.height;
    }
    if (height != CELLHEIGHT) {
        height += 4;
        oldKeyFrame.size.height = height;
        oldValueFrame.size.height = height;
        keylb.frame = oldKeyFrame;
        valueView.frame = oldValueFrame;
        CGRect frame = v.frame;
        frame.size.height = height;
        v.frame = frame;
    }
    return v;
}


- (void)updateScrollViewContentSize:(CGFloat)height
{
    if (height > self.scrollView.contentSize.height) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), height);
    } else {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    }
}

- (void)createPishiView:(NSArray *)array showInput:(BOOL)flag item:(NSArray *)agreeItems
{
    self.pishiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), 0)];
    self.pishiView.hidden = YES;
    [self.scrollView addSubview:self.pishiView];
    CGFloat y = 0;
    if (array != nil && array.count != 0) {
        for (XWHWorkFlowRecord *record in array) {
            UIView *v = [self createRecordView:record];
            v.frame = CGRectMake(LEFT_MARGIN, y, CGRectGetWidth(v.frame), CGRectGetHeight(v.frame));
            y += CGRectGetHeight(v.frame) + 2;
            [self.pishiView addSubview:v];
        }
    }
    if (flag) {
        self.psView = [[[NSBundle mainBundle] loadNibNamed:@"XWHPiShiView" owner:nil options:nil] firstObject];
        __weak typeof (self) weakSelfReference = self;
        self.psView.callBack = ^(NSInteger index) {
            if (index == 1) {// submit
                [weakSelfReference submitAction];
            } else if (index == 2) {// back
                [weakSelfReference backButtonAction:nil];
            }
        };
        self.psView.frame = CGRectMake(0, y, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.psView.frame));
        CGRect frame = self.pishiView.frame;
        frame.size.height = y + CGRectGetHeight(self.psView.frame);
        self.pishiView.frame = frame;
        
        [self.pishiView addSubview:self.psView];
        
        if (agreeItems != nil && agreeItems.count != 0) {
            for (NSInteger index = 0; index < agreeItems.count; index++) {
                XWHProcessDetailAgreeItem *item = [agreeItems objectAtIndex:index];
                if (index == 0) {
                    self.psView.agreeLabel.text = item.agreeItemText;
                    self.psView.agreeBtn.tag = item.agreeId;
                    self.psView.agreeBtn.hidden = NO;
                    self.psView.agreeLabel.hidden = NO;
                } else {
                    self.psView.disagreeLabel.text = item.agreeItemText;
                    self.psView.disAgreeBtn.tag = item.agreeId;
                    self.psView.disAgreeBtn.hidden = NO;
                    self.psView.disagreeLabel.hidden = NO;
                }
            }
            self.psView.agreeBtn.selected = YES;
        }
    }
    y += CGRectGetHeight(self.psView.frame);
    self.pishiViewHeight = y;
    [self updateScrollViewContentSize:y];
}

- (UIView *)createRecordView:(XWHWorkFlowRecord *)record
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, CGRectGetWidth(self.scrollView.frame) - 2*LEFT_MARGIN, 0)];
    v.backgroundColor = LINECOLOR;
    
    UIFont *font = [UIFont systemFontOfSize:13];
    CGFloat lbHeight = 15;
    CGFloat leftMargin = 4; //左间距
    CGFloat topMargin = 4; //顶部间距
    CGFloat margin = 4; //两行之前的间距
    
    UILabel *datelb = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, 50, lbHeight)];
    datelb.font = font;
    datelb.text = record.executeTime;
    [datelb sizeToFit];
    [v addSubview:datelb];
    
    CGFloat status_x = datelb.frame.origin.x + CGRectGetWidth(datelb.frame) + 4;
    UILabel *statuslb = [[UILabel alloc] initWithFrame:CGRectMake(status_x, topMargin, CGRectGetWidth(v.frame) - status_x - 4, CGRectGetHeight(datelb.frame))];
    statuslb.font = font;
    statuslb.text = record.taskName;
    [v addSubview:statuslb];
    
    UILabel *ownerNamelb = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, datelb.frame.origin.y + CGRectGetHeight(datelb.frame) + margin, 100, lbHeight)];
    ownerNamelb.font = font;
    ownerNamelb.text = record.ownerName;
    [ownerNamelb sizeToFit];
    [v addSubview:ownerNamelb];
    
    UILabel *phlb = [[UILabel alloc] initWithFrame:CGRectMake(ownerNamelb.frame.origin.x + CGRectGetWidth(ownerNamelb.frame) + 10, ownerNamelb.frame.origin.y, 100, lbHeight)];
    phlb.font = font;
    phlb.text = record.agreeNameRecord;
    [phlb sizeToFit];
    [v addSubview:phlb];
    
    CGFloat height = CGRectGetHeight(ownerNamelb.frame);
    if (record.attTextRecord != nil && record.attTextRecord.length != 0) {
        CGFloat argue_x = phlb.frame.origin.x + CGRectGetWidth(phlb.frame) + 4;
        CGFloat argue_width = CGRectGetWidth(v.frame) - argue_x - 4;
        CGRect rect = [record.attTextRecord boundingRectWithSize:CGSizeMake(argue_width, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        if (CGRectGetHeight(rect) > height) {
            height = CGRectGetHeight(rect);
        }
        UILabel *arguelb = [[UILabel alloc] initWithFrame:CGRectMake(argue_x, phlb.frame.origin.y, argue_width, height)];
        arguelb.font = font;
        arguelb.numberOfLines = 0;
        arguelb.textColor = [UIColor redColor];
        arguelb.text = record.attTextRecord;
        [v addSubview:arguelb];
    }
    
    CGRect frame = v.frame;
    frame.size.height = ownerNamelb.frame.origin.y + height + topMargin;
    v.frame = frame;
    
    return v;
}

- (void)submitAction
{
    if (self.psView.agreeBtn.selected || self.psView.disAgreeBtn.selected) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.parsDictionary];
        [dict setObject:@"1" forKey:@"commit_flag"];
        [dict setObject:self.psView.textView.text forKey:@"attText"];
        if (self.psView.agreeBtn.selected) {
            [dict setObject:[NSNumber numberWithInteger:self.psView.agreeBtn.tag] forKey:@"agreeId"];
        } else {
            [dict setObject:[NSNumber numberWithInteger:self.psView.disAgreeBtn.tag] forKey:@"agreeId"];
        }
        
        if (self.monthCanEdit) {
            if (self.psView.monthTextField.text.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"日期不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if (self.monthParId != nil && self.monthParId.length != 0) {
                [dict setObject:self.psView.monthTextField.text forKey:self.monthParId];
            }
        }
        if (self.dayCanEdit) {
            if (self.psView.dayTextField.text.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"日期不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if (self.dayParId != nil && self.dayParId.length != 0) {
                [dict setObject:self.psView.dayTextField.text forKey:self.dayParId];
            }
        }
        if (self.numberCanEdit) {
            if (self.psView.numberTextField.text.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"房间号不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if (self.numberParId != nil && self.numberParId.length != 0) {
                [dict setObject:self.psView.numberTextField.text forKey:self.numberParId];
            }
        }
        if (self.barParId != nil && self.extraParmDic.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择备案人!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        if (self.extraParmDic != nil && self.extraParmDic.count != 0) {
            [dict addEntriesFromDictionary:self.extraParmDic];
        }
        
        [self progressHUDShowWithTitle:@"正在提交..."];
        [[XWHHttpClient sharedInstance] postExecuteWorkFlow:dict completer:^(NetworkResult networkResult, NSString *rtnMsg) {
            if (networkResult == NetworkResultSuccess) {
                if ([rtnMsg isEqualToString:@"EXECUTESUCCESS"]) {
                    [self progressHUDCompleteHide:YES afterDelay:1.0f title:@"成功!"];
                    [self.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PISHISUCCESS" object:nil userInfo:nil];
                } else {
                    [self progressHUDHide:YES];
                }
            } else {
                [self progressHUDHide:YES];
                [self showNetWorkError:networkResult];
            }
        }];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择是否同意!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - NotificationCenter

- (void)registerNotifcations
{
    if (!self.isRegisteredNotificationObserver)
    {
        self.registeredNotificationObserver = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)deregisterNotifcations
{
    if (self.isRegisteredNotificationObserver)
    {
        self.registeredNotificationObserver = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
}

#pragma mark - Keyboard

- (void)willShowKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.0
                        options:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                     animations:^(void) {
                         self.scrollViewBottomConstraint.constant = 138;
                     }
                     completion:NULL];
}

- (void)willHideKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.0
                        options:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                     animations:^(void) {
                         self.scrollViewBottomConstraint.constant = 58;
                     }
                     completion:NULL];
}

- (void)setMonth:(NSDictionary *)month day:(NSDictionary *)day number:(NSDictionary *)number
{
    self.dayParId = [day objectForKey:@"item_id"];
    self.monthParId = [month objectForKey:@"item_id"];
    self.numberParId = [number objectForKey:@"item_id"];
    
    self.psView.monthTextField.text = [month objectForKey:@"item_id_value"];
    self.psView.dayTextField.text = [day objectForKey:@"item_id_value"];
    self.psView.numberTextField.text = [number objectForKey:@"item_id_value"];
    
    if ([[month objectForKey:@"ifReadOnly"] isEqualToString:@"true"]) {
        self.psView.monthTextField.enabled = NO;
    } else {
        self.psView.monthTextField.enabled = YES;
        self.monthCanEdit = YES;
    }
    if ([[day objectForKey:@"ifReadOnly"] isEqualToString:@"true"]) {
        self.psView.dayTextField.enabled = NO;
    } else {
        self.psView.dayTextField.enabled = YES;
        self.dayCanEdit = YES;
    }
    if ([[number objectForKey:@"ifReadOnly"] isEqualToString:@"true"]) {
        self.psView.numberTextField.enabled = NO;
    } else {
        self.psView.numberTextField.enabled = YES;
        self.numberCanEdit = YES;
    }
    self.psView.dateView.hidden = NO;
    self.psView.textViewTopConstraint.constant = 34;
    
    self.pishiViewHeight += CGRectGetHeight(self.psView.dateView.frame);
}

- (NSString *)setTextViewValue:(NSString *)value
{
    if (value != nil && value.length != 0) {
        NSMutableAttributedString *allAttriStr = [[NSMutableAttributedString alloc] init];
        CGFloat height = 0;
        if ([value rangeOfString:@"锐器伤"].location != NSNotFound) {
            NSAttributedString *rqsKey = [[NSAttributedString alloc] initWithString:@"锐器伤:\n" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[UIColor redColor]}];
            [allAttriStr appendAttributedString:rqsKey];
            NSAttributedString *rqsValue = [[NSAttributedString alloc] initWithString:@"①尽可能挤出伤口处血液（从近心端向远心端挤血， 不要挤压伤口处）\n②流动水充分冲洗\n③0.5%碘伏或75%乙醇消毒伤口\n④若伤口创面较大，可采用3％过氧化氢冲洗或擦拭伤口3～5min。\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
            [allAttriStr appendAttributedString:rqsValue];
            height += 105;
        } else {
            height += 15;
        }
        if ([value rangeOfString:@"黏膜暴露"].location != NSNotFound) {
            NSAttributedString *nmblKey = [[NSAttributedString alloc] initWithString:@"黏膜暴露: " attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[UIColor redColor]}];
            [allAttriStr appendAttributedString:nmblKey];
            NSAttributedString *nmblValue = [[NSAttributedString alloc] initWithString:@"反复用生理盐水冲洗" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
            [allAttriStr appendAttributedString:nmblValue];
            height += 17;
        }
    }
    return value;
}

- (CGFloat)setBllxText:(NSString *)value view:(UITextView *)textView
{
    if (value != nil && value.length != 0) {
        NSMutableAttributedString *allAttriStr = [[NSMutableAttributedString alloc] init];
        CGFloat height = 0;
        if ([value rangeOfString:@"锐器伤"].location != NSNotFound) {
            NSAttributedString *rqsKey = [[NSAttributedString alloc] initWithString:@"锐器伤:\n" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONTSIZE], NSForegroundColorAttributeName:[UIColor redColor]}];
            [allAttriStr appendAttributedString:rqsKey];
            NSAttributedString *rqsValue = [[NSAttributedString alloc] initWithString:@"①尽可能挤出伤口处血液（从近心端向远心端挤血， 不要挤压伤口处）\n②流动水充分冲洗\n③0.5%碘伏或75%乙醇消毒伤口\n④若伤口创面较大，可采用3％过氧化氢冲洗或擦拭伤口3～5min。\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FONTSIZE], NSForegroundColorAttributeName:[UIColor blackColor]}];
            [allAttriStr appendAttributedString:rqsValue];
            height += 145;
        } else {
            height += 15;
        }
        if ([value rangeOfString:@"黏膜暴露"].location != NSNotFound) {
            NSAttributedString *nmblKey = [[NSAttributedString alloc] initWithString:@"黏膜暴露: " attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONTSIZE], NSForegroundColorAttributeName:[UIColor redColor]}];
            [allAttriStr appendAttributedString:nmblKey];
            NSAttributedString *nmblValue = [[NSAttributedString alloc] initWithString:@"反复用生理盐水冲洗" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FONTSIZE], NSForegroundColorAttributeName:[UIColor blackColor]}];
            [allAttriStr appendAttributedString:nmblValue];
            height += 17;
        }
        if (allAttriStr.length != 0) {
            textView.attributedText = allAttriStr;
            return height;
        } else {
            textView.text = value;
            return 0;
        }
    }
    return 0;
}

- (CGFloat)setTextViewText:(NSString *)value view:(UITextView *)textView
{
 
    textView.text = value;
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    return newSize.height - 5;
}

#pragma mark - Create ertra for psview

//职业护士工号的填写
- (void)createGHWithArray:(NSArray *)array
{
    CGFloat lbHeigth = 30;
    CGFloat betweenMargin = 4;
    CGFloat leftMargin = 8;
    CGFloat rightMargin = 8;
    CGFloat allHeight = 0;
    for (NSInteger index = 0; index < array.count; index++) {
        CGRect lbFrame = CGRectMake(leftMargin, (betweenMargin+lbHeigth)*index, 50, lbHeigth);
        UILabel *lb = [[UILabel alloc] initWithFrame: lbFrame];
        lb.font = [UIFont systemFontOfSize:13];
        lb.text = [array objectAtIndex:index];
//        [lb sizeToFit];
//        lbFrame = lb.frame;
//        lbFrame.size.height = lbHeigth;
//        lb.frame = lbFrame;
        [self.extraViewForPS addSubview:lb];
        
        CGFloat x = leftMargin+CGRectGetWidth(lb.frame)+betweenMargin;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, lb.frame.origin.y, CGRectGetWidth(self.psView.frame) - x - rightMargin, lbHeigth)];
        textField.placeholder = @"请输入工号";
        textField.font = [UIFont systemFontOfSize:13];
        textField.tag = index;
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [self.extraViewForPS addSubview:textField];
        allHeight += lbHeigth + betweenMargin;
    }
    CGRect frame = self.extraViewForPS.frame;
    frame.size.height = allHeight;
    self.extraViewForPS.frame = frame;
    [self.psView addSubview:self.extraViewForPS];
    
    CGRect psFrame = self.psView.frame;
    psFrame.size.height += CGRectGetHeight(self.extraViewForPS.frame);
    self.psView.frame = psFrame;
    
    self.psView.textViewTopConstraint.constant += CGRectGetHeight(self.extraViewForPS.frame);
    
    self.pishiViewHeight += self.extraViewForPS.frame.size.height;
    [self updateScrollViewContentSize:self.pishiViewHeight];
}

- (void)createBARView:(NSDictionary *)dic
{
    CGFloat betweenMargin = 4;
    CGFloat leftMargin = 8;
    CGFloat btnHeigth = 30;
    
    NSArray *array = [dic objectForKey:@"options"];
    array = @[@{@"item_rc_text":@"医务处", @"item_rc_value":@"1"},@{@"item_rc_text":@"门诊部", @"item_rc_value":@"2"},@{@"item_rc_text":@"不备案", @"item_rc_value":@"3"}];
    CGFloat width = 0;
    for (NSInteger index = 0; index < array.count; index++) {
        NSDictionary *temp = [array objectAtIndex:index];
        NSString *name = [temp objectForKey:@"item_rc_text"];
        NSInteger name_id = [[temp objectForKey:@"item_rc_value"] integerValue];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = name_id;
        [btn setImage:[UIImage imageNamed:@"beianren_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"beianren_selected"] forState:UIControlStateDisabled];
        btn.frame = CGRectMake(leftMargin+width, 0, btnHeigth, btnHeigth);
        [btn addTarget:self action:@selector(barBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.extraViewForPS addSubview:btn];
        width += btnHeigth;
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x+CGRectGetWidth(btn.frame), 0, 40, btnHeigth)];
        lb.text = name;
        lb.textAlignment = NSTextAlignmentLeft;
        lb.font = [UIFont systemFontOfSize:13];
        [lb sizeToFit];
        lb.frame = CGRectMake(lb.frame.origin.x, lb.frame.origin.y, lb.frame.size.width, btnHeigth);
        
        width += lb.frame.size.width + betweenMargin;
        
        [self.extraViewForPS addSubview:lb];
    }

    [self.psView addSubview:self.extraViewForPS];
    
    CGRect psFrame = self.psView.frame;
    psFrame.size.height += CGRectGetHeight(self.extraViewForPS.frame);
    self.psView.frame = psFrame;
    
    self.psView.textViewTopConstraint.constant += CGRectGetHeight(self.extraViewForPS.frame);
    
    self.pishiViewHeight += self.extraViewForPS.frame.size.height;
    [self updateScrollViewContentSize:self.pishiViewHeight];
    
}

- (void)barBtnAction:(id)sender
{
    for (UIButton *btn in self.extraViewForPS.subviews) {
        btn.enabled = YES;
    }
    UIButton *btn = sender;
    btn.enabled = NO;
    if (self.barParId != nil) {
        [self.extraParmDic setObject:[NSNumber numberWithInteger:btn.tag] forKey:self.barParId];
    }
}

#pragma mark - UITextView delegate method

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.bigModel.workFlowId == 187) {//首次开通HIS系统权限申请单（执业护士）
        NSInteger tag = textField.tag;
        if (tag < self.ghParArray.count) {
            NSString *parmId = [self.ghParArray objectAtIndex:tag];
            [self.extraParmDic setObject:textField.text forKey:parmId];
        }
    }
}

- (NSArray *)workFlowKeys:(NSInteger)workFlowId
{
    NSArray *listArray = nil;
    switch (workFlowId) {
        case 164://科主任请假申请
            listArray = @[@"申请人",@"科室",@"申请时间",@"申请人电话",@"替代人",@"替代人电话",@"请假开始时间",@"请假结束时间",@"主管院长",@"请假理由",@"备注",@"备案人"];
            break;
        case 163://支书请假
            listArray = @[@"申请人", @"申请科室", @"申请人电话", @"申请时间", @"替代人", @"替代人电话", @"请假开始时间", @"请假结束时间", @"理由"];
            break;
        case 195://专家门诊申请
            listArray = @[@"申请人", @"科室", @"姓名", @"工号", @"性别", @"年龄", @"现职称", @"座机", @"申请时间", @"手机", @"专业特长", @"申请挂牌专业", @"申请挂牌级别", @"要求（调整）出诊时间", @"既往工作经历<br>（重点是门诊工作）", @"门诊组长"];
            break;
        case 191://专科（专病）门诊申请
            listArray = @[@"申请人", @"科室", @"座机", @"手机", @"专科门诊名称", @"专业特色说明", @"具体时间安排", @"门诊组长", @"申请时间"];
            break;
        case 160://门禁卡申请、补办
            listArray = @[@"姓名", @"科室", @"联系人", @"联系电话", @"办卡人姓名1", @"办卡人所在部门1", @"办卡人姓名2", @"办卡人所在部门2", @"办卡人姓名3", @"办卡人所在部门3", @"申请开通权限", @"权限生效日期", @"权限截止日期", @"申请时间", @"备注1", @"备注2"];
            break;
        case 186://实验室加班申请
            listArray = @[@"申请人", @"申请科室", @"加班开始时间", @"加班结束时间", @"加班事由", @"加班人员", @"是否使用危险化学品及其危险特性", @"是否使用加热设备", @"是否经过安全培训", @"申请时间"];
            break;
        case 196://零星维修申请
            listArray = @[@"申请人", @"科室", @"职务", @"联系电话", @"附件", @"维修的房间号", @"维修内容", @"申请时间"];
            break;
        case 211://电子病历后台修改申请
            listArray = @[@"申请人", @"申请科室", @"申请时间", @"患者病历号", @"患者姓名", @"入院日期", @"主任医师", @"住院医师", @"修改内容", @"修改原因"];
            break;
        case 201://医保拒付问题反馈
            listArray = @[@"申请人", @"申请科室", @"患者姓名", @"费用发生日期", @"拒付金额", @"联系电话", @"拒付原因", @"申请补支原因", @"申请时间"];
            break;
        case 162://医保病人住院费用上传信息删除申请
            listArray = @[@"申请人", @"申请科室", @"联系人", @"联系电话", @"患者姓名", @"病例号", @"入院日期", @"出院日期", @"申请时间", @"删除原因和内容描述"];
            break;
        case 151://打印申请
            listArray = @[@"申请人", @"申请科室", @"申请时间", @"座机", @"手机", @"项目", @"使用时间", @"中文", @"英文", @"备注"];
            break;
        case 149://刻字申请
            listArray = @[@"申请人", @"申请科室", @"申请时间", @"座机", @"手机", @"项目", @"项目其他", @"横幅米数", @"中文", @"英文", @"备注"];
            break;
        case 185://科主任出国申请
            listArray = @[@"申请人", @"科室", @"申请时间", @"性别", @"出生日期", @"政治面貌", @"联系电话", @"职称", @"职务", @"来院工作日期", @"护照号", @"年收入", @"出访开始时间", @"出访结束时间", @"出访国家/地区", @"出访天数", @"出国理由", @"主管院长", @"备注"];
            break;
        case 159://正式在编职工出国申请
            listArray = @[@"姓名", @"科室", @"申请时间", @"性别", @"出生日期", @"政治面貌", @"联系电话", @"职称", @"职务", @"来院工作日期", @"护照号", @"年收入", @"出访开始时间", @"出访结束时间", @"出访国家/地区", @"出访天数", @"出国理由", @"备注"];
            break;
        case 203://开通HIS系统权限申请（急诊系统）
            listArray = @[@"申请人", @"申请科室", @"工号", @"申请时间", @"急诊系统/出诊科室", @"备注"];
            break;
        case 199://首次开通HIS系统权限申请单（执业医师）
            listArray = @[@"申请人", @"申请科室", @"工号", @"手机号", @"执业证书编码", @"执业注册时间", @"职称", @"申请时间", @"申请开放权限", @"门诊医生站", @"急诊医生站", @"住院医生站", @"手麻系统", @"电子病历", @"备注"];
            break;
        case 187://首次开通HIS系统权限申请单（执业护士）
            listArray = @[@"申请人", @"申请科室", @"联系电话", @"申请时间", @"人员"];
            break;
        case 158://多媒体信息发布
            listArray = @[@"申请人", @"申请科室", @"信息发布起始时间", @"信息发布截止时间", @"科室联系人", @"申请时间", @"手机", @"座机", @"门前LED显示电子横幅", @"会议名称", @"地点", @"开始时间", @"结束时间"];
            break;
        case 161://科护士长请假
            listArray = @[@"申请人", @"申请科室", @"申请人联系电话", @"申请时间", @"替代人", @"替代人联系电话", @"请假开始时间", @"请假结束时间", @"请假理由"];
            break;
        case 183://血源性病原体职业暴露处理
            listArray = @[@"申请人", @"科室", @"申请时间", @"座机", @"手机", @"暴露类型", @"暴露源", @"备注"];
            break;
    }
    return listArray;
}

#pragma mark -  set method

- (NSMutableArray *)ghParArray
{
    if (_ghParArray == nil) {
        _ghParArray = [NSMutableArray array];
    }
    return _ghParArray;
}

- (UIView *)extraViewForPS
{
    if (_extraViewForPS == nil) {
        _extraViewForPS = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.psView.frame), 30)];
//        _extraViewForPS.backgroundColor = [UIColor yellowColor];
    }
    return _extraViewForPS;
}

- (NSMutableDictionary *)extraParmDic
{
    if (_extraParmDic == nil) {
        _extraParmDic = [NSMutableDictionary dictionary];
    }
    return _extraParmDic;
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
