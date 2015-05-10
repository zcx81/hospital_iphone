//
//  XWHSmallWorkFlowCell.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/11.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWHSmallWorkFlowCell.h"
#import "XWHSmallScheduleModel.h"

@interface XWHSmallWorkFlowCell ()

@property (weak, nonatomic) IBOutlet UILabel *sqrlb;
@property (weak, nonatomic) IBOutlet UILabel *datelb;
@property (weak, nonatomic) IBOutlet UILabel *statuslb;

@end

@implementation XWHSmallWorkFlowCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setData:(id)model
{
    if ([model isKindOfClass:[XWHWorkFlowSmallModel class]]) {
        XWHWorkFlowSmallModel *smallModel = model;
        if (smallModel.valuesArray.count >= 1) {
            NSString *sqr = [smallModel.valuesArray firstObject];
            if ([sqr isKindOfClass:[NSString class]]) {
                self.sqrlb.text = sqr;
            }
        }
        if (smallModel.valuesArray.count >= 2) {
            NSString *date = [smallModel.valuesArray objectAtIndex:1];
            if ([date isKindOfClass:[NSString class]]) {
                self.datelb.text = date;
            }
        }
        if (smallModel.isCanBanli) {
            self.statuslb.textColor = [UIColor redColor];
        } else {
            self.statuslb.textColor = [UIColor blackColor];
        }
        self.statuslb.text = smallModel.processStatus;
        if (smallModel.isFinish) {
            self.statuslb.textColor = [UIColor greenColor];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
