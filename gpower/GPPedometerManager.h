//
//  GPPedometerManager.h
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <CBToolkit/CBToolkit.h>
#import <Foundation/Foundation.h>

@interface GPPedometerManager : NSObject
CB_SINGLETON_DEFAULT_INTERFACE(GPPedometerManager);

@property (nonatomic) NSInteger steps;

- (void)startDetectionWithUpdateBlock:(void (^)(GPPedometerManager *manager, NSError *error))completion;
- (void)stopDetection;

@end
