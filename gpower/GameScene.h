//
//  GameScene.h
//  gpower
//

//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GPChicken;
@class PBJVision;
@class GameScene;

@protocol GameSceneDelegate <SKSceneDelegate>
- (void)gameSceneDidCameraButton:(GameScene *)scene;
@end

@interface GameScene : SKScene
@property (nonatomic, weak) id<GameSceneDelegate> delegate;
@property (nonatomic) GPChicken *gpChicken;
@property (nonatomic, weak) PBJVision *vision;

- (void)resumeGame;
- (void)saveGame;
@end
