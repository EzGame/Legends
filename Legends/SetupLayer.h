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
#import "SetupBrain.h"

// Others
#import "BattleBrain.h"
#import "PlayerResources.h"
#import "UnitDisplay.h"
#import "SetupSuppLayers.h"


enum SetupLayerState{
    SetupLayerStateIdle,
    SetupLayerStateSave,
};

@interface SetupLayer : CCLayer<SetupBrainDelegate, SetupUnitMenuLayerDelegate, SetupMenuLayerDelegate>
{    
    // IVars
    BOOL scrolled;
    CGSize winSize;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (nonatomic, strong)           CCTMXTiledMap *map;
@property (nonatomic, strong)              CCTMXLayer *tmxLayer;
@property (nonatomic, strong)                 CCLayer *setupLayer;
@property (nonatomic, strong)                 CCLayer *hudLayer;
@property (nonatomic, strong)                  CCMenu *menu;
@property (nonatomic, strong)          SetupMenuLayer *savedSetups;

@property (nonatomic, strong)           CCLabelBMFont *debug;


+ (CCScene *) scene;
@end
