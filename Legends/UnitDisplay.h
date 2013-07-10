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
// Other
#import "Tile.h"
/***************************************************************/
@interface UnitDisplay : CCNode
@property (nonatomic) CGPoint position;
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




/***************************************************************/
@interface CommandsDisplay : CCNode
{
    int maxCP;
    BOOL isOwner;
}
@property (nonatomic, strong) CCLabelBMFont *cpDisplay;
@property (nonatomic) int cpAmount;
@property (nonatomic) int cpGainPerTurn;
+ (id) commandsDisplayWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner;
- (id) initWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner;

- (void) turnEnded;
- (void) usedAmount:(int)amount;
- (BOOL) isOutOfPoints;
@end

