//
//  GPChicken.h
//  gpower
//
//  Created by yyjim on 6/17/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import "GPGameConfig.h"
#import <Foundation/Foundation.h>

@interface GPChicken : NSObject
@property (nonatomic) NSString *name;

@property (nonatomic) CGFloat energy;  // [0 -> 100]
@property (nonatomic) CGFloat vitamin; // [0 -> MAX]

@property (nonatomic, readonly) CGFloat energyProgress;
@property (nonatomic, readonly) CGFloat vitaminProgress;

@property (nonatomic) CGFloat exp;
@property (nonatomic) NSInteger level;

@property (nonatomic) GPChickenConfig *config;

+ (instancetype)createNew;
+ (instancetype)chickenFromRecord:(NSDictionary *)record;

- (BOOL)eat;
- (void)updateWithSteps:(NSInteger)steps;

- (NSDictionary *)record;
@end
