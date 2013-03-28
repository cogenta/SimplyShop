//
//  CSRetailerSelectionViewController.m
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerSelectionViewController.h"
#import "CSRetailerSelectionCell.h"

@interface CSRetailerSelectionViewController ()

@end

@implementation CSRetailerSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[CSRetailerSelectionCell class]
            forCellWithReuseIdentifier:@"CSRetailerSelectionCell"];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSRetailerSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSRetailerSelectionCell"
                                                                              forIndexPath:indexPath];
    return cell;
}

@end
