//
//  CSRefine.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefine.h"
#import <CSApi/CSAPI.h>

@interface CSRefine ()

@property (copy, nonatomic) NSString *typeName;

@end

@implementation CSRefine

- (id)initWithTypeName:(NSString *)typeName
             valueName:(NSString *)valueName
{
    self = [super init];
    if (self) {
        self.typeName = typeName;
        self->_valueName = valueName;
    }
    return self;
}

+ (instancetype)refineWithTypeName:(NSString *)typeName
                         valueName:(NSString *)valueName
{
    return [[self alloc] initWithTypeName:typeName valueName:valueName];
}

- (id)copyWithZone:(NSZone *)zone
{
    CSRefine *result = [[CSRefine allocWithZone:zone] init];
    result.typeName = self.typeName;
    result->_valueName = self->_valueName;
    return result;
}

- (NSUInteger)hash
{
    return [self.typeName hash] ^ [self.valueName hash];
}

- (NSString *)name
{
    NSDictionary *labels = @{@"author": @"Author",
                             @"cover_type": @"Cover",
                             @"manufacturer": @"Manufacturer",
                             @"software_platform": @"Platform"};
    return labels[self.typeName];
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[CSRefine class]]) {
        return NO;
    }
    
    CSRefine *other = (CSRefine *)object;
    
    return ((self.typeName == other.typeName ||
             [self.typeName isEqualToString:other.typeName]) &&
            (self.valueName == other.valueName ||
             [self.valueName isEqualToString:other.valueName]));
}

- (void)getSliceWithoutRefine:(id<CSSlice>)slice
                     callback:(void (^)(id<CSSlice>, NSError *))callback
{
    if ([self.typeName isEqualToString:@"author"]) {
        [slice getSliceWithoutAuthorFilter:callback];
        return;
    }
    
    if ([self.typeName isEqualToString:@"cover_type"]) {
        [slice getSliceWithoutCoverTypeFilter:callback];
        return;
    }
    
    if ([self.typeName isEqualToString:@"manufacturer"]) {
        [slice getSliceWithoutManufacturerFilter:callback];
        return;
    }
    
    if ([self.typeName isEqualToString:@"software_platform"]) {
        [slice getSliceWithoutSoftwarePlatformFilter:callback];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:
                         @"Don't know how to undo %@ refine", self.typeName];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"SimplyShop"
                                         code:0
                                     userInfo:userInfo];
    callback(nil, error);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CSRefine<\"%@: %@\">",
            self.name, self.valueName];
}

@end
