//
//  CSRetailersCell.m
//  SimplyShop
//
//  Created by Will Harris on 12/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailersCell.h"
#import "CSRetailerSelectionCell.h"

@implementation CSRetailersCell

- (NSString *)cellNibName
{
    return @"CSSliceRetailersCell";
}

- (Class)itemCellClass
{
    return [CSRetailerSelectionCell class];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id, NSError *))done
{
    [self getRetailerWithAddress:address
                        callback:^(id<CSRetailer> retailer, NSError *error)
     {
         if (error) {
             done(nil, error);
             return;
         }
         
         done(retailer, nil);
     }];
}

- (NSInteger)modelCount
{
    return [self retailerCount];
}

- (id)addressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self addressForRetailerAtIndex:indexPath.row];
}

- (NSInteger)retailerCount
{
    return 0;
}

- (id)addressForRetailerAtIndex:(NSInteger)index
{
    return nil;
}

- (void)getRetailerWithAddress:(id)address
                      callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    callback(nil, [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:nil]);
}

@end
