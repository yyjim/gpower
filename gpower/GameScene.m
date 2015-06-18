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
#import <Tweaks/FBTweakViewController.h>
#import <Tweaks/FBTweakStore.h>

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
    <FBTweakViewControllerDelegate>
@property (nonatomic) SKTextureAtlas *atlas;
@property (nonatomic, strong) SKAction *sequence;
@property (nonatomic, strong) SKSpriteNode *chicken;
@property (nonatomic, strong) GPProgressNode *gpowerBar;
@property (nonatomic, strong) GPProgressNode *stepsBar;
@property (nonatomic, strong) GPSKButton *feedButton;
@property (nonatomic, strong) GPSKButton *musicButton;
@property (nonatomic, strong) GPSKButton *tweaksButton;
@property (nonatomic, strong) GPSKButton *energyButton;

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
        self.gpChicken = ({
            GPChicken *g;
            NSDictionary *record = [[NSUserDefaults standardUserDefaults] objectForKey:@"gpower_chicken_record"];
            if (record) {
                g = [GPChicken chickenFromRecord:record];
            } else {
                g = [GPChicken createNew];
            }
            g;
        });
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
        node.position = CGPointMake(CGRectGetMidX(self.frame), self.chicken.position.y - 200);
        [self addChild:node];
        node;
    });

    self.musicButton = ({
        GPSKButton *node = [[GPSKButton alloc] initWithImageNamedNormal:@"btn_music" selected:nil];
        [node setTouchUpInsideTarget:self action:@selector(handleMusicButtonPressed:)];
        node.position = CGPointMake(self.frame.size.width - 64, 64);
        [self addChild:node];
        node;
    });

    self.tweaksButton = ({
        GPSKButton *node = [[GPSKButton alloc] initWithImageNamedNormal:@"btn_settings" selected:nil];
        [node setTouchUpInsideTarget:self action:@selector(handleTweaksButtonPressed:)];
        node.position = CGPointMake(64, 64);
        [self addChild:node];
        node;
    });
    
    self.energyButton = ({
        GPSKButton *node = [[GPSKButton alloc] initWithImageNamedNormal:@"btn_energy" selected:nil];
        [node setTouchUpInsideTarget:self action:@selector(handleEnergyButtonPressed:)];
        node.position = CGPointMake(CGRectGetMidX(self.frame), 64);
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
    
    _backgroundPlayer = ({
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background_sound" withExtension:@"wav"];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
        player.numberOfLoops = -1; //-1 = infinite loop
        player;
    });
    
    [self updateSubviews];
    [self updateAnimation];
}

- (void)resumeGame
{
    self.view.paused = NO;
    self.chicken.paused = NO;
}

- (void)saveGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *record = [self.gpChicken record];
    [defaults setObject:record forKey:@"gpower_chicken_record"];
    [defaults synchronize];
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
    [self updateAnimation];
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
            [self.chicken removeAllActions];
            
            SKAction *baseAnim = [SKAction animateWithTextures:textures
                                                  timePerFrame:0.3];
            SKAction *moveY = [SKAction moveToY:CGRectGetMidY(self.frame) + 50 duration:0.3];
            SKAction *walkAnim = [SKAction sequence:@[moveY, baseAnim, baseAnim, baseAnim]];
            SKAction *block = [SKAction runBlock:^{
                [self updateAnimation];
            }];
            [self.chicken runAction:[SKAction sequence:@[walkAnim, block]]];
        }
    }
}

- (void)handleTweaksButtonPressed:(id)sender
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    UIViewController *visibleViewController = window.rootViewController;
    while (visibleViewController.presentedViewController != nil) {
        visibleViewController = visibleViewController.presentedViewController;
    }

    // Prevent double-presenting the tweaks view controller.
    if (![visibleViewController isKindOfClass:[FBTweakViewController class]]) {
        FBTweakStore *store = [FBTweakStore sharedInstance];
        FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:store];
        viewController.tweaksDelegate = self;
        [visibleViewController presentViewController:viewController animated:YES completion:NULL];
    }
}

- (void)handleEnergyButtonPressed:(id)sender
{
    [self.gpChicken updateWithSteps:100];
}

- (void)handleMusicButtonPressed:(id)sender
{
    if (_backgroundPlayer.playing) {
        [_backgroundPlayer pause];
    } else {
        [_backgroundPlayer play];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    if (self.gpChicken.level >= 1 && [self.chicken containsPoint:touchLocation]) {
        SKAction *select = [SKAction animateWithTextures:SPRITES_ANIM_8BITS_LV1_SELECT
                                            timePerFrame:0.3];
        [self.chicken removeAllActions];
        SKAction *moveY = [SKAction moveToY:CGRectGetMidY(self.frame) + 50 duration:0.3];
        SKAction *block = [SKAction runBlock:^{
            [self updateAnimation];
        }];
        SKAction *sound = [SKAction playSoundFileNamed:@"chicken-3.wav" waitForCompletion:YES];
        [self.chicken runAction:[SKAction group:@[sound, [SKAction sequence:@[moveY, select, select, block]]]]];
    }
}

- (void)updateAnimation
{
    NSArray *textures = [self animateTexturesForState:0];
    if (!textures) {
        return;
    }
    [self.chicken removeAllActions];
    SKAction *baseAnim = [SKAction animateWithTextures:textures timePerFrame:0.3];

    SKAction *jump = [SKAction moveBy:CGVectorMake(0, 15) duration:0.2];
    SKAction *walkAnim = [SKAction sequence:@[baseAnim, jump, [jump reversedAction], baseAnim]];
    
    // we define two actions to move the sprite from left to right, and back;
    SKAction *moveRight  = [SKAction moveToX:CGRectGetMaxX(self.frame) - 120
                                    duration:walkAnim.duration];
    SKAction *moveLeft   = [SKAction moveToX:CGRectGetMinX(self.frame) + 120
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
    
    [self saveGame];
}

- (void)updateSubviews
{
    self.gpowerBar.progress = self.gpChicken.energyProgress;
    self.stepsBar.progress = self.gpChicken.vitaminProgress;
    
    self.gpowerLabel.text = [@((NSInteger)ceil(self.gpChicken.energy)) stringValue];
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
}


#pragma mark - FBTweakViewControllerDelegate

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FBTweakShakeViewControllerDidDismissNotification
                                                        object:tweakViewController];
    [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
