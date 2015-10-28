//
//  SecondViewController.m
//  ALRunloopWatchDog
//
//  Created by Arien Lau on 15/10/28.
//  Copyright © 2015年 Arien Lau. All rights reserved.
//

#import "SecondViewController.h"
#import "ALRunLoopWatchdog.h"

@interface SecondViewController ()
@property (nonatomic, strong) ALRunLoopWatchdog *watchdog;
@end

@implementation SecondViewController

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.watchdog = [[ALRunLoopWatchdog alloc] initWithRunLoop:CFRunLoopGetCurrent() stallingThreshold:0.2];
    [self.watchdog startWatchingMode:kCFRunLoopCommonModes];
    self.watchdog.didStallWithDuration = ^(NSTimeInterval timeInterval) {
        NSLog(@"%@", @(timeInterval));
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sleep(3);
        NSLog(@"%s", __FUNCTION__);
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
