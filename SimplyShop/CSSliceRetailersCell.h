//
//  CSSliceRetailersCell.h
//  SimplyShop
//
//  Created by Will Harris on 09/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailersCell.h"

@protocol CSSliceRetailersCellDelegate;
@protocol CSSlice;
@protocol CSNarrow;

@interface CSSliceRetailersCell : CSRetailersCell

@property (nonatomic, weak) IBOutlet id<CSSliceRetailersCellDelegate> delegate;
@property (nonatomic, strong) NSObject<CSNarrowList> *narrows;

- (IBAction)didTapChooseStores:(id)sender;

@end

@protocol CSSliceRetailersCellDelegate <NSObject>

- (void)sliceRetailersCell:(CSSliceRetailersCell *)cell
           didSelectNarrow:(id<CSNarrow>)narrow;
- (void)sliceRetailersCell:(CSSliceRetailersCell *)cell
   failedToLoadRetailerURL:(NSURL *)retailerURL
                     error:(NSError *)error;
- (void)sliceRetailersCellDidTapChooseButton:(CSSliceRetailersCell *)cell;

@end