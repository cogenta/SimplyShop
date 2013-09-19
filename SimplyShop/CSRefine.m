//
//  CSRefine.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefine.h"
#import <CSApi/CSAPI.h>
#import "CSRefineType.h"

@interface CSRefine ()

@property (strong, nonatomic) CSRefineType *type;

@end

@implementation CSRefine

- (id)initWithType:(CSRefineType *)type
         valueName:(NSString *)valueName
{
    self = [super init];
    if (self) {
        self.type = type;
        self->_valueName = valueName;
    }
    return self;
}

+ (instancetype)refineWithType:(CSRefineType *)type
                     valueName:(NSString *)valueName
{
    return [[self alloc] initWithType:type valueName:valueName];
}

- (id)copyWithZone:(NSZone *)zone
{
    CSRefine *result = [[CSRefine allocWithZone:zone] init];
    result.type = self.type;
    result->_valueName = self->_valueName;
    return result;
}

- (NSUInteger)hash
{
    return [self.type hash] ^ [self.valueName hash];
}

- (NSString *)name
{
    return self.type.name;
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[CSRefine class]]) {
        return NO;
    }
    
    CSRefine *other = (CSRefine *)object;
    
    return ((self.type == other.type ||
             [self.type isEqual:other.type]) &&
            (self.valueName == other.valueName ||
             [self.valueName isEqualToString:other.valueName]));
}

- (void)getSliceWithoutRefine:(id<CSSlice>)slice
                     callback:(void (^)(id<CSSlice>, NSError *))callback
{
    [self.type getSliceWithoutRefine:slice callback:callback];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CSRefine<\"%@: %@\">",
            self.name, self.valueName];
}

@end
