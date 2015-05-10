//
//  XWHMessageListCell.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/10.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHMessageListCell.h"

@interface XWHMessageListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titlelb;
@property (weak, nonatomic) IBOutlet UILabel *datelb;
@property (weak, nonatomic) IBOutlet UILabel *namelb;
@property (weak, nonatomic) IBOutlet UILabel *statuslb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fjLeftConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fjImageView;

@end

@implementation XWHMessageListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setModel:(id)model
{
    if ([model isKindOfClass:[XWHMessageReceiveListModel class]]) {
        XWHMessageReceiveListModel *listModel = model;
        self.titlelb.text = listModel.subject;
        self.datelb.text = listModel.sendTime;
        self.namelb.text = listModel.fromUserName;
//        self.messageId = listModel.messageRemindId;
        if (listModel.isReaded) {
            self.statuslb.text = @"已读";
            self.statuslb.textColor = [UIColor blackColor];
        } else {
            self.statuslb.text = @"未读";
            self.statuslb.textColor = [UIColor redColor];
        }
        self.fjImageView.hidden = !listModel.isAttachment;
    } else if ([model isKindOfClass:[XWHMessageSendListModel class]]) {
        XWHMessageSendListModel *listModel = model;
        self.titlelb.text = listModel.subject;
        self.datelb.text = listModel.sendTime;
//        self.messageId = model.messageRemindId;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        for (NSDictionary *obj in listModel.toUserList) {
            BOOL flag = [[obj objectForKey:IF_READED] boolValue];
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:[obj objectForKey:USER_NAMES] attributes:@{NSForegroundColorAttributeName:flag?[UIColor blackColor]:[UIColor redColor]}];
            [attrStr appendAttributedString:str];
        }
        self.namelb.attributedText = attrStr;
        self.statuslb.hidden = YES;
        self.fjImageView.hidden = !listModel.isAttachment;
    }
    CGRect rect = [self.titlelb.text boundingRectWithSize:CGSizeMake(216, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titlelb.font} context:nil];
    self.fjLeftConstraint.constant = rect.size.width + 8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
