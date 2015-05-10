//
//  XWHBulletinTableViewCell.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/10.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHBulletinTableViewCell.h"
#import "XWHDBManage.h"
#import "XWHHelper.h"

@interface XWHBulletinTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titlelb;
@property (weak, nonatomic) IBOutlet UILabel *typelb;
@property (weak, nonatomic) IBOutlet UILabel *datelb;

@end

@implementation XWHBulletinTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setModel:(XWHBulletinModel *)model
{
    self.titlelb.text = model.title;
    NSString *typeName = [[XWHDBManage sharedInstance] getTypeNameById:model.bulletinTypeId];
    if (typeName == nil || typeName.length == 0) {
        self.typelb.hidden = YES;
    } else {
        self.typelb.hidden = NO;
        self.typelb.text = typeName;
    }
    self.datelb.text = model.updateTime;
    
    if ([XWHHelper dateFormatter:self.datelb.text]) {
//        self.imgView.hidden = YES;
    } else {
//        self.imgView.hidden = NO;
//        CGRect frame = self.titlelb.frame;
//        CGSize titleSize = [self.titleLabel.text boundingRectWithSize:frame.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
//        CGRect imgframe = self.imgView.frame;
//        imgframe.origin.x = frame.origin.x+titleSize.width + 10;
//        self.imgView.frame = imgframe;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
