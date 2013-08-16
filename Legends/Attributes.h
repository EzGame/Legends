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
#import "Objects.h"


#pragma mark - Attributes
@class Attributes;

@protocol AttributesDelegate <NSObject>
- (void) attributesDelegateMaximumHealth:(int)health;
- (void) attributesDelegateCurrentHealth:(int)health;
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
                           multiplier:(float)multiplier
                               target:(Attributes *)target;
@end


