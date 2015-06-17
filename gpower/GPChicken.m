//
//  GPChicken.m
//  gpower
//
//  Created by yyjim on 6/17/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#define XP_BASE   100
#define XP_SCALE  1.1

#import "GPChicken.h"
@interface GPChicken ()
@property (nonatomic) NSDate *lastUpdatedAt;
@end

@implementation GPChicken

+ (instancetype)createNew
{
    GPChicken *chicken = [[GPChicken alloc] init];
    chicken.energy  = 50;
    chicken.vitamin = 100;
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

- (void)setEnergy:(CGFloat)energy
{
    _energy = MAX(0.0, energy);
    _energy = MIN(100.0, _energy);
}

- (void)setVitamin:(CGFloat)vitamin
{
    _vitamin = MAX(0.0, vitamin);
    _vitamin = MIN(200.0, _vitamin);
}

- (void)setExp:(CGFloat)exp
{
    _exp = exp;
    [self leveling];
}

- (BOOL)eat
{
    if (self.vitamin >= 10) {
        self.exp     += XP_BASE;
        self.energy  += 5;
        self.vitamin -= 10;
        [self updateWithSteps:0];
        return YES;
    }
    return NO;
}

- (void)updateWithSteps:(NSInteger)steps
{
    NSDate *curDate = [NSDate date];
    NSTimeInterval seconds = [curDate timeIntervalSinceDate:self.lastUpdatedAt];
    CGFloat diff = seconds * (10.0f / (24 * 60));
    NSLog(@"diff %@ energy %@ to %@\n vitamin %@", @(diff), @(self.energy), @(self.energy - diff), @(self.vitamin));
    self.energy -= diff;
    self.vitamin += steps;
    self.lastUpdatedAt = curDate;
}

- (void)leveling
{
    // XP_TO_LEVEL = (XP_BASE * CURRENT_LEVEL) ^ SCALE
    // CURRENT_LEVEL = (XP_TO_LEVEL ^ 1 / SCALE) / XP_BASE
    NSInteger nextLevel = pow(self.exp, 1 / XP_SCALE) / XP_BASE;
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