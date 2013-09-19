//
//  CSRefineMenuViewController.m
//  SimplyShop
//
//  Created by Will Harris on 19/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineMenuViewController.h"
#import "CSRefineType.h"
#import "CSRefineSelectionViewController.h"
#import <CSApi/CSAPI.h>

#pragma mark - CSRefineTypeRefines

@interface CSRefineTypeRefines : NSObject
<CSRefineSelectionViewControllerDelegate>

@property (strong, nonatomic) id<CSSlice> slice;
@property (strong, nonatomic) CSRefineType *type;
@property (strong, nonatomic) CSRefineMenuViewController *controller;

@property (strong, nonatomic) id<CSNarrowList> narrowsCache;

@end

@implementation CSRefineTypeRefines

- (void)getNarrows:(void (^)(id<CSNarrowList>, NSError *))callback
{
    if (self.narrowsCache) {
        return callback(self.narrowsCache, nil);
    }
    
    [self.type getNarrowsForSlice:self.slice
                         callback:^(id<CSNarrowList> narrows, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        self.narrowsCache = narrows;
        callback(narrows, nil);
    }];
}

- (void)didSelectNarrowAtIndex:(NSUInteger)index
{
    CSRefineMenuViewController *controller = self.controller;
    
    [self getNarrows:^(id<CSNarrowList> list, NSError *error) {
        if (error) {
            // TODO: show error
            return;
        }
        
        [list getNarrowAtIndex:index callback:^(id<CSNarrow> narrow,
                                                NSError *error)
        {
            if (error) {
                // TODO: show error
                return;
            }
            
            [controller.menuDelegate refineMenuViewController:controller
                                              didSelectNarrow:narrow];
        }];
        
        return;
    }];
}

@end

#pragma mark - CSRefineMenuViewController

@interface CSRefineMenuViewController ()

@property (strong, nonatomic) NSArray *types;

@end

@implementation CSRefineMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [CSRefineType getRefineTypesForSlice:self.slice
                                callback:^(NSArray *types, NSError *error) {
        if (error) {
            // TODO: show error
        }
        
        self.types = types;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.types.count;
}

- (CSRefineType *)refineTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSRefineType *result = self.types[indexPath.row];
    if ( ! [result isKindOfClass:[CSRefineType class]]) {
        return nil;
    }
    
    return result;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RefineType";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self refineTypeForRowAtIndexPath:indexPath].name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSRefineSelectionViewController *vc =
    [[CSRefineSelectionViewController alloc]
     initWithNibName:@"CSRefineSelectionViewController"
     bundle:nil];
    CSRefineTypeRefines * refines = [[CSRefineTypeRefines alloc] init];
    refines.type = [self refineTypeForRowAtIndexPath:indexPath];
    refines.slice = self.slice;
    refines.controller = self;
    
    vc.selectionDelegate = refines;
    vc.type = [self refineTypeForRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
