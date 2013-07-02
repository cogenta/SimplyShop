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
    static NSMutableDictionary *symbolDicts = nil;
    if ( ! symbolDicts) {
        symbolDicts = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    NSMutableDictionary *symbolDict = symbolDicts[symbol];
    if ( ! symbolDict) {
        symbolDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        symbolDicts[symbol] = symbolDict;
    }
    
    NSMutableDictionary *formatters = symbolDict[code];
    if ( ! formatters) {
        formatters = [[NSMutableDictionary alloc] initWithCapacity:2];
        symbolDict[code] = formatters;
    }
    
    NSNumber *roundedValue = [NSNumber numberWithInteger:[self integerValue]];
    BOOL isIntegerValue = [self isEqualToNumber:roundedValue];
    
    NSNumberFormatter *formatter = formatters[@(isIntegerValue)];
    
    if ( ! formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setCurrencySymbol:symbol];
        [formatter setCurrencyCode:code];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        if (isIntegerValue) {
            [formatter setMaximumFractionDigits:0];
        }
        
        formatters[@(isIntegerValue)] = formatter;
    }
    
    return [formatter stringFromNumber:self];
}

@end
