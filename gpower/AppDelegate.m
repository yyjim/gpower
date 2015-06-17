//
//  AppDelegate.m
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright (c) 2015 cardinalblue. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "GameViewController.h"
#import "GPChicken.h"
#import "GPPedometerManager.h"
#import "AppDelegate.h"

BOOL LogDebugEnabled = YES;

@interface AppDelegate ()
@property (nonatomic) GPPedometerManager *pedometerManager;

@end

@implementation AppDelegate

- (GameScene *)gameScene
{
    GameViewController *gameViewController = SAFE_CAST([GameViewController class], self.window.rootViewController);
    return gameViewController.scene;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];

    GameViewController *gameViewController = [[GameViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = gameViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];

    self.pedometerManager = [GPPedometerManager shared];
    [self.pedometerManager startDetectionWithUpdateBlock:nil];

    NSDictionary *record = [[NSUserDefaults standardUserDefaults] objectForKey:@"gpower_chicken_record"];
    if (record) {
        [self gameScene].gpChicken = [GPChicken chickenFromRecord:record];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[self gameScene].gpChicken updateWithSteps:self.pedometerManager.steps];
    self.pedometerManager.steps = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.pedometerManager stopDetection];
}

- (void)saveState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@(self.pedometerManager.steps) forKey:@"gpower_steps_count"];
    
    NSDictionary *record = [[self gameScene].gpChicken record];
    [defaults setObject:record forKey:@"gpower_chicken_record"];
    [defaults synchronize];
    NSLog(@"record %@", record);
}

// ============================================================================

//- (void)applicationWillResignActive:(UIApplication *)application
//{
//    
//    [locationManager stopMonitoringSignificantLocationChanges];
//    [locationManager startUpdatingLocation];
//    
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    BOOL isInBackground = NO;
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
//    {
//        isInBackground = YES;
//    }
//    
//    if (isInBackground)
//    {
//        [self sendBackgroundLocationToServer:newLocation];
//    }
//    
//}
//
//- (void)sendBackgroundLocationToServer:(CLLocation *)location
//{
//    UIApplication *application = [UIApplication sharedApplication];
//    
//    __block UIBackgroundTaskIdentifier background_task;
//    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
//        NSAssert(background_task == UIBackgroundTaskInvalid, nil);
//        [application endBackgroundTask: background_task];
//    }];
//    
//    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
////    CMAccelerometerData *_returnedData = [[CMAccelerometerData alloc] init];
//    CMMotionManager  *_motionManager = [[CMMotionManager alloc] init];
//    
//    [_motionManager startAccelerometerUpdatesToQueue:theQueue
//                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
//    {
//        CGFloat x = _motionManager.accelerometerData.acceleration.x;
//        CGFloat y = _motionManager.accelerometerData.acceleration.y;
//        CGFloat z = _motionManager.accelerometerData.acceleration.z;
//        
//        NSLog(@"X: %@, Y: %@, z: %@", @(x), @(y), @(z));
//        
//        //[self changeFilter:[HighpassFilter class]];
//        //[filter addAcceleration:acceleration];
//        const float violence = 1.20;
//        float magnitudeOfAcceleration = sqrt (x*x + y*y + z*z);
//        
//        //float magnitudeOfAcceleration = sqrt (filter.x*filter.x + filter.y * filter.y + filter.z * filter.z);
//        BOOL shake = magnitudeOfAcceleration > violence;
//        if (shake)
//        {
//            step++;
//            NSLog(@"---------------");
//        }
//        NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
//        NSLog(@"steps in background: %i",step );
//        
//        if([defalut objectForKey:@"Stepscounting"]){
//            int f = [[defalut objectForKey:@"Stepscounting"] intValue];
//            step+=f;
//        }
//        [defalut setObject:[NSString stringWithFormat:@"%i",step] forKey:@"Stepscounting"];
//    }];
//    
//    // AFTER ALL THE UPDATES, close the task
//    if (background_task != UIBackgroundTaskInvalid) {
//        [[UIApplication sharedApplication] endBackgroundTask:background_task];
//        background_task = UIBackgroundTaskInvalid;
//    }
//}

@end
