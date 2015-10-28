//
//  ALRunLoopWatchdog.h
//  ALRunloopWatchDog
//
//  Created by Arien Lau on 15/10/28.
//  Copyright © 2015年 Arien Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALRunLoopWatchdog : NSObject

- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop;
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop stallingThreshold:(NSTimeInterval)threshold;
- (void)startWatchingMode:(CFStringRef)mode;
- (void)stopWatchingMode:(CFStringRef)mode;

@property (nonatomic, copy) void (^didStallWithDuration)(NSTimeInterval duration);

@end
