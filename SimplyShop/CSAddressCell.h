//
//  CSAddressCell.h
//  SimplyShop
//
//  Created by Will Harris on 05/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSAddressCell <NSObject>

- (void)setLoadingAddress:(NSObject *)address;
- (void)setModel:(id)model address:(NSObject *)address;
- (void)setError:(NSError *)error address:(NSObject *)address;

@end
