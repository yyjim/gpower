//
//  GPGameConfig.h
//  gpower
//
//  Created by yyjim on 6/18/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

// =============================================================================

@class GPChickenConfig;
@interface GPGameConfig : NSObject

+ (instancetype)config;
- (GPChickenConfig *)chickenConfig;
@end

// =============================================================================

@interface GPChickenConfig : NSObject
@property (nonatomic) CGFloat expBase;
@property (nonatomic) CGFloat expScale;

@property (nonatomic) CGFloat energyInitial;
@property (nonatomic) CGFloat energyConsumeRate;
@property (nonatomic) CGFloat energyBase;
@property (nonatomic) CGFloat energyLevelScale;

@property (nonatomic) CGFloat vitaminBase;
@property (nonatomic) CGFloat vitaminLevelScale;
@property (nonatomic) CGFloat vitaminInitial;
@property (nonatomic) CGFloat vitaminConversionRate;

@property (nonatomic) CGFloat feedVitaminCost;
@property (nonatomic) CGFloat feedEnergyGet;
@property (nonatomic) CGFloat feedExpGet;
+ (instancetype)config;
@end
