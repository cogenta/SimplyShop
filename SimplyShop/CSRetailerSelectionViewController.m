//
//  CSRetailerSelectionViewController.m
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerSelectionViewController.h"
#import "CSRetailerSelectionCell.h"
#import <CSApi/CSAPI.h>

@interface CSRetailerSelectionViewController ()

@property (nonatomic, strong) NSObject<CSRetailerList> *retailerList;

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@property (nonatomic, strong) NSMutableSet *selectedRetailerURLs;

- (void)loadRetailers;

@end

@implementation CSRetailerSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedIndexes = [NSMutableIndexSet indexSet];
        self.selectedRetailerURLs = [NSMutableSet set];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedIndexes = [NSMutableIndexSet indexSet];
        self.selectedRetailerURLs = [NSMutableSet set];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;
    [self loadRetailers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addObserver:self
           forKeyPath:@"retailerList"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"api"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"api"];
    [self removeObserver:self forKeyPath:@"retailerList"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"retailerList"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    } else if ([keyPath isEqualToString:@"api"]) {
        [self loadRetailers];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.retailerList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSRetailerSelectionCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSRetailerSelectionCell"
                                              forIndexPath:indexPath];
    [cell setRetailerList:self.retailerList index:indexPath.row];
    BOOL selected = [self.selectedIndexes containsIndex:indexPath.row];
    cell.selected = selected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView cellForItemAtIndexPath:indexPath].selected = YES;
    [self.selectedIndexes addIndex:indexPath.row];
    [self.retailerList getRetailerAtIndex:indexPath.row
                                 callback:^(id<CSRetailer> retailer, NSError *error)
    {
        if (error) {
            // TODO: report error
            return;
        }
        
        [self.selectedRetailerURLs addObject:retailer.URL];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView cellForItemAtIndexPath:indexPath].selected = NO;
    [self.selectedIndexes removeIndex:indexPath.row];
    [self.retailerList getRetailerAtIndex:indexPath.row
                                 callback:^(id<CSRetailer> retailer, NSError *error)
     {
         if (error) {
             // TODO: report error
             return;
         }
         
         [self.selectedRetailerURLs removeObject:retailer.URL];
     }];
}

- (IBAction)didTapShopButton:(id)sender {
    // TODO: present saving state
    
    [self.api login:^(id<CSUser> user, NSError *error) {
        [user createGroupWithChange:^(id<CSMutableGroup> mutableGroup) {
            mutableGroup.reference = @"favoriteRetailers";
        } callback:^(id<CSGroup> group, NSError *error) {
            if (error) {
                // TODO: handle error
                return;
            }
            
            __block NSUInteger likesToAdd = self.selectedRetailerURLs.count;
            for (NSURL *url in self.selectedRetailerURLs) {
                [group createLikeWithChange:^(id<CSMutableLike> like) {
                    like.likedURL = url;
                } callback:^(id<CSLike> like, NSError *error) {
                    --likesToAdd;
                    // TODO: handle error
                    
                    if (likesToAdd == 0) {
                        [[[UIAlertView alloc] initWithTitle:@"Done" message:@"Added" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
                    }
                }];
            }
        }];
    }];
}

- (void)loadRetailers
{
    [self.api getApplication:^(id<CSApplication> app, NSError *error) {
        if (error) {
            // TODO: report error
            return;
        }
        
        [app getRetailers:^(id<CSRetailerListPage> firstPage, NSError *error) {
            if (error) {
                // TODO: report error
                return;
            }
            
            self.retailerList = firstPage.retailerList;
        }];
    }];
}

@end
