//
//  SetupLayer.h
//  myFirstApp
//
//  Created by David Zhang on 2012-12-16.
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




@interface SetupLayer : CCLayer
{    
    // IVars
    BOOL scrolled;
    CGSize winSize;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (nonatomic, strong)   CCTMXTiledMap *map;
@property (nonatomic, strong)      CCTMXLayer *tmxLayer;
@property (nonatomic, strong)         CCLayer *setupLayer;
@property (nonatomic, strong)         CCLayer *hudLayer;
@property (nonatomic, strong)          CCMenu *menu;
//@property (nonatomic, strong) SetupUnitDisplay *display;
@property (nonatomic)       CGPoint previous;

+ (CCScene *) scene;
@end
