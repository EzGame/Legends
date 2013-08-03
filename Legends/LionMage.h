//
//  LionMage.h
//  Legends
//
//  Created by David Zhang on 2013-07-16.
//
//

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

+ (id) lionmageWithObj:(UnitObj *)obj;
+ (id) lionmageForEnemyWithObj:(UnitObj *)obj;
+ (id) lionmageForSetupWithObj:(UnitObj *)obj;


- (id) initLionmageFor:(BOOL)side withObj:(UnitObj *)obj;
- (id) initLionmageForSetupWithObj:(UnitObj *)obj;
@end
