// ---------------------------------------
// Sprite definitions for sprites
// Generated with TexturePacker 3.8.0
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

#ifndef __SPRITES_ATLAS__
#define __SPRITES_ATLAS__

// ------------------------
// name of the atlas bundle
// ------------------------
#define SPRITES_ATLAS_NAME @"sprites"

// ------------
// sprite names
// ------------
#define SPRITES_SPR_BLINK_0001  @"blink/0001"
#define SPRITES_SPR_BLINK_0002  @"blink/0002"
#define SPRITES_SPR_NORMAL_0001 @"normal/0001"
#define SPRITES_SPR_NORMAL_0002 @"normal/0002"

// --------
// textures
// --------
#define SPRITES_TEX_BLINK_0001  [SKTexture textureWithImageNamed:@"blink/0001"]
#define SPRITES_TEX_BLINK_0002  [SKTexture textureWithImageNamed:@"blink/0002"]
#define SPRITES_TEX_NORMAL_0001 [SKTexture textureWithImageNamed:@"normal/0001"]
#define SPRITES_TEX_NORMAL_0002 [SKTexture textureWithImageNamed:@"normal/0002"]

// ----------
// animations
// ----------
#define SPRITES_ANIM_BLINK @[ \
        [SKTexture textureWithImageNamed:@"blink/0001"], \
        [SKTexture textureWithImageNamed:@"blink/0002"]  \
    ]

#define SPRITES_ANIM_NORMAL @[ \
        [SKTexture textureWithImageNamed:@"normal/0001"], \
        [SKTexture textureWithImageNamed:@"normal/0002"]  \
    ]


#endif // __SPRITES_ATLAS__
