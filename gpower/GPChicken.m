//
//  GPChicken.m
//  gpower
//
//  Created by yyjim on 6/17/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import "GPChicken.h"
@interface GPChicken ()
@property (nonatomic) NSDate *lastUpdatedAt;
@end

@implementation GPChicken

+ (instancetype)createNew
{
    GPChicken *chicken = [[GPChicken alloc] init];
    chicken.energy  = chicken.config.energyInitial;
    chicken.vitamin = chicken.config.vitaminInitial;
    chicken.lastUpdatedAt = [NSDate date];
    return chicken;
}

+ (instancetype)chickenFromRecord:(NSDictionary *)record;
{
    GPChicken *chicken = [[GPChicken alloc] initWithRecord:record];
    return chicken;
}

- (instancetype)initWithRecord:(NSDictionary *)record
{
    self = [self init];
    if (self) {
        self.exp = [record[@"exp"] floatValue];
        self.energy = [record[@"energy"] floatValue];
        self.vitamin = [record[@"vitamin"] floatValue];
        self.lastUpdatedAt = record[@"lastUpdatedAt"];
    }
    return self;
}


#pragma mark - Setters/Getters

- (GPChickenConfig *)config
{
    if (!_config) {
        _config = [GPGameConfig config].chickenConfig;
    }
    return _config;
}

- (void)setEnergy:(CGFloat)energy
{
    _energy = MAX(0.0, energy);
    _energy = MIN(self.config.energyBase + self.level * self.config.energyLevelScale, _energy);
}

- (CGFloat)energyProgress
{
    return self.energy / (self.config.energyBase + self.level * self.config.energyLevelScale);
}

- (void)setVitamin:(CGFloat)vitamin
{
    _vitamin = MAX(0.0, vitamin);
    _vitamin = MIN(self.config.vitaminBase + self.level * self.config.vitaminLevelScale, _vitamin);
}

- (CGFloat)vitaminProgress
{
    return self.vitamin / (self.config.vitaminBase + self.level * self.config.vitaminLevelScale);
}

- (void)setExp:(CGFloat)exp
{
    _exp = exp;
    [self leveling];
}

#pragma mark - Actions

- (BOOL)eat
{
    if (self.vitamin >= self.config.feedVitaminCost) {
        self.exp     += self.config.feedExpGet;
        self.energy  += self.config.feedEnergyGet;
        self.vitamin -= self.config.feedVitaminCost;
        [self updateWithSteps:0];
        return YES;
    }
    return NO;
}

- (void)updateWithSteps:(NSInteger)steps
{
    NSDate *curDate = [NSDate date];
    NSTimeInterval seconds = [curDate timeIntervalSinceDate:self.lastUpdatedAt];
    CGFloat diff = seconds * self.config.energyConsumeRate;
    NSLog(@"diff %@ energy %@ to %@\n vitamin %@", @(diff), @(self.energy), @(self.energy - diff), @(self.vitamin));
    self.energy -= diff;
    self.vitamin += steps;
    self.lastUpdatedAt = curDate;
}

- (void)leveling
{
    // XP_TO_LEVEL = (XP_BASE * CURRENT_LEVEL) ^ SCALE
    // CURRENT_LEVEL = (XP_TO_LEVEL ^ 1 / SCALE) / XP_BASE
    NSInteger nextLevel = pow(self.exp, 1 / self.config.expScale) / self.config.expBase;
    if (nextLevel != self.level) {
        self.level = nextLevel;
    }
}

- (NSDictionary *)record
{
    return @{ @"energy"  : @(self.energy),
              @"vitamin" : @(self.vitamin),
              @"exp"     : @(self.exp),
              @"lastUpdatedAt" : self.lastUpdatedAt};
}

@end