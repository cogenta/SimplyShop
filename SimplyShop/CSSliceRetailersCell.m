//
//  CSSliceRetailersCell.m
//  SimplyShop
//
//  Created by Will Harris on 09/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSSliceRetailersCell.h"
#import <CSApi/CSAPI.h>

@interface CSSliceRetailersCell ()

@property (nonatomic, strong) NSMutableDictionary *retailerCache;
@property (nonatomic, strong) NSMutableDictionary *narrowCache;

- (void)configure;
- (void)narrowsChanged;
- (void)isRootChanged;

- (NSString *)titleLabelText;

@end

@implementation CSSliceRetailersCell

- (void)initialize
{
    [super initialize];
    self.narrowCache = [[NSMutableDictionary alloc] init];
    self.retailerCache = [[NSMutableDictionary alloc] init];
    
    [self configure];
    
    [self addObserver:self
           forKeyPath:@"narrows"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"isRoot"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (NSString *)cellNibName
{
    return @"CSSliceRetailersCell";
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"narrows"];
    [self removeObserver:self forKeyPath:@"isRoot"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != self) {
        return;
    }
    
    if ([keyPath isEqualToString:@"narrows"]) {
        [self narrowsChanged];
        return;
    }
    
    if ([keyPath isEqualToString:@"isRoot"]) {
        [self isRootChanged];
        return;
    }
}

- (void)narrowsChanged
{
    [self.narrowCache removeAllObjects];
    [self.retailerCache removeAllObjects];
    [self reloadData];
}

- (void)isRootChanged
{
    [self configure];
}

- (void)configure
{
    self.titleLabel.text = [self titleLabelText];
    self.chooseStoresButton.hidden = ! self.isRoot;
}

- (NSString *)titleLabelText
{
    if (self.isRoot) {
        return NSLocalizedString(@"Favorite Stores", nil);
    }
    
    return NSLocalizedString(@"Stores", nil);
}

- (NSInteger)retailerCount
{
    return [self.narrows count];
}

- (id)addressForRetailerAtIndex:(NSInteger)index
{
    return @(index);
}

- (void)getRetailerWithAddress:(id)address
                      callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    if ( ! [address respondsToSelector:@selector(integerValue)]) {
        NSString *msg = [NSString stringWithFormat:@"Invalid cell address %@",
                         address];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: msg};
        NSError *error = [NSError errorWithDomain:@"com.cogenta.SimplyShop.errors"
                                             code:0
                                         userInfo:userInfo];
        callback(nil, error);
        return;
    }
    
    id<CSRetailer> cachedResult = self.retailerCache[address];
    if (cachedResult) {
        callback(cachedResult, nil);
        return;
    }
    
    NSInteger index = [address integerValue];
    [self.narrows getNarrowAtIndex:index
                          callback:^(id<CSNarrow> narrow, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        self.narrowCache[address] = narrow;
        
        [narrow getNarrowsByRetailer:^(id<CSRetailer> result, NSError *error)
        {
            if (error) {
                [self.delegate sliceRetailersCell:self
                          failedToLoadRetailerURL:narrow.narrowsByRetailerURL
                                            error:error];
                callback(nil, error);
                return;
            }
            
            if (result) {
                self.retailerCache[address] = result;
            }
            
            callback(result, nil);
        }];
    }];
}

- (IBAction)didTapChooseStores:(id)sender {
    [self.delegate sliceRetailersCellDidTapChooseButton:self];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id address = [self addressForItemAtIndexPath:indexPath];
    return self.narrowCache[address] != nil;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    SEL sel = @selector(sliceRetailersCell:didSelectNarrow:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    id address = [self addressForItemAtIndexPath:indexPath];
   [self.delegate sliceRetailersCell:self
                      didSelectNarrow:self.narrowCache[address]];
}


@end
