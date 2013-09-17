//
//  CSExplicitBlockOperation.h
//  SimplyShop
//
//  Created by Will Harris on 17/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSExplicitBlockOperation : NSOperation

+ (CSExplicitBlockOperation *)operationWithBlock:(void (^)(void (^done)()))blk;

@end
