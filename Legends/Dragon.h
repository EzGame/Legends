//
//  Dragon.h
//  Legends
//
//  Created by David Zhang on 2013-06-27.
//
//

#import "Unit.h"
#import "Defines.h"
#import "CCActions.h"
#import "MenuItemSprite.h"
#import "cocos2d.h"

@interface Dragon : Unit
extern const NSString *DRAGON_TWO_DESP;
extern const NSString *DRAGON_ONE_DESP;
extern const NSString *DRAGON_MOVE_DESP;

@property (nonatomic, strong) CCActions *idle;
@property (nonatomic, strong) CCActions *move;
@property (nonatomic, strong) CCActions *moveEnd;
@property (nonatomic, strong) CCActions *fireball;
@property (nonatomic, strong) CCActions *flamebreath;

@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *fireballButton;
@property (nonatomic, strong) MenuItemSprite *flamebreathButton;

+ (id) dragonWithObj:(UnitObj *)obj;
+ (id) dragonForEnemyWithObj:(UnitObj *)obj;
+ (id) dragonForSetupWithObj:(UnitObj *)obj;

- (id) initDragonFor:(BOOL)side withObj:(UnitObj *)obj;
- (id) initDragonForSetupWithObj:(UnitObj *)obj;

- (CGPoint *) getFireballArea;
- (CGPoint *) getFireballEffect;
- (CGPoint *) getFlamebreathArea;
- (CGPoint *) getFlamebreathEffect;
@end
