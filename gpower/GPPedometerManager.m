//
//  GPPedometerManager.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <SOMotionDetector/SOStepDetector.h>
#import "GPPedometerManager.h"

@interface GPPedometerManager ()
@end

@implementation GPPedometerManager
CB_SINGLETON_DEFAULT_IMPLEMENTATION(GPPedometerManager);

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)startDetectionWithUpdateBlock:(void (^)(GPPedometerManager *, NSError *))completion
{
    SOStepDetector *detector = [SOStepDetector sharedInstance];
    [detector startDetectionWithUpdateBlock:^(NSError *error) {
        if (!error) {
            self.steps++;
        }
        NSLog(@"steps %@", @(self.steps));
        if (completion) {
            completion(self, error);
        }
    }];
}

- (void)stopDetection
{
    [[SOStepDetector sharedInstance] stopDetection];
}

@end
