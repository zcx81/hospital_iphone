//
//  XWSmallScheduleTableViewCell.m
//  XuanWu Hospital
//
//  Created by Mingyang on 15/1/29.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "XWSmallScheduleTableViewCell.h"

@interface XWSmallScheduleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titlelb;
@property (weak, nonatomic) IBOutlet UILabel *subtitlelb;
@property (weak, nonatomic) IBOutlet UILabel *datelb;
@property (weak, nonatomic) IBOutlet UILabel *userlb;


@end

@implementation XWSmallScheduleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setData:(XWHSmallScheduleModel *)model
{
    if ([model isKindOfClass:[XWHSmallScheduleModel class]]) {
        self.titlelb.text = model.procdef_name;
        self.subtitlelb.text = model.task_name;
        self.datelb.text = model.create_time;
        self.userlb.text = model.user_name;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
