//////////////////////////////////////////////
//
//  Unit.h
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//
//////////////////////////////////////////////


#pragma mark - Imports
/* Global and Singletons */
#import "Defines.h"
#import "UserSingleton.h"
/* Cocos2d Objects */
#import "cocos2d.h"
#import "CCActions.h"
/* Data Objects */
#import "Buff.h"
#import "Objects.h"
#import "Attributes.h"

#pragma mark - Classes
@class Unit;
@class UnitDamage;
@class ShortestPathStep;
@class SetupUnit;

#pragma mark - Unit Delegates
@protocol UnitDelegate <NSObject>
@required
- (BOOL) unitDelegatePressedButton:(int)action;
- (void) unitDelegateUnit:(Unit *)unit finishedAction:(int)action;
- (void) unitDelegateDisplayCombatMessage:(NSMutableString *)message
                               atPosition:(CGPoint)point
                                withColor:(ccColor3B)color
                                   isCrit:(BOOL)isCrit;

- (void) unitDelegateAddSprite:(CCSprite *)sprite z:(int)z;
- (void) unitDelegateRemoveSprite:(CCSprite *)sprite;
- (void) unitDelegateShakeScreen;
- (void) unitDelegateKillMe:(Unit *)unit at:(CGPoint)position;
- (void) unitDelegateUnit:(Unit *)unit updateLayer:(CGPoint)boardPos;
@end

#pragma mark - Unit
@interface Unit : CCNode
<BuffCasterDelegate,BuffTargetDelegate,AttributesDelegate>
{
    @public
    // negative states
    BOOL isStunned;
    BOOL isEnsnared;
    BOOL isFrozen;
    BOOL isStoned;
    BOOL isFocused;
    
    // positive states
    BOOL isDefending;
}

@property (nonatomic, assign)   id <UnitDelegate>   delegate;

@property (nonatomic, strong)   CCSprite            *sprite;
@property (nonatomic, strong)   CCSpriteBatchNode   *spriteSheet;
@property (nonatomic, strong)   CCMenu              *menu;
@property (nonatomic, strong)   CCAction            *death;
@property (nonatomic, strong)   CCProgressTimer     *health_bar;

@property (nonatomic, strong)   NSMutableArray      *spOpenSteps;
@property (nonatomic, strong)   NSMutableArray      *spClosedSteps;
@property (nonatomic, strong)   NSMutableArray      *shortestPath;

@property (nonatomic, strong)   Attributes          *attribute;
@property (nonatomic, strong)   UnitObj             *obj;
@property (nonatomic, strong)   NSMutableArray      *myBuffs;
@property (nonatomic, strong)   NSMutableArray      *buffs;

@property (nonatomic)           BOOL                isOwned;
@property (nonatomic)           int                 coolDown;
@property (nonatomic)           int                 direction;
@property (nonatomic)           CGPoint             boardPos;
@property (nonatomic)           int                 current_hp;
@property (nonatomic)           int                 maximum_hp;

// init
- (id) initForSide:(BOOL)side withObj:(UnitObj *)obj;
- (void) initEffects;

// skills
- (void) action:(int)action at:(CGPoint)position;
- (void) combatAction:(int)action targets:(NSArray *)targets;
- (void) popStepAndAnimate;
- (BOOL) canIDo:(int)action;

// combat + state
- (void) damageHealth:(DamageObj *)dmg;
- (void) healHealth:(DamageObj *)dmg;
- (void) receiveBuff:(Buff *)buff;
- (void) addBuff:(Buff *)buff caster:(BOOL)amICaster;
- (void) removeBuff:(Buff *)buff caster:(BOOL)amICaster;
- (BOOL) hasActionLeft;

// menu
- (void) toggleMenu:(BOOL)state;
- (void) reset;

 // wow so annoying
- (float) getAngle:(CGPoint)p1 :(CGPoint)p2;
- (int) getValue;
- (void) setDirectionWithDifference:(CGPoint)difference;
@end


#pragma mark - UnitDamage
@interface UnitDamage : NSObject
@property (nonatomic, weak)     Unit        *target;
@property (nonatomic, strong)   DamageObj   *damage;

+ (id) unitDamageTarget:(Unit *)target damage:(DamageObj *)damage;
@end


#pragma mark - ShortestPathStep
@interface ShortestPathStep : NSObject
{
	CGPoint position;
	int gScore;
	int hScore;
	ShortestPathStep *__unsafe_unretained parent;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGPoint boardPos;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, unsafe_unretained) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos boardPos:(CGPoint)bpos;
- (int)fScore;

@end


#pragma mark SetupUnit
@interface SetupUnit : CCNode
<AttributesDelegate>
{
    CCSprite *reserve;
    CCSprite *ready;
}
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic, strong) UnitObj *obj;
@property (nonatomic, strong) Attributes *attribute;
@property (nonatomic) int direction;

+ (id) setupUnitWithObj:(UnitObj *)obj;
- (int) getValue;

@end