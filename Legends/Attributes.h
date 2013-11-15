/////////////////////////////////////////////
//  Attributes.h
//  Legends
//
//  Created by David Zhang on 2013-08-08.
//
/////////////////////////////////////////////

#pragma mark - Imports
/* Global and Singletons */
#import "Defines.h"
#import "UserSingleton.h"
/* Data Objects */
#import "StatObject.h"

@interface Attributes : NSObject
{
    @private
    float physical_power;
    float physical_resistance;
    
    float range_power;
    float range_resistance;
    
    float magic_power;
    float magic_resistance;
    
    float heal_power;
    float heal_multiplier;
}

@property (nonatomic, weak, readonly) StatObject* stats;

@property (nonatomic)                         int strength;
@property (nonatomic)                         int agility;
@property (nonatomic)                         int intellect;
@property (nonatomic)                         int spirit;
@property (nonatomic)                         int health;

+ (id) attributesWithObject:(StatObject *)stats;

//- (float) getDamageMultiplierWithType:(int)type;

@end
/*#pragma mark - Attributes
@class Attributes;

@protocol AttributesDelegate <NSObject>
- (void) attributesDelegateMaximumHealth:(int)health;
- (void) attributesDelegateCurrentHealth:(int)health;
- (DamageObj *) attributesDelegateRequestObjWithSkillType:(int)skillType;
@end

@interface Attributes : NSObject
{
    // Strength
    float melee_physical_power;
    float physical_resistance;

    // Agility
    float range_physical_power;
    float physical_crit;
    
    // Intellect
    float spell_power;
    float spell_resistance;
    
    // Wisdom
    float heal_effectiveness;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic) int strength;
@property (nonatomic) int agility;
@property (nonatomic) int intellect;
@property (nonatomic) int wisdom;
@property (nonatomic) int max_health;
@property (nonatomic, weak) StatObj *original;

+ (id) attributesWithStats:(StatObj *)stats delegate:(id)delegate;

- (DamageObj *) damageCalculationForSkillType:(int)skillType
                              skillDamageType:(int)skillDamageType
                                   multiplier:(float)multiplier
                                       target:(Attributes *)target;
@end*/


