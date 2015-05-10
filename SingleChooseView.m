//
//  SingleChooseView.m
//  XuanWu Hospital
//
//  Created by apple on 15/5/9.
//  Copyright (c) 2015年 XuanWu. All rights reserved.
//

#import "SingleChooseView.h"

@interface SingleChooseView ()

@property(nonatomic,strong) UITableView *tableView;

@end

@implementation SingleChooseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init{
    
    if ( self = [super init] ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    return self;
}

-(void)reload
{
    self.frame = CGRectMake(0, 0, 320, [_infoArray count]*40);
    _tableView.frame = self.bounds;
    [_tableView reloadData];
}

-(void)setInfoArray:(NSArray *)infoArray
{
    _infoArray = infoArray;
    [self reload];
}

#pragma mark-UITableViewDelegate

//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;//返回标题数组中元素的个数来确定分区的个数
    
}



//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_infoArray count];
}



//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    cell.textLabel.text = [_infoArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

@end
