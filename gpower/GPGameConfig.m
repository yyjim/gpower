//
//  GPGameConfig.m
//  gpower
//
//  Created by yyjim on 6/18/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//
#import <Tweaks/FBTweakInline.h>
#import "GPGameConfig.h"

@implementation GPGameConfig

+ (instancetype)config
{
    GPGameConfig *config = [[self alloc] init];
    return config;
}

- (GPChickenConfig *)chickenConfig
{
     return [GPChickenConfig config];
}

@end

// =============================================================================

@implementation GPChickenConfig

+ (instancetype)config
{
    GPChickenConfig *config = [[self alloc] init];
    config.expBase  = FBTweakValue(@"chicken", @"exp", @"base", 100);
    config.expScale = FBTweakValue(@"chicken", @"exp", @"scale", 1.1);
    
    config.energyInitial = FBTweakValue(@"chicken", @"energy", @"initial", 50);;
    config.energyConsumeRate = FBTweakValue(@"chicken", @"energy", @"consume", 0.0069);
    config.energyBase = FBTweakValue(@"chicken", @"energy", @"base", 100);
    config.energyLevelScale = FBTweakValue(@"chicken", @"energy", @"level scale", 1);

    config.vitaminInitial = FBTweakValue(@"chicken", @"vitamin", @"initial", 100);;
    config.vitaminConversionRate = FBTweakValue(@"chicken", @"vitamin", @"conversion", 1);
    config.vitaminBase = FBTweakValue(@"chicken", @"vitamin", @"base", 100);
    config.vitaminLevelScale = FBTweakValue(@"chicken", @"vitamin", @"level scale", 1);
    
    config.feedVitaminCost = FBTweakValue(@"chicken", @"feed", @"vitamin cost", 10);
    config.feedEnergyGet = FBTweakValue(@"chicken", @"feed", @"energy get", 5);
    config.feedExpGet = FBTweakValue(@"chicken", @"feed", @"exp get", 50);

    return config;
}

@end

