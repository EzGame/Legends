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
#import "Buff.h"

@interface Attributes : NSObject
{
    @public
    int main;

    // Combat stats
    int damage; // from main stat
    int max_health; // from str
    float acurracy; // from agi
    float spell_pierce; // from int
    
    float phys_resist; // from str
    float evasion; // from agi
    float magic_resist; // from int
    
    // Primary stats (base not included)
    int strength;
    int agility;
    int intellegence;
    
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
    int lvlup_str;
    int lvlup_agi;
    int lvlup_int;
}
@property (nonatomic) int experience;

+ (id) attributesForType:(int)type stats:(NSDictionary *)stats;

- (void) scrollUpgrade:(NSDictionary *)stats;
- (void) lvlUpUpgrade;
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
- (BOOL)pressedButton:(int)action turn:(int)cost;
- (void)kill:(CGPoint)position;
- (void)addSprite:(CCSprite *)sprite z:(int)z;
@optional
- (void)upgraded:(Unit *)unit;
@end

@interface Unit : NSObject <BuffCasterDelegate,BuffTargetDelegate>
{
    @public
    // Static
    int type;
    int value;
    int speed;
    
    // Runtime
    int facingDirection;
    
    // states
    BOOL isStunned;
    BOOL isEnsnared;
    BOOL isFrozen;
    BOOL isFocused;
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
@property (nonatomic) int rarity_level;
@property (nonatomic) int experience;

// init
- (id) initForSide:(BOOL)side withValues:(NSArray *)values;

// upgrades
- (void) scrollUpgrade:(NSDictionary *) stats experience:(int)xp;
- (void) runeUpgrade:(int) type;

// skills
- (void) action:(int)action at:(CGPoint)position;
- (NSArray *) getAttkArea:(CGPoint)position;
- (void) popStepAndAnimate;

// combat + state
- (void) addBuff:(Buff *)buff myBuff:(BOOL)isMyBuff;
- (void) take:(int)damage;
- (int) calculate:(int)damage;

// menu
- (void) toggleMenu:(BOOL)state;
- (void) undoLastButton;
- (void) reset;
@end

