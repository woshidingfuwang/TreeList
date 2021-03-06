//
//  MasterViewController.m
//  TreeList
//
//  Created by xuqianlong on 16/3/14.
//  Copyright © 2016年 Debugly. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TreeModel.h"
#import "QLTableViewRowAction.h"
#import "RowActionButton.h"
#import "QLTableViewCell.h"

@interface MasterViewController ()

@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    if(self.objects.count < 1){
        int random = arc4random() % 6 + 1;
        while (random--) {
            TreeModel *root = [[TreeModel alloc]initWithLeval:0];
            root.date = [NSDate date];
            [self.objects addObject:root];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    TreeModel *model = self.objects[indexPath.row];
    cell.indentationLevel = model.leval;
    cell.indentationWidth = 10 * cell.indentationLevel;
    cell.detailTextLabel.text = [model.date description];
    cell.textLabel.text = [NSString stringWithFormat:@"I'm Leval:%ld",model.leval];
    return cell;
}

- (TreeModel *)model4IndexPath:(NSIndexPath *)idx
{
    return  (self.objects.count > idx.row) ? self.objects[idx.row] : nil;
}


- (void)showDetailViewController:(TreeModel *)model
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailViewController = [sb instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.detailItem = model;
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TreeModel *model = [self model4IndexPath:indexPath];
    if (!model.isOpened) {
        if (model.leval < 5) {
            NSArray *arr = [self prepareData4Leval:model.leval idx:indexPath];
            NSIndexSet *idxSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, arr.count)];
            [self.objects insertObjects:arr atIndexes:idxSet];
            
            NSMutableArray *idxArr = [NSMutableArray array];
            NSInteger i = 0;
            while (i < arr.count) {
                i ++;
                [idxArr addObject:[NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section]];
            }
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:idxArr withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [model setOpened:YES];
        }else{
            //show detail;
            [self showDetailViewController:model];
        }
    }else{
        //关闭
        [model setOpened:NO];
        NSMutableArray *tmpArr = [NSMutableArray array];
        NSMutableArray *idxArr = [NSMutableArray array];
        
        for (NSInteger i = [self.objects indexOfObject:model] + 1; i < self.objects.count; i ++) {
            TreeModel *m = self.objects[i];
            
            if (m.leval <= model.leval) {
                break;
            }else{
                [tmpArr addObject:m];
                [idxArr addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            }
        }
        
        [self.objects removeObjectsInArray:tmpArr];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:idxArr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (NSArray *)prepareData4Leval:(NSInteger)leval idx:(NSIndexPath *)idx
{
    int random = arc4random() % 20 + 1;
    NSMutableArray *arr = [NSMutableArray array];
    while (random--) {
        TreeModel *model = [[TreeModel alloc]initWithLeval:leval + 1];
        model.date = [NSDate date];
        [arr addObject:model];
    }
    return [arr copy];
}

#pragma mark - edit logic begin

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actions = [self tableView:tableView editActionsForRowAtIndexPath:indexPath];
    NSArray *titles  = [actions valueForKeyPath:@"title"];
    return [titles componentsJoinedByString:@"拼接"];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLTableViewRowAction *action1 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"1自动删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    
    QLTableViewRowAction *action2 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"2自删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    
    QLTableViewRowAction *action3 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"3删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    
    QLTableViewRowAction *action4 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"4不删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    
    NSArray *bgColors = @[[UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0],
                          [UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:3.0f/255.0f alpha:1.0],
                          [UIColor colorWithRed:255.0f/255.0f green:128.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
    
    action2.backgroundColor = bgColors[1];
    action3.backgroundColor = bgColors[1];
    action4.backgroundColor = bgColors[2];
    if (indexPath.row == 0) {
        return @[action1];
    }else if (indexPath.row == 1){
        return @[action1,action2];
    }else if (indexPath.row == 2){
        return @[action1,action2,action3];
    }
    
    return @[action1,action2,action3,action4];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        //just handle other style
    }
}

#pragma mark - edit logic end

@end
