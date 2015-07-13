//
//  GameViewController.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//
#import <PBJVision/PBJVision.h>
#import <SpriteKit/SpriteKit.h>
#import <Tweaks/FBTweakViewController.h>

#import "GPChicken.h"
#import "GameViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface GameViewController ()
    <PBJVisionDelegate, GameSceneDelegate>
@end

@implementation GameViewController
{
    UIImageView *_imageView;
    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    PBJVision *_vision;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTweakNotification:)
                                                 name:FBTweakShakeViewControllerDidDismissNotification
                                               object:nil];
    
    // Configure the view.
//    self.view = [[SKView alloc] init];
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_imageView];
    
    SKView *skView = [[SKView alloc] initWithFrame:self.view.bounds];
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.allowsTransparency = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;

    [self setupVision];
    
    // Create and configure the scene.
    self.scene = ({
        GameScene *scene = [GameScene sceneWithSize:[UIScreen mainScreen].bounds.size];
        scene.delegate = self;
        scene.vision = _vision;
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene;
    });
    
//    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    
    _previewView = ({
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [UIColor clearColor];
        v.frame = self.view.bounds;
        v;
    });
    _previewLayer = [_vision previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    [self.view addSubview:_previewView];
    
    [skView presentScene:self.scene];
    [self.view addSubview:skView];
    
    [_vision startPreview];
}

- (void)setupVision
{
    PBJVision *vision        = [PBJVision sharedInstance];
    vision.delegate          = self;
    vision.cameraMode        = PBJCameraModePhoto;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode         = PBJFocusModeContinuousAutoFocus;
    vision.exposureMode      = PBJExposureModeAutoExpose;
    vision.outputFormat      = PBJOutputFormatStandard;
    vision.videoBitRate      = PBJVideoBitRate640x480;
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceFront]) {
        vision.cameraDevice = PBJCameraDeviceFront;
    }
    _vision = vision;
}

- (void)handleTweakNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:FBTweakShakeViewControllerDidDismissNotification]) {
        self.scene.gpChicken.config = [GPGameConfig config].chickenConfig;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - PBJVision

- (void)vision:(PBJVision * __nonnull)vision capturedPhoto:(nullable NSDictionary *)photoDict error:(nullable NSError *)error
{
    [vision stopPreview];
    UIImage *image = photoDict[PBJVisionPhotoThumbnailKey];
    _imageView.image = image;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view.superview drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(outImage, nil, nil, nil);
}

#pragma mark - Game Scene 

- (void)gameSceneDidCameraButton:(GameScene *)scene
{
    if (_imageView.image) {
        _imageView.image = nil;
        [_vision startPreview];
    } else {
        [[PBJVision sharedInstance] capturePhoto];
    }
}

@end
