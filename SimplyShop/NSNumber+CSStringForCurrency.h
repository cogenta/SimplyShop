//
//  NSNumber+CSStringForCurrency.h
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CSStringForCurrency)

- (NSString *)stringForCurrencySymbol:(NSString *)symbol code:(NSString *)code;

@end
