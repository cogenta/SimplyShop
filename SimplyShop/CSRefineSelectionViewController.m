//
//  CSRefineSelectionViewController.m
//  SimplyShop
//
//  Created by Will Harris on 13/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineSelectionViewController.h"
#import "CSNarrowCell.h"
#import <CSApi/CSAPI.h>

@interface CSRefineSelectionViewController ()

@property (strong, nonatomic) id<CSNarrowList> narrows;

@end

@implementation CSRefineSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.selectionDelegate getNarrows:^(id<CSNarrowList> narrows,
                                         NSError *error)
     {
        if (error) {
            // TODO: show error
            return;
        }
        
        self.narrows = narrows;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.narrows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NarrowCell";
    CSNarrowCell *cell = (CSNarrowCell *)
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CSNarrowCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier];
    }
    
    [cell setNarrowList:self.narrows index:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.narrows != nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectionDelegate didSelectNarrowAtIndex:indexPath.row];
}

@end
