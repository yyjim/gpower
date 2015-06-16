//
//  GPProgressNode.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright © 2015 cardinalblue. All rights reserved.
//

#import "GPProgressNode.h"

@implementation GPProgressNode

- (instancetype)initWithImageNamed:(NSString *)imageNamed
{
    if (self = [super init]) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageNamed];
        self.maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor]
                                                     size:sprite.size];
        [self addChild:sprite];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    self.maskNode.xScale = progress;
}

- (CGFloat)progress
{
    return self.maskNode.xScale;
}

@end
