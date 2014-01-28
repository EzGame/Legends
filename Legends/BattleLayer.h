//
//  BattleLayer.h
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//

// Auto includes
#import "Constants.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "UserSingleton.h"
#import "MatchObject.h"

// Others
#import "BattleBrain.h"
#import "PlayerResources.h"
#import "UnitDisplay.h"
#import "SetupLayer.h"




@interface BattleLayer : CCLayer <BattleBrainDelegate>
{
    // Turn variables
    BOOL isMyTurn;

    // Variables
    BOOL scroll;
    CGSize winSize;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (nonatomic, strong)   CCTMXTiledMap *map;
@property (nonatomic, strong)     MatchObject *matchObj;
@property (nonatomic, strong)      CCTMXLayer *tmxLayer;
@property (nonatomic, strong)         CCLayer *gameLayer;
@property (nonatomic, strong)         CCLayer *hudLayer;

@property (nonatomic, strong) PlayerResources *me;

@property (nonatomic, strong) CCLabelBMFont *debug;

/*@property (nonatomic, strong) CCMenu *menu;//
@property (nonatomic, strong) CCMenu *turnMenu;
@property (nonatomic, strong) UnitDisplay *display;
*/
+ (CCScene *) sceneWithMatch:(MatchObject *)obj;
@end