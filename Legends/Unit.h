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

/* Data Objects */
//#import "Buff.h"

#import "cocos2d.h"
#import "GeneralUtils.h"
#import "Constants.h"

#import "AttributesObject.h"
#import "UnitSkill.h"
#import "UnitAction.h"
#import "BuffObject.h"

#pragma mark - Classes
@class Unit;
@class ShortestPathStep;
@class SetupUnit;
@class Tile;

@protocol UnitDelegate <NSObject>
@optional
- (void) unit:(Unit *)unit didMoveTo:(CGPoint)position;
- (void) unit:(Unit *)unit didFinishAction:(UnitSkill *)action;
- (void) unit:(Unit *)unit wantsToPlace:(CCNode *)child;
- (void) unit:(Unit *)unit wantsUnitEffect:(CCNode *)child;
- (BOOL) unit:(Unit *)unit wishesToUse:(UnitSkill *)action;
@end

@interface Unit : CCNode <BuffObjectDelegate>
/* General Objects */
@property (nonatomic, strong, readonly)  UnitObject *object;
@property (nonatomic, strong)      AttributesObject *attributes;
@property (nonatomic, strong)              CCSprite *sprite;
@property (nonatomic, strong)              CCSprite *glowSprite;
@property (nonatomic, strong)     CCSpriteBatchNode *spriteSheet;
@property (nonatomic, strong)       CCProgressTimer *healthBar;
@property (nonatomic, strong)                CCMenu *menu;

@property (nonatomic, strong)        NSMutableArray *spOpenSteps;
@property (nonatomic, strong)        NSMutableArray *spClosedSteps;
@property (nonatomic, strong)        NSMutableArray *shortestPath;
@property (nonatomic, assign)                    id delegate;

/* In-game stats */
@property (nonatomic, strong)        NSMutableArray *buffList;
@property (nonatomic)                     Direction direction;
@property (nonatomic)                       CGPoint boardPos;
@property (nonatomic)                           int currentCD;
@property (nonatomic)                           int currentHP;
@property (nonatomic)                           int maximumHP;
@property (nonatomic)                           int moveSpeed;
@property (nonatomic)                          BOOL isOwned;
@property (nonatomic)                          BOOL isBusy;

/* Real time stats */
- (id)      initUnit:(UnitObject *)obj isOwned:(BOOL)owned;

- (void)    action:(Action)action targets:(NSMutableArray *)targets;

- (void)    combatSend:(CombatObject *)obj to:(Unit *)unit;
- (void)    combatReceive:(CombatObject *)obj;

- (void)    reset;
- (void)    openMenu;
- (void)    closeMenu;

/* Sub classing functions */
- (void)    playAnimation:(CCAnimation *)animation selector:(SEL)s;
- (void)    playAction:(CCAction *)action;
@end










#pragma mark - ShortestPathStep
@interface ShortestPathStep : NSObject
//{
//	CGPoint position;
//	int gScore;
//	int hScore;
//	ShortestPathStep *__unsafe_unretained parent;
//}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGPoint boardPos;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, unsafe_unretained) ShortestPathStep *parent;

- (id)initWithBoardPos:(CGPoint)pos;
- (int)fScore;

@end
/*
 [Elements WIP]
    fire      < water < lightning < earth < nature
    lightning < fire  < earth     < water < nature
 
 [Heart WIP]
    Every unit will have a different heart, individulism if you will. This heart will apply a gain to a stat and a loss to another. The gain/loss will be added to the stats you gain per level up. A static value is used over a % to provide more of a choice 
    Case: 
        + gain more strength for some loss in intellect VS
        % give you an optimal choice of losing your lowest stat and gaining your highest for maximization
 
 Mana
    Each skill will require a certain amount of mana to be used. Mana cost of skill will change with the spirit of the unit.
 
    during the game, mana will be given to the user. This mana pool will be constructed with the sprit of the units used by the character. The mana regen rate will be [10% WIP]. This provides a tradeoff strong skills vs high resources. Players must balance between power and MP to win the game.
 
 Cool down
    This is a static attribute that each skill has. When a unit uses said skill, the total cool down will be applied to the unit (e.g. +3 CD). Said unit will require 3 turns (starting from next turn) for the unit to be able to be used again.
 
 give every unit a uID (this is per game)
 */