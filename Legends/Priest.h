//
//  Priest.h
//  Legends
//
//  Created by David Zhang on 2013-11-06.
//
//

#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"
#import "UnitAction.h"
#import "UnitButton.h"

@interface Priest : Unit
@property (nonatomic, strong) UnitAction *idle;
@property (nonatomic, strong) UnitAction *move;
@property (nonatomic, strong) UnitAction *heal;
@property (nonatomic, strong) UnitAction *cast;
@property (nonatomic, strong) UnitButton *moveButton;
@property (nonatomic, strong) UnitButton *healButton;
@property (nonatomic, strong) UnitButton *castButton;

+ (id) priest:(UnitObject *)object
      isOwned:(BOOL)owned;
@end

/*
 #import "Unit.h"
 #import "Defines.h"
 #import "CCActions.h"
 #import "MenuItemSprite.h"
 #import "cocos2d.h"
 
 @interface LionMage : Unit
 extern const NSString *LIONMAGE_ONE_DESP;
 extern const NSString *LIONMAGE_MOVE_DESP;
 
 @property (nonatomic, strong) CCActions *idle;
 @property (nonatomic, strong) CCActions *move;
 @property (nonatomic, strong) CCActions *heal;
 @property (nonatomic, strong) CCAction *healEffect;
 
 @property (nonatomic, strong) MenuItemSprite *moveButton;
 @property (nonatomic, strong) MenuItemSprite *healButton;
 
 + (id) lionmageForSide:(BOOL)side withObj:(UnitObj *)obj;
 - (id) initLionmageFor:(BOOL)side withObj:(UnitObj *)obj;
 @end
*/