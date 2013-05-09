//
//  SenTestCase+CSAsyncTestCase.m
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "SenTestCase+CSAsyncTestCase.h"

@implementation SenTestCase (CSAsyncTestCase)

- (NSTimeInterval)CSATC_waitForSemaphore:(dispatch_semaphore_t)semaphore
{
    NSDate *start = [NSDate date];
    long timedout;
    int maxTries = 16;
    double totalWait = 3.0;
    double delayInSeconds = totalWait / maxTries;
    int64_t delaayInNanoseconds = (int64_t)(delayInSeconds * NSEC_PER_SEC);
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW,
                                              delaayInNanoseconds);
    for (int tries = 0; tries < maxTries; tries++) {
        timedout = dispatch_semaphore_wait(semaphore, wait_time);
        if (! timedout) {
            break;
        }
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:delayInSeconds];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:deadline];
    }
    
    NSDate *end = [NSDate date];
    if (timedout != 0) {
        return [end timeIntervalSinceDate:start];
    } else {
        return 0;
    }
}

- (NSTimeInterval)CSATC_timeoutInterval:(void (^)(void (^done)()))blk
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^done)() = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    blk(done);
    
    return [self CSATC_waitForSemaphore:semaphore];
}

@end
