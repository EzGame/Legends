//
//  SetupLayer.h
//  myFirstApp
//
//  Created by David Zhang on 2012-12-16.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"
// Layers
#import "BattleLayer.h"
// Other
#import "SetupBrain.h"
#import "Tile.h"
#import "UnitDisplay.h"

@interface SetupLayer : CCLayer <SetupBrainDelegate>
{
    CGPoint previous;
    
    // Camera variables
    BOOL scrolled;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (nonatomic, strong) CCTMXTiledMap *map;
@property (nonatomic, strong) CCTMXLayer *tmxLayer;
@property (nonatomic, strong) CCLayer *setupLayer;
@property (nonatomic, strong) CCLayer *hudLayer;

@property (nonatomic, strong) Tile *selection;

@property (nonatomic, strong) CCMenu *menu;
@property (nonatomic, strong) UnitDisplay *display;

+ (CCScene *) scene;
@end
