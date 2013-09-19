//
//  CSRefineType.m
//  SimplyShop
//
//  Created by Will Harris on 19/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineType.h"
#import <CSApi/CSAPI.h>
#import <NSArray+Functional/NSArray+Functional.h>
#import "CSRefine.h"

@interface CSRefineType ()

@property (readonly, nonatomic) NSString *typeName;

@end

@implementation CSRefineType

- (id)initWithTypeName:(NSString *)typeName
{
    self = [super init];
    if (self) {
        self->_typeName = typeName;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[CSRefineType class]]) {
        return NO;
    }
    
    CSRefineType *other = (CSRefineType *)object;
    return (other.typeName == self.typeName ||
            [other.typeName isEqualToString:self.typeName]);
}

- (NSString *)name
{
    NSDictionary *labels = @{@"author": @"Author",
                             @"cover_type": @"Cover",
                             @"manufacturer": @"Manufacturer",
                             @"software_platform": @"Platform"};
    return labels[self.typeName];
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
                         @"Don't know how to undo %@ refine",
                         self.typeName];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"SimplyShop"
                                         code:0
                                     userInfo:userInfo];
    callback(nil, error);
}

- (void)getNarrowsForSlice:(id<CSSlice>)slice
                  callback:(void (^)(id<CSNarrowList>, NSError *))callback
{
    void (^finish)(id<CSNarrowListPage>, NSError *) =
    ^(id<CSNarrowListPage> page, NSError *error) {
        callback(page.narrowList, error);
    };
    
    if ([self.typeName isEqualToString:@"author"]) {
        [slice getAuthorNarrows:finish];
        return;
    }
    
    if ([self.typeName isEqualToString:@"cover_type"]) {
        [slice getCoverTypeNarrows:finish];
        return;
    }
    
    if ([self.typeName isEqualToString:@"manufacturer"]) {
        [slice getManufacturerNarrows:finish];
        return;
    }
    
    if ([self.typeName isEqualToString:@"software_platform"]) {
        [slice getSoftwarePlatformNarrows:finish];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:
                         @"Don't know how to get narrows for %@ refine",
                         self.typeName];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"SimplyShop"
                                         code:0
                                     userInfo:userInfo];
    callback(nil, error);
}

+ (void)getRefineTypesForSlice:(id<CSSlice>)slice
                      callback:(void (^)(NSArray *, NSError *))callback
{
    NSMutableArray *typeNames = [[NSMutableArray alloc] init];
    
    if (slice.authorNarrowsURL) {
        [typeNames addObject:@"author"];
    }
    
    if (slice.coverTypeNarrowsURL) {
        [typeNames addObject:@"cover_type"];
    }
    
    if (slice.manufacturerNarrowsURL) {
        [typeNames addObject:@"manufacturer"];
    }
    
    if (slice.softwarePlatformNarrowsURL) {
        [typeNames addObject:@"software_platform"];
    }
    
    callback([typeNames mapUsingBlock:^id(id obj) {
        return [[CSRefineType alloc] initWithTypeName:(NSString *)obj];
    }], nil);
}

- (CSRefine *)refineWithValueName:(NSString *)valueName
{
    return [CSRefine refineWithType:self valueName:valueName];
}

+ (instancetype)authorRefineType
{
    return [[CSRefineType alloc] initWithTypeName:@"author"];
}

+ (instancetype)coverTypeRefineType
{
    return [[CSRefineType alloc] initWithTypeName:@"cover_type"];
}

+ (instancetype)manufacturerRefineType
{
    return [[CSRefineType alloc] initWithTypeName:@"manufacturer"];
}

+ (instancetype)softwarePlatformRefineType
{
    return [[CSRefineType alloc] initWithTypeName:@"software_platform"];
}

@end
