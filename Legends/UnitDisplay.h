//
//  UnitDisplay.h
//  Legends
//
//  Created by David Zhang on 2013-02-14.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"
#import <SFS2XAPIIOS/SmartFox2XClient.h>
// Other
#import "Tile.h"
#import "Scale9Sprite.h"
/***************************************************************/
@interface UnitDisplay : CCNode
{
    CGPoint pos;
}
@property (nonatomic) CGPoint position;
@property (nonatomic, weak) Tile *tilePtr;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCLabelBMFont *nameLabel;

@property (nonatomic, strong) CCLabelBMFont *dmgLabel;
@property (nonatomic, strong) CCLabelBMFont *phy_defense;
@property (nonatomic, strong) CCLabelBMFont *mag_defense;

@property (nonatomic, strong) CCProgressTimer *hpBar;
@property (nonatomic, strong) CCLabelBMFont *currentHP;
@property (nonatomic, strong) CCLabelBMFont *maxHP;

- (id) initWithPosition:(CGPoint)position;
+ (id) displayWithPosition:(CGPoint)position;

- (void) setDisplayFor:(Tile *)tile;
- (void) setHPBar:(Tile *)tile;
@end

@interface OpponentDisplay : CCNode
{
    CGPoint pos;
}

- (id) initWithPos:(CGPoint)position withUser:(SFSUser *)user;
+ (id) displayWithPos:(CGPoint)position withUser:(SFSUser *)user;
@end


/***************************************************************/
@interface SetupUnitDisplay : CCNode
@property (nonatomic) CGPoint position;
//@property (nonatomic, weak) SetupTile *tilePtr;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCLabelBMFont *nameLabel;
@property (nonatomic, strong) CCLabelBMFont *description;

/*@property (nonatomic, strong) CCLabelBMFont *dmgLabel;
@property (nonatomic, strong) CCLabelBMFont *phy_defense;
@property (nonatomic, strong) CCLabelBMFont *mag_defense;

@property (nonatomic, strong) CCLabelBMFont *hp;*/

- (id) initWithPosition:(CGPoint)position;
+ (id) displayWithPosition:(CGPoint)position;

//- (void) setDisplayFor:(SetupTile *)tile;
- (void) setPosition:(CGPoint)position x:(BOOL)x y:(BOOL)y;
@end

