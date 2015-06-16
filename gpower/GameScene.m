//
//  GameScene.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import "sprites.h"

#import "GPSKButton.h"
#import "GameScene.h"

@interface GameScene ()
@property (nonatomic) SKTextureAtlas *atlas;
@property (nonatomic, strong) SKAction *sequence;
@property (nonatomic, strong) SKSpriteNode *chicken;
@property (nonatomic, strong) SKNode *gpowerBar;
@property (nonatomic, strong) SKNode *stepsBar;
@property (nonatomic, strong) GPSKButton *feedButton;
@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        [self initScene];
    }
    return self;
}

- (void)initScene
{
    self.atlas = [SKTextureAtlas atlasNamed:SPRITES_ATLAS_NAME];
    
    // load background image, and set anchor point to the bottom left corner (default: center of sprite)
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.size = self.scene.size;
    background.anchorPoint = CGPointMake(0, 0);
    // add the background image to the SKScene; by default it is added to position 0,0 (bottom left corner) of the scene
    [self addChild: background];
    
    self.chicken = ({
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:SPRITES_TEX_NORMAL_0001];
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 70);
        [self addChild:sprite];
        sprite;
    });
    
    self.gpowerBar = ({
        SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"bar_gpower"];
        node.anchorPoint = CGPointMake(0, 0);
        node.position = CGPointMake(10, self.frame.size.height - node.frame.size.height - 10);
        [self addChild:node];
        node;
    });
    
    self.stepsBar = ({
        SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"bar_steps"];
        node.anchorPoint = CGPointMake(0, 0);
        node.position = CGPointMake(self.frame.size.width - node.frame.size.width - 10,
                                    self.frame.size.height - node.frame.size.height - 10);
        [self addChild:node];
        node;
    });
    
    self.feedButton = ({
        GPSKButton *node = [[GPSKButton alloc] initWithImageNamedNormal:@"btn_feed_me" selected:nil];
        [node setTouchUpInsideTarget:self action:@selector(handleFeedButtonPressed:)];
        node.position = CGPointMake(CGRectGetMidX(self.frame), self.chicken.position.y - 250);
        [self addChild:node];
        node;
    });
    
    [self updateAnimation];
}

- (void)handleFeedButtonPressed:(id)sender
{
    SKAction *baseAnim = [SKAction animateWithTextures:SPRITES_ANIM_BLINK timePerFrame:0.3];
    SKAction *walkAnim = [SKAction sequence:@[baseAnim, baseAnim, baseAnim]];
    [self.chicken runAction:walkAnim];
}

//-(void)didMoveToView:(SKView *)view
//{
//    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    SKTextureAtlas *chickenAnimatedAtlas = [SKTextureAtlas atlasNamed:@"chicken1"];
//    
//    [self addChild:myLabel];
//}

- (void)updateAnimation
{
    SKAction *baseAnim = [SKAction animateWithTextures:SPRITES_ANIM_NORMAL timePerFrame:0.3];

    SKAction *walkAnim = [SKAction sequence:@[baseAnim, baseAnim, baseAnim]];
    
    // we define two actions to move the sprite from left to right, and back;
    SKAction *moveRight  = [SKAction moveToX:CGRectGetMaxX(self.frame) - self.chicken.size.width
                                    duration:walkAnim.duration];
    SKAction *moveLeft   = [SKAction moveToX:CGRectGetMinX(self.frame) + self.chicken.size.width
                                    duration:walkAnim.duration];
    
    // as we have only an animation with the CapGuy walking from left to right, we use a 'scale' action
    // to get a mirrored animation.
    SKAction *mirrorDirection  = [SKAction scaleXTo:1   y:1 duration:0.0];
    SKAction *resetDirection   = [SKAction scaleXTo:-1  y:1 duration:0.0];
    
    // Action within a group are executed in parallel:
    SKAction *walkAndMoveRight = [SKAction group:@[resetDirection,  walkAnim, moveRight]];
    SKAction *walkAndMoveLeft  = [SKAction group:@[mirrorDirection, walkAnim, moveLeft]];
    
    SKAction *sequenceAnim = [SKAction repeatActionForever:
                              [SKAction sequence:@[walkAndMoveRight, walkAndMoveLeft]]];
    [self.chicken runAction:sequenceAnim];
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
