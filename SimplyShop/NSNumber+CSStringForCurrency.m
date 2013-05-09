//
//  NSNumber+CSStringForCurrency.m
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "NSNumber+CSStringForCurrency.h"

@implementation NSNumber (CSStringForCurrency)

- (NSString *)stringForCurrencySymbol:(NSString *)symbol code:(NSString *)code
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setCurrencySymbol:symbol];
    [formatter setCurrencyCode:code];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    
    NSNumber *roundedValue = [NSNumber numberWithInteger:[self integerValue]];
    BOOL isIntegerValue = [self isEqualToNumber:roundedValue];
    
    if (isIntegerValue) {
        [formatter setMaximumFractionDigits:0];
    }
    
    return [formatter stringFromNumber:self];
}

@end
