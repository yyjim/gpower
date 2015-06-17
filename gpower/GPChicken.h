//
//  GPChicken.h
//  gpower
//
//  Created by yyjim on 6/17/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPChicken : NSObject
@property (nonatomic) NSString *name;

@property (nonatomic) CGFloat energy;  // [0 -> 100]
@property (nonatomic) CGFloat vitamin; // [0 -> MAX]

@property (nonatomic) CGFloat exp;
@property (nonatomic) NSInteger level;

+ (instancetype)createNew;
+ (instancetype)chickenFromRecord:(NSDictionary *)record;

- (BOOL)eat;
- (void)updateWithSteps:(NSInteger)steps;

- (NSDictionary *)record;
@end
