//
//  BattleLayer.h
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"
#import "AppDelegate.h"
#import "UserSingleton.h"
// Layers
#import "SetupLayer.h"
// Others
#import "BattleBrain.h"
#import "MatchObject.h"
#import "UnitDisplay.h"
#import "Constants.h"



@interface BattleLayer : CCLayer <BattleBrainDelegate>
{
    // Turn variables
    BOOL isMyTurn;
    TurnState turnState;

    // Variables
    BOOL scroll;
    CGSize winSize;
}

@property (nonatomic, strong)   CCTMXTiledMap *map;
@property (nonatomic, strong)     MatchObject *matchObj;
@property (nonatomic, strong)      CCTMXLayer *tmxLayer;
@property (nonatomic, strong)         CCLayer *gameLayer;
@property (nonatomic, strong)         CCLayer *hudLayer;

@property (nonatomic, strong) CCLabelBMFont *debug;

/*@property (nonatomic, strong) CCMenu *menu;//
@property (nonatomic, strong) CCMenu *turnMenu;
@property (nonatomic, strong) UnitDisplay *display;
*/
+ (CCScene *) sceneWithMatch:(MatchObject *)obj;
@end