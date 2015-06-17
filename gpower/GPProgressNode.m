//
//  GPProgressNode.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright © 2015 cardinalblue. All rights reserved.
//

#import "GPProgressNode.h"

@interface GPProgressNode ()
@property (nonatomic) SKSpriteNode *maskSprite;
@end

@implementation GPProgressNode
{
    CGSize _size;
}

- (instancetype)initWithImageNamed:(NSString *)imageNamed
{
    if (self = [super init]) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageNamed];
        _size = [sprite size];
        self.maskSprite = ({
            SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor]
                                                                  size:sprite.size];
            maskNode.anchorPoint = CGPointMake(0, 0);
            maskNode.position = CGPointMake(-_size.width / 2, -_size.height / 2);
            maskNode;
        });
        self.maskNode = self.maskSprite;
        [self addChild:sprite];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    self.maskSprite.size = ({
        CGSize s = _size;
        s.width = _size.width * progress;
        s;
    });
}

- (CGFloat)progress
{
    return self.maskNode.xScale;
}

@end
