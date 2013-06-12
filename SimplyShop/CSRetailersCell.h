//
//  CSRetailersCell.h
//  SimplyShop
//
//  Created by Will Harris on 12/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"
#import <CSApi/CSAPI.h>

@interface CSRetailersCell : CSDashboardRowCell

- (NSInteger)retailerCount;
- (id)addressForRetailerAtIndex:(NSInteger)index;
- (void)getRetailerWithAddress:(id)address
                      callback:(void (^)(id<CSRetailer>, NSError *))callback;

@end
