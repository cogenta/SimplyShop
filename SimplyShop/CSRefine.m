//
//  CSRefine.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefine.h"

@implementation CSRefine

- (id)copyWithZone:(NSZone *)zone
{
    CSRefine *result = [[CSRefine allocWithZone:zone] init];
    result.name = self.name;
    result.valueName = self.valueName;
    return result;
}

- (NSUInteger)hash
{
    return [self.name hash] ^ [self.valueName hash];
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[CSRefine class]]) {
        return NO;
    }
    
    CSRefine *other = (CSRefine *)object;
    
    return ((self.name == other.name || [self.name isEqualToString:other.name])
            && (self.valueName == other.valueName
                || [self.valueName isEqualToString:other.valueName]));
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", self.name, self.valueName];
}

@end
