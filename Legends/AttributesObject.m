//
//  AttributesObject.m
//  Legends
//
//  Created by David Zhang on 2013-08-08.
//
//

#import "AttributesObject.h"

@implementation AttributesObject
#pragma mark - Setters n Getters

- (void) setStrength:(int)strength
{
    // Set Primary
    _strength = strength;
    // Set Secondary
    self.meleeCrit = (self.intellect + 2 * self.strength)/3;
    self.meleeResist = (2 * self.intellect + self.strength)/3;
    self.meleeDefense = (self.agility + 2 * self.strength)/3;
    self.meleePierce = (2 * self.agility + self.strength)/3;
}

- (void) setAgility:(int)agility
{
    // Set Primary
    _agility = agility;
    // Set Secondary
    self.rangeCrit = (self.strength + 2 * self.agility)/3;
    self.rangeResist = (2 * self.strength + self.agility)/3;
    self.rangeDefense = (self.intellect + 2 * self.agility)/3;
    self.rangePierce = (2 * self.intellect + self.agility)/3;
}

- (void) setIntellect:(int)intellect
{
    // Set Primary
    _intellect = intellect;
    // Set Secondary
    self.spellCrit = (self.agility + 2 * self.intellect)/3;
    self.spellResist = (2 * self.agility + self.intellect)/3;
    self.spellDefense = (self.strength + 2 * self.intellect)/3;
    self.spellPierce = (2 * self.strength + self.intellect)/3;
}



#pragma mark - Init n shit
+ (id) attributesWithObject:(StatObject *)stats augment:(StatObject *)augmentation
{
    return [[AttributesObject alloc] initAttributesWithObject:stats augment:augmentation];
}

- (id) initAttributesWithObject:(StatObject *)stats augment:(StatObject *)augmentation
{
    self = [super init];
    if ( self ) {
        [self setStrength:stats.strength + augmentation.strength];
        [self setAgility:stats.agility + augmentation.agility];
        [self setIntellect:stats.intellect + augmentation.intellect];
        
        // These stats don't change with buffs;
        self.health = 3 * self.strength;
        self.experience = 3 * self.strength;
        self.mana = 3 * self.strength;
    }
    return self;
}



#pragma mark - Calculators
- (void) attackerCalculation:(CombatObject *)obj
{
    float critChance = 5.0f;
    if ( obj.type == CombatTypeStr ) {
        obj.amount += self.meleePierce;
        critChance += [self ratingToPercent:self.meleeCrit];
        
    } else if ( obj.type == CombatTypeAgi ) {
        obj.amount += self.rangePierce;
        critChance += [self ratingToPercent:self.rangeCrit];
        
    } else if ( obj.type == CombatTypeInt ) {
        obj.amount += self.spellPierce;
        critChance += [self ratingToPercent:self.spellCrit];
        
    }
    
    if ( arc4random() % 100 < critChance ) {
        obj.isCrit = YES;
        obj.amount *= 2;
    }
}

- (void) defenderCalculation:(CombatObject *)obj
{
    float resistChance = 5.0f;
    float defense;
    
    if ( obj.type == CombatTypeStr ) {
        defense = self.meleeDefense;
        resistChance += [self ratingToPercent:self.meleeResist];
        
    } else if ( obj.type == CombatTypeAgi ) {
        defense = self.rangeDefense;
        resistChance += [self ratingToPercent:self.rangeResist];
        
    } else if ( obj.type == CombatTypeInt ) {
        defense = self.spellDefense;
        resistChance += [self ratingToPercent:self.spellResist];
        
    }
    
    if ( arc4random() % 100 < resistChance ) {
        obj.isResist = YES;
        obj.amount *= 0.5;
    }
    
    obj.amount -= defense;
}

- (float) ratingToPercent:(float)aRating;
{
    // Rating influenced RNG will be calculated with a poly function
    float percent = 0.005 * powf(aRating, 2);
    return percent;
}
@end