//
//  ALRunLoopMonitoring.m
//  ALRunloopWatchDog
//
//  Created by Arien Lau on 15/10/28.
//  Copyright © 2015年 Arien Lau. All rights reserved.
//

#import "ALRunLoopMonitoring.h"
#import "ALRunLoopWatchdog.h"

@interface ALRunLoopMonitoring ()
@property (nonatomic, strong) ALRunLoopWatchdog *watchdog;
@end

@implementation ALRunLoopMonitoring

static id _instance = nil;

+ (void)load
{
    @autoreleasepool {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ALRunLoopWatchdog *watchdog = [[ALRunLoopWatchdog alloc] initWithRunLoop:CFRunLoopGetMain()];
            [watchdog startWatchingMode:kCFRunLoopDefaultMode];
            watchdog.didStallWithDuration = ^(NSTimeInterval timeInterval) {
                
            };
            [ALRunLoopMonitoring sharedRunLoopMonitoring].watchdog = watchdog;
        });
    }
}

+ (instancetype)sharedRunLoopMonitoring
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
