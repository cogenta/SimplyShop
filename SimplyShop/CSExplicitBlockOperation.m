//
//  CSExplicitBlockOperation.m
//  SimplyShop
//
//  Created by Will Harris on 17/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSExplicitBlockOperation.h"

@interface CSExplicitBlockOperation ()

@property (strong, nonatomic) void (^blk)(void (^)());
@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

@end

@implementation CSExplicitBlockOperation

- (id)initWithBlock:(void (^)(void (^done)()))blk
{
    self = [super init];
    if (self) {
        _blk = blk;
    }
    return self;
}

+ (CSExplicitBlockOperation *)operationWithBlock:(void (^)(void (^done)()))blk
{
    return [[CSExplicitBlockOperation alloc] initWithBlock:blk];
}

- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    _blk(^{
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    });
}

- (BOOL)isConcurrent
{
    return YES;
}

@end
