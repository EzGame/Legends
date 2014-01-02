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

/* NOTE! -
 * We can change the attributes here by
 */
- (void) setStrength:(int)strength
{
    _strength = strength;
    self.power = strength * ((main == Strength) ? 1.25 : 1.0);
}

- (void) setAgility:(int)agility
{
    _agility = agility;
    self.foresight = agility * ((main == Agility) ? 1.25 : 1.0);
}

- (void) setIntellect:(int)intellect
{
    _intellect = intellect;
    self.focus = intellect * ((main == Intellect) ? 1.25 : 1.0);
}

- (void) setSpirit:(int)spirit
{
    _spirit = spirit;
    heal_power = spirit;
    heal_multiplier = spirit;
}

- (void) setHealth:(int)health
{
    _health = health;
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
        [self setSpirit:stats.spirit + augmentation.spirit];
        [self setHealth:stats.health + augmentation.health];
    }
    return self;
}


#pragma mark - Calculators
- (float) powerBonus:(float)opPower
{
    float difference = self.power/opPower;
    
}

- (float) foresightBonus:(float)opforesight
{
    float difference = self.foresight/opforesight;
    
}

- (float) focusBonus:(float)opFocus
{
    float difference = self.focus/opFocus;
    
}

- (BOOL) strCalculation:(CombatObject *)ret with:(AttributesObject *)opAttributes
{
    float bonus = [self powerBonus:opAttributes.power];
//    ret.crushing = bonus * ret.damage;
    return NO;
}

- (BOOL) agiCalculation:(CombatObject *)ret with:(AttributesObject *)opAttributes
{
    float bonus = [self foresightBonus:opAttributes.foresight];
    ret.isMissed = arc4random() % ((int)bonus*100);
//    ret.isCritical = (bonus > 1.25) ? arc4random() % ((int)bonus*100 - 25) : NO;
    return NO;
}

- (BOOL) intCalculation:(CombatObject *)ret with:(AttributesObject *)opAttributes
{
    return NO;
}

@end
/*#define MAXSTAT (STATSPERLVL * MAXLEVEL)
 
 #pragma mark - Attributes:
 @implementation Attributes : NSObject
 @synthesize delegate    = _delegate;
 @synthesize strength    = _strength;
 @synthesize agility     = _agility;
 @synthesize intellect   = _intellect;
 @synthesize wisdom      = _wisdom;
 @synthesize max_health  = _max_health;
 @synthesize original    = _original;
 
 #pragma mark - Setters n Getters
 - (void) setDelegate:(id)delegate
 {
 _delegate = delegate;
 [delegate attributesDelegateMaximumHealth:_max_health];
 [delegate attributesDelegateCurrentHealth:_max_health];
 }
 
 - (void) setStrength:(int)strength
 {
 _strength = strength;
 melee_physical_power = 1 + ( strength / ( MAXSTAT * 1.0 ) );
 physical_resistance = ( strength * ( 3 * 1.25 / MAXSTAT ) ) /
 ( 1 + strength * ( 3 * 1.25 / MAXSTAT ) );
 }
 
 - (void) setAgility:(int)agility
 {
 _agility = agility;
 range_physical_power = 1 + ( agility / ( MAXSTAT * 2.0 ) );
 physical_crit = ( agility * ( 3 * 1.25 / MAXSTAT ) ) /
 ( 1 + agility * ( 3 * 1.25 / MAXSTAT ) );
 }
 
 - (void) setIntellect:(int)intellect
 {
 _intellect = intellect;
 spell_power = 1 + ( intellect / ( MAXSTAT * 2.0 ) );
 spell_resistance = ( intellect * ( 3 * 1.25 / MAXSTAT ) ) /
 ( 1 + intellect * ( 3 * 1.25 / MAXSTAT ) );
 
 }
 
 - (void) setWisdom:(int)wisdom
 {
 _wisdom = wisdom;
 heal_effectiveness = 1 + ( wisdom / ( MAXSTAT * 2.0 ) );
 }
 
 - (void) setMax_health:(int)max_health
 {
 _max_health = max_health;
 [self.delegate attributesDelegateMaximumHealth:max_health];
 }
 
 #pragma mark - Init n' shit
 + (id) attributesWithStats:(StatObj *)stats delegate:(id)delegate;
 {
 return [[Attributes alloc] initWithStats:stats delegate:delegate];
 }
 
 - (id) initWithStats:(StatObj *)stats delegate:(id)delegate;
 {
 self = [super init];
 if ( self )
 {
 [self setStrength:stats.strength];
 [self setAgility:stats.agility];
 [self setIntellect:stats.intellect];
 [self setWisdom:stats.wisdom];
 [self setMax_health:stats.health];
 [self setDelegate:delegate];
 _original = stats;
 }
 return self;
 }
 
 #pragma mark - Others
 - (BOOL) rollToCrit
 {
 double r = (double)arc4random() / ((double)UINT32_MAX + 1);
 return r < physical_crit;
 }
 
 - (DamageObj *) damageCalculationForSkillType:(int)skillType skillDamageType:(int)skillDamageType multiplier:(float)multiplier target:(Attributes *)target
 {
 int damage;
 DamageObj *obj = [self.delegate attributesDelegateRequestObjWithSkillType:skillType];
 if ( skillType == SkillDamageTypeNormalHeal ) {
 damage = self.wisdom * multiplier * target->heal_effectiveness ;
 
 } else if ( skillType == SkillDamageTypeNormalMagic ) {
 damage = self.intellect * multiplier * spell_power * ( 1 - target->spell_power );
 
 } else if ( skillType == SkillDamageTypeNormalRange ) {
 damage = self.agility * multiplier * range_physical_power * ( 1 - physical_resistance );
 
 } else if ( skillType == SkillDamageTypeNormalMelee ) {
 damage = self.strength * multiplier * melee_physical_power * ( 1 - physical_resistance );
 
 } else if ( skillType == SkillDamageTypePureMagic ) {
 damage = self.intellect * multiplier;
 
 } else if ( skillType == SkillDamageTypePureRange ) {
 damage = self.agility * multiplier;
 
 } else if ( skillType == SkillDamageTypePureMelee ) {
 damage = self.strength * multiplier;
 
 } else {
 NSAssert(false, @">FATAL< UNKNOWN SKILL TYPE");
 
 }
 return obj;
 }
 
 - (NSString *)description
 {
 return [NSString stringWithFormat:@"str:%d,agi:%d,int:%d,wis:%d,hp:%d",
 _strength, _agility, _intellect , _wisdom, _max_health];
 }
 @end*/

