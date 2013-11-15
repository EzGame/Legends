//
//  BattleLayer.h
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//

// Auto includes
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "cocos2d.h"
#import "Defines.h"
#import "AppDelegate.h"
#import "UserSingleton.h"
// Layers
#import "SetupLayer.h"
// Others
#import "Tile.h"
#import "BattleBrain.h"
#import "UnitDisplay.h"

#import "Constants.h"



@interface BattleLayer : CCLayer //<BattleBrainDelegate, UnitDelegate>
{
    // Turn variables
    BOOL unitLocked;
    BOOL isMyTurn;
    BOOL isTurnA;
    BOOL isTurnB;
    BOOL isTurnC;

    // Camera variables
    BOOL scroll;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
    CGSize winSize;
}

@property (nonatomic, strong)   CCTMXTiledMap *map;
@property (nonatomic, strong)      CCTMXLayer *tmxLayer;
@property (nonatomic, strong)         CCLayer *gameLayer;
@property (nonatomic, strong)         CCLayer *hudLayer;

@property (nonatomic, strong) CCLabelBMFont *debug;

/*@property (nonatomic, weak) Tile *selection;

@property (nonatomic, strong) CCMenu *menu;//
@property (nonatomic, strong) CCMenu *turnMenu;
@property (nonatomic, strong) UnitDisplay *display;
*/
+ (CCScene *) scene;
@end