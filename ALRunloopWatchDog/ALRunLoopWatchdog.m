//
//  ALRunLoopWatchdog.m
//  ALRunloopWatchDog
//
//  Created by Arien Lau on 15/10/28.
//  Copyright © 2015年 Arien Lau. All rights reserved.
//

#import "ALRunLoopWatchdog.h"
#include <mach/mach_time.h>

static const NSTimeInterval ALRunLoopWatchdogDefaultStallingThreshold = 0.2;

@interface ALRunLoopWatchdog ()

@property (nonatomic, assign, readonly) CFRunLoopRef runLoop; /**< the run loop object to watch*/
@property (nonatomic, assign, readonly) CFRunLoopObserverRef observer; /**< the observer use to watch the run loop*/
@property (nonatomic, assign, readonly) NSTimeInterval threshold; /**< the number of seconds that must pass to consider the run loop stalled*/
/**
 the mach_absolute_time() at which the current run loop iteration was started,or 0 if there is no current iteration in progress.
 this property is not thread-safe, and must only be accessed from the thread that the run loop is associated with.
 */
@property (nonatomic, assign) uint64_t startTime;

/**
 invoked any time the run loop stall.
 @param duration the number of seconds that elapsed in the run loop iteration.
 */
- (void)iterationStalledWithDuration:(NSTimeInterval)duration;

@end

@implementation ALRunLoopWatchdog

- (void)dealloc
{
    if (_observer) {
        CFRunLoopObserverInvalidate(_observer);
        CFRelease(_observer);
        _observer = NULL;
    }
    if (_runLoop) {
        CFRelease(_runLoop);
        _runLoop = NULL;
    }
}

- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop
{
    return [self initWithRunLoop:runLoop stallingThreshold:ALRunLoopWatchdogDefaultStallingThreshold];
}

- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop stallingThreshold:(NSTimeInterval)threshold
{
    NSParameterAssert(runLoop);
    NSParameterAssert(threshold > 0);
    self = [super init];
    if (self) {
        _runLoop = (CFRunLoopRef)CFRetain(runLoop);
        _threshold = threshold;
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        
        NSTimeInterval secondsPerMachTime = timebase.numer / timebase.denom / 1e9;
        __weak typeof(self) weakSelf = self;
        _observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopAllActivities, YES, INT_MIN, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            switch (activity) {
                //run loop 迭代循环是以下面的几种之一开始的
                case kCFRunLoopEntry:
                case kCFRunLoopBeforeTimers:
                case kCFRunLoopAfterWaiting:
                case kCFRunLoopBeforeSources:
                    if (strongSelf.startTime == 0) {
                        strongSelf.startTime = mach_absolute_time();
                    }
                    break;
                case kCFRunLoopBeforeWaiting:
                case kCFRunLoopExit: {
                    uint64_t endTime = mach_absolute_time();
                    if (strongSelf.startTime <= 0) {
                        break;
                    }
                    uint64_t elapsed = endTime - strongSelf.startTime;
                    NSTimeInterval duration = elapsed * secondsPerMachTime;
                    if (duration > strongSelf.threshold) {
                        [strongSelf iterationStalledWithDuration:duration];
                    }
                    strongSelf.startTime = 0;
                    break;
                }
                default: {
#if DEBUG
                    NSException *exception = [NSException exceptionWithName:@"ALRunLoopWatchdogException" reason:[NSString stringWithFormat:@"Observer should not have been triggered for activity %@", @(activity)] userInfo:@{}];
                    [exception raise];
#endif
                    break;
                }
            }
        });
        
        if (!_observer) {
            return nil;
        }
    }
    return self;
}

#pragma mark - Starting and Stopping
- (void)startWatchingMode:(CFStringRef)mode
{
    NSParameterAssert(mode);
    CFRunLoopAddObserver(self.runLoop, self.observer, mode);
}

- (void)stopWatchingMode:(CFStringRef)mode
{
    NSParameterAssert(mode);
    CFRunLoopRemoveObserver(self.runLoop, self.observer, mode);
}

#pragma mark - Timing
- (void)iterationStalledWithDuration:(NSTimeInterval)duration
{
#if DEBUG
    NSLog(@"%@:iteration of run loop %p took %.f ms to excute", self, self.runLoop, duration * 1000);
#endif
    if (self.didStallWithDuration) {
        self.didStallWithDuration(duration);
    }
}

@end
