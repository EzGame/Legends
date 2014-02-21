///////////////////////////////////////////
//  Objects.h
//  Legends
//
//  Created by David Zhang on 2013-07-18.
//
///////////////////////////////////////////
#import "Defines.h"
#define MAX_SKILL_RANK 10
@class StatObj; @class UnitObj; @class DamageObj;


#pragma mark - Stat Object
@interface StatObj : NSObject
@property (nonatomic) int strength;
@property (nonatomic) int agility;
@property (nonatomic) int intellect;
@property (nonatomic) int wisdom;
@property (nonatomic) int health;

+ (id) statsWithStr:(int)str
                agi:(int)agi
               inte:(int)inte
                wis:(int)wis
                 hp:(int)hp;
@end


#pragma mark - Unit Object
@interface UnitObj : NSObject
{
    int levelup_str;
    int levelup_agi;
    int levelup_int;
    int levelup_wis;
    int levelup_hp;
    int max_level;
}

@property (nonatomic, strong)   StatObj         *stats;
@property (nonatomic, strong)   NSMutableArray  *skills;

@property (nonatomic)           int             type;
@property (nonatomic)           int             rarity;
@property (nonatomic)           int             experience;
@property (nonatomic)           int             level;
@property (nonatomic)           int             movespeed;

@property (nonatomic)           CGPoint         position;
@property (nonatomic)           BOOL            locked;

+ (id) unitObjWithString:(NSString *)string;

- (NSString *) userFunctionSkillUp:(int)skillType;
@end


#pragma mark - Damage Object
@interface DamageObj : NSObject
@property (nonatomic) int damage;
@property (nonatomic) int skillType;
@property (nonatomic) int skillDamageType;
@property (nonatomic) BOOL isCrit;
@property (nonatomic) BOOL isStun;
@property (nonatomic, copy) int (^calculateDamageBlock)(int damage);

+ (id) damageObjWith:(int)damage;
@end


#pragma mark - ScrollObj
@interface ScrollObj : NSObject
@property (nonatomic) int type;
@property (nonatomic) int experience;
@property (nonatomic, strong) StatObj *stats;

+ (id) scrollObjWithString:(NSString *)string;
@end