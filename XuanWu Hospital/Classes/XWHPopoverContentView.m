//
//  XWHPopoverContentView.m
//  XuanWu Hospital
//
//  Created by Mingyang on 14/12/22.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

#import "XWHPopoverContentView.h"
#import "XWHBulletinTypeModel.h"
#import "XWHProcessStatus.h"
#import "XWHDaiBanBigModel.h"

@interface XWHPopoverContentView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) UITableView *mTableView;

@end

@implementation XWHPopoverContentView

- (id)initWithFrame:(CGRect)frame data:(NSArray *)data
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.dataArray = data;
        self.mTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        [self addSubview:self.mTableView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.mTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        [self addSubview:self.mTableView];
    }
    return self;
}

- (void)setData:(NSArray *)array
{
    self.dataArray = array;
    CGRect frame = self.mTableView.frame;
    frame.size.height = array.count * POPOVER_CELL_HEIGHT;
    if (frame.size.height > 300) {
        frame.size.height = 300;
    }
    self.mTableView.frame = frame;
    [self.mTableView reloadData];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frame.size.height);
}

- (void)setData:(NSArray *)array andHeight:(CGFloat)height
{
    self.dataArray = array;
    CGRect frame = self.mTableView.frame;
    frame.size.height = array.count * POPOVER_CELL_HEIGHT;
    if (frame.size.height > height) {
        frame.size.height = height;
    }
    self.mTableView.frame = frame;
    [self.mTableView reloadData];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frame.size.height);
}

#pragma mark - UITableViewDelegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return POPOVER_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    id temp = [self.dataArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[NSString class]]) {
        cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    } else if ([temp isKindOfClass:[XWHBulletinTypeModel class]]) {
        XWHBulletinTypeModel *type = temp;
        cell.textLabel.text = type.typeName;
    } else if ([temp isKindOfClass:[XWHProcessStatus class]]) {
        XWHProcessStatus *status = temp;
        cell.textLabel.text = status.activityName;
    } else if ([temp isKindOfClass:[XWHDaiBanBigModel class]]) {
        XWHDaiBanBigModel *model = temp;
        cell.textLabel.text = model.procdefName;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.cellSelectHandler(indexPath.row, [self.dataArray objectAtIndex:indexPath.row]);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
