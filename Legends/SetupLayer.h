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
#import "HTCustomAutocompleteTextField.h"

@interface SetupLayer : CCLayer <SetupBrainDelegate,UITextFieldDelegate>
{    
    // Camera variables
    BOOL scrolled;
    CGPoint prevPos;
    
    // Others
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (nonatomic, strong) CCTMXTiledMap *map;
@property (nonatomic, strong) CCTMXLayer *tmxLayer;
@property (nonatomic, strong) CCLayer *setupLayer;
@property (nonatomic, strong) CCLayer *hudLayer;

//@property (nonatomic, weak) SetupTile *selection;
@property (nonatomic)       CGPoint previous;

@property (nonatomic, strong) CCMenu *menu;
@property (nonatomic, strong) SetupUnitDisplay *display;

@property (nonatomic, strong) HTUnitTagAutocompleteTextField *search;

+ (CCScene *) scene;
@end
