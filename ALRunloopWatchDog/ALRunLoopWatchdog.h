//
//  ALRunLoopWatchdog.h
//  ALRunloopWatchDog
//
//  Created by Arien Lau on 15/10/28.
//  Copyright © 2015年 Arien Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALRunLoopWatchdog : NSObject

/**
 initializes the receiver to watch the specified run loop,using a default stalliing threshold.
 */
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop;

/**
 initialized the receiver to detech when the specified run loop blocks for more than 'threshold' seconds
 @note This is the designated initializer for this class
 */
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop stallingThreshold:(NSTimeInterval)threshold;

/**
 begins watching the receiver's run loop for stalling in the given mode
 @note the receiver will automatically stop watching the run loop upon deallocation
 @param mode the mode in which to monitor the specified run loop.Use kCFRunLoopCommonModes to watch all common run loop modes. this shouldn't be NULL
 */
- (void)startWatchingMode:(CFStringRef)mode;

/**
 stop watching the receiver's run loop for stalling in the given mode.There is generally no need to invoke this method explicitly
 @param mode The mode in which to monitor the specified run loop.This mode should be equal to the param which deliver to startWatchingMode: method
 */
- (void)stopWatchingMode:(CFStringRef)mode;

/**
 the number of seconds that elapsed in the run loop iteration.
 */
@property (nonatomic, copy) void (^didStallWithDuration)(NSTimeInterval duration);

@end
