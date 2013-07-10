//
//  Unit.h
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Defines.h"
#import "CCActions.h"
#import "UserSingleton.h"
#import "Buff.h"

@interface Attributes : NSObject
{
    @public
    int main;

    // Combat stats
    int damage; // from main stat
    int max_health; // standalone
    
    float phys_reduction; // from str
    float acurracy; // from agi
    float spell_pierce; // from int
    
    float phys_resist; // from str
    float evasion; // from agi
    float magic_resist; // from int
    
    // Primary stats (base not included)
    int strength;
    int agility;
    int intellegence;
    int bonus_hp;
    
    // Constants
    int base_hp;
    int base_dmg;
    int base_str;
    int base_agi;
    int base_int;
    int max_str;
    int max_agi;
    int max_int;
    
    // Other shit
    int lvlup_hp;
    int lvlup_str;
    int lvlup_agi;
    int lvlup_int;
    
    // fucking temp fix
    int speed;
    int rarity;
}
@property (nonatomic) int experience;

+ (id) attributesForType:(int)type stats:(NSDictionary *)stats;

- (void) scrollUpgrade:(NSDictionary *)stats;
- (void) lvlUpUpgrade;

- (int) getStr;
- (int) getAgi;
- (int) getInt;
@end

// Shortest Path
@interface ShortestPathStep : NSObject
{
	CGPoint position;
	int gScore;
	int hScore;
	ShortestPathStep *__unsafe_unretained parent;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, unsafe_unretained) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;
@end

@class Unit;

@protocol UnitDelegate <NSObject>
@required
- (BOOL)pressedButton:(int)action;
- (void)killMe:(Unit *)unit at:(CGPoint)position;
- (void)addSprite:(CCSprite *)sprite z:(int)z;
- (void)removeSprite:(CCSprite *)sprite;
- (void)actionDidFinish:(Unit *)unit;
@optional
- (void)levelUp:(Unit *)unit;
@end

@interface Unit : NSObject <BuffCasterDelegate,BuffTargetDelegate>
{
    @public
    // Static
    int type;
    int rarity;
    int value;
    int health;
    int speed;
        
    // negative states
    BOOL isStunned;
    BOOL isEnsnared;
    BOOL isFrozen;
    BOOL isStoned;
    BOOL isFocused;
    
    // positive states
    BOOL isDefending;
}

@property (nonatomic, strong)   CCSprite    *sprite;
@property (nonatomic, strong)   CCSpriteBatchNode *spriteSheet;
@property (assign)   id <UnitDelegate> delegate;
@property (nonatomic, strong)   CCMenu *menu;

@property (nonatomic, strong)   NSMutableArray *spOpenSteps;
@property (nonatomic, strong)   NSMutableArray *spClosedSteps;
@property (nonatomic, strong)   NSMutableArray *shortestPath;

@property (nonatomic, strong)   Attributes *attribute;
@property (nonatomic, strong)   NSMutableArray *myBuffs;
@property (nonatomic, strong)   NSMutableArray *buffs;
@property (nonatomic, strong)   NSMutableArray *runes;

@property (nonatomic) BOOL isOwned;
@property (nonatomic) BOOL canUpgrade;
@property (nonatomic) int experience;
@property (nonatomic) int level;
@property (nonatomic) int coolDown;
@property (nonatomic) int direction;

// init
- (id) initForSide:(BOOL)side withValues:(NSArray *)values;

// upgrades
- (void) scrollUpgrade:(NSDictionary *) stats experience:(int)xp;
- (void) runeUpgrade:(int) type;

// skills
- (void) action:(int)action at:(CGPoint)position;
- (void) popStepAndAnimate;
- (BOOL) canIDo:(int)action;

// combat + state
- (void) take:(int)damage after:(float)delay;
- (int) calculate:(int)damage type:(int)dmgType;
- (void) addBuff:(Buff *)buff caster:(BOOL)amICaster;
- (void) removeBuff:(Buff *)buff caster:(BOOL)amICaster;

// menu
- (void) toggleMenu:(BOOL)state;
- (void) reset;

// wow so annoying
- (float) getAngle:(CGPoint)p1 :(CGPoint)p2;
@end

