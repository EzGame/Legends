//
//  Attributes.m
//  Legends
//
//  Created by David Zhang on 2013-08-08.
//
//

#import "Attributes.h"

#define MAXSTAT (STATSPERLVL * MAXLEVEL)

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
        _delegate = delegate;
        [self setStrength:stats.strength];
        [self setAgility:stats.agility];
        [self setIntellect:stats.intellect];
        [self setWisdom:stats.wisdom];
        [self setMax_health:stats.health];
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

- (DamageObj *) damageCalculationForSkillType:(int)skillType multiplier:(float)multiplier target:(Attributes *)target
{
    int damage;
    BOOL isCrit = [self rollToCrit];
    if ( skillType == SkillTypeNormalHeal ) {
        damage = self.wisdom * multiplier * target->heal_effectiveness ;
        
    } else if ( skillType == SkillTypeNormalMagic ) {
        damage = self.intellect * multiplier * spell_power * ( 1 - target->spell_power );
        
    } else if ( skillType == SkillTypeNormalRange ) {
        damage = self.agility * multiplier * range_physical_power * ( 1 - physical_resistance );
        damage *= (isCrit)?2:1;
        
    } else if ( skillType == SkillTypeNormalMelee ) {
        damage = self.strength * multiplier * melee_physical_power * ( 1 - physical_resistance );
        damage *= (isCrit)?2:1;
        
    } else if ( skillType == SkillTypePureMagic ) {
        damage = self.intellect * multiplier;
        
    } else if ( skillType == SkillTypePureRange ) {
        damage = self.agility * multiplier;
        
    } else if ( skillType == SkillTypePureMelee ) {
        damage = self.strength * multiplier;
        
    } else {
        NSAssert(false, @">FATAL< UNKNOWN SKILL TYPE");
        
    }
    DamageObj *obj = [DamageObj damageObjWith:damage isCrit:isCrit];
    return obj;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"str:%d,agi:%d,int:%d,wis:%d,hp:%d",
            _strength, _agility, _intellect , _wisdom, _max_health];
}
@end

