//
//  GameScene.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <SOMotionDetector/SOStepDetector.h>
#import <CoreMotion/CoreMotion.h>

#import "sprites.h"

#import "GPPedometerManager.h"
#import "GPProgressNode.h"
#import "GPChicken.h"
#import "GPSKButton.h"
#import "GameScene.h"

//static NSString *kHeaderTitles[3] = {@ "ACCOUNT DETAILS", @ "SOCIAL NETWORK", @ "SETTINGS"};
//static int kNumbers[3] = {1, 2, 3};

static NSString *textureNameForState[2][2] = {
    {
        SPRITES_SPR_8BITS_LV0_NORMAL_0001,
        SPRITES_SPR_8BITS_LV1_NORMAL_0001,
    },
    {
        SPRITES_SPR_8BITS_LV0_NORMAL_0001,
        SPRITES_SPR_8BITS_LV1_HIGHLIGHT_0001,
    }
};

@interface GameScene ()
@property (nonatomic) SKTextureAtlas *atlas;
@property (nonatomic, strong) SKAction *sequence;
@property (nonatomic, strong) SKSpriteNode *chicken;
@property (nonatomic, strong) GPProgressNode *gpowerBar;
@property (nonatomic, strong) GPProgressNode *stepsBar;
@property (nonatomic, strong) GPSKButton *feedButton;

@property (nonatomic, strong) SKLabelNode *gpowerLabel;
@property (nonatomic, strong) SKLabelNode *stepsLabel;

@end

@implementation GameScene
{
    NSInteger _stepsCount;
    AVAudioPlayer *_backgroundPlayer;
}

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
    [[GPPedometerManager shared] addObserver:self
                                  forKeyPath:NSStringFromSelector(@selector(steps))
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
    
    self.atlas = [SKTextureAtlas atlasNamed:SPRITES_ATLAS_NAME];
    
    // load background image, and set anchor point to the bottom left corner (default: center of sprite)
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.size = self.scene.size;
    background.anchorPoint = CGPointMake(0, 0);
    [self addChild:background];
    //     add the background image to the SKScene; by default it is added to position 0,0 (bottom left corner) of the scene
    
    self.chicken = ({
        SKTexture *texture = [SKTexture textureWithImageNamed:textureNameForState[0][MIN(1, self.gpChicken.level)]];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 50);
        sprite.size = CGSizeMake(120, 120);
        [self addChild:sprite];
        sprite;
    });
    
    self.gpowerBar = ({
        // 65, 54.5
        GPProgressNode *node = [[GPProgressNode alloc] initWithImageNamed:@"bar_gpower"];
        node.position = CGPointMake(10 + 68, self.frame.size.height - 54.5 - 10);
        node.zPosition = 10;
        [self addChild:node];
        node;
    });
    
    self.stepsBar = ({
        GPProgressNode *node = [[GPProgressNode alloc] initWithImageNamed:@"bar_steps"];
        node.position = CGPointMake(self.frame.size.width - 10 - 68 - 10,
                                    self.frame.size.height - 54.5 - 10);
        node.zPosition = 10;
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
    
    self.stepsLabel = ({
        SKLabelNode *l = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
        l.text = @"0";
        l.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        l.fontSize = 20;
        l.position = CGPointMake(self.stepsBar.position.x - [self.stepsBar calculateAccumulatedFrame].size.width / 2,
                                 self.stepsBar.position.y - 60);
        [self addChild:l];
        l;
    });
    
    self.gpowerLabel = ({
        SKLabelNode *l = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
        l.text = @"0";
        l.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        l.fontSize = 20;
        l.position = CGPointMake(self.gpowerBar.position.x - [self.gpowerBar calculateAccumulatedFrame].size.width / 2,
                                 self.gpowerBar.position.y - 60);
        [self addChild:l];
        l;
    });
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateGPChicken)
                                   userInfo:nil
                                    repeats:YES];

#if 0
    _backgroundPlayer = ({
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background_sound" withExtension:@"wav"];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
        player.numberOfLoops = -1; //-1 = infinite loop
        [player play];
        player;
    });
#endif
    [self updateSubviews];
    [self updateAnimation];
}

#pragma mark - Setters/Getters

- (void)setGpChicken:(GPChicken *)gpChicken
{
    static NSArray *keypaths;
    if (!keypaths) {
        keypaths = @[NSStringFromSelector(@selector(energy)),
                     NSStringFromSelector(@selector(level)),
                     NSStringFromSelector(@selector(vitamin))];
    }
    
    [keypaths each:^(NSString *keyPath) {
        [_gpChicken removeObserver:self forKeyPath:keyPath];
    }];
    
    _gpChicken = gpChicken;
    
    [keypaths each:^(NSString *keyPath) {
        [_gpChicken addObserver:self
                     forKeyPath:keyPath
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }];
    
    [self updateSubviews];
//    [self updateAnimation];
}

#pragma mark - Handlers

- (NSArray *)animateTexturesForState:(NSInteger)state
{
    switch (self.gpChicken.level) {
        case 0:
            return state == 0 ? SPRITES_ANIM_8BITS_LV0_NORMAL : nil;
            break;
        case 1:
            return state == 0 ? SPRITES_ANIM_8BITS_LV1_NORMAL : SPRITES_ANIM_8BITS_LV1_HIGHLIGHT;
            break;
        default:
            break;
    }
    return state == 0 ? SPRITES_ANIM_8BITS_LV1_NORMAL : SPRITES_ANIM_8BITS_LV1_HIGHLIGHT;
}

- (void)handleFeedButtonPressed:(id)sender
{
    if ([self.gpChicken eat]) {
        NSArray *textures = [self animateTexturesForState:1];
        if (textures) {
            SKAction *baseAnim = [SKAction animateWithTextures:textures
                                                  timePerFrame:0.3];
            SKAction *walkAnim = [SKAction sequence:@[baseAnim, baseAnim, baseAnim]];
            if ([self.chicken hasActions]) {
                [self.chicken removeAllActions];                
            }
            SKAction *block = [SKAction runBlock:^{
                [self updateAnimation];
            }];
            [self.chicken runAction:[SKAction sequence:@[walkAnim, block]]];
        }
    }
}

-(void)didMoveToView:(SKView *)view
{
    /* Setup your scene here */
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
}

- (void)updateAnimation
{
    NSArray *textures = [self animateTexturesForState:0];
    if (!textures) {
        return;
    }
    SKAction *baseAnim = [SKAction animateWithTextures:textures timePerFrame:0.3];

    SKAction *jump = [SKAction moveBy:CGVectorMake(0, 15) duration:0.2];
    SKAction *walkAnim = [SKAction sequence:@[baseAnim, jump, [jump reversedAction], baseAnim]];
    
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

- (void)updateGPChicken
{
    [self.gpChicken updateWithSteps:[GPPedometerManager shared].steps];
    [GPPedometerManager shared].steps = 0;
}

- (void)updateSubviews
{
    CGFloat progress = self.gpChicken.energy / 100.0;
    self.gpowerBar.progress = progress;
    
    self.stepsBar.progress = ({
        self.gpChicken.vitamin / 200.0;
    });
    
    self.gpowerLabel.text = [@((NSInteger)self.gpChicken.energy) stringValue];
    self.stepsLabel.text  = [@((NSInteger)self.gpChicken.vitamin) stringValue];
    
    self.chicken.texture = [SKTexture textureWithImageNamed:textureNameForState[0][MIN(1, self.gpChicken.level)]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.gpChicken) {
        [self updateSubviews];
        return;
    }
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(steps))]) {
        id value = [change valueForKey:NSKeyValueChangeNewKey];
    }
}

@end
