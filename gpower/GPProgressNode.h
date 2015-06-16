//
//  GPProgressNode.h
//  gpower
//
//  Created by yyjim on 6/16/15.
//  Copyright © 2015 cardinalblue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GPProgressNode : SKCropNode

@property (nonatomic) CGFloat progress;
- (instancetype)initWithImageNamed:(NSString *)imageNamed;

@end
