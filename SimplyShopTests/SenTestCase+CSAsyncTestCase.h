//
//  SenTestCase+CSAsyncTestCase.h
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#define CALL_AND_WAIT(blk) \
{ \
    if ([self CSATC_timeoutInterval:(blk)] > 0.0) { \
        STFail(@"timed out"); \
    } \
}

@interface SenTestCase (CSAsyncTestCase)

- (NSTimeInterval)CSATC_timeoutInterval:(void (^)(void (^done)()))blk;
- (NSTimeInterval)CSATC_waitForSemaphore:(dispatch_semaphore_t)semaphore;

@end
