//
//  CSAddressCell.h
//  SimplyShop
//
//  Created by Will Harris on 05/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSAddressCell <NSObject>

- (void)setLoadingAddress:(id)address;
- (void)setModel:(id)model address:(id)address;
- (void)setError:(NSError *)error address:(id)address;

@end
