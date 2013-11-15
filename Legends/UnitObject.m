//
//  UnitObject.m
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "UnitObject.h"

#pragma mark - Attribute Constants
// Level
#define GETEXP(X)       25 * X * X
#define GETLVL(X)       sqrt(X)/5
#define MAXLEVEL        100
#define MAXEXPERIENCE   250000
#define MAXSKILLRANK    10
#define STATSPERLVL     10
// Stats
#define LVLUP_STR       0
#define LVLUP_AGI       1
#define LVLUP_INT       2
#define LVLUP_SPR       3
#define LVLUP_HP        4
#define MOVESPEED       5
#define UNITRARITY      6
#define STATS_LASTINDEX 7
// Default Stats
const int priest_stats[STATS_LASTINDEX]     = {1, 1, 1, 1, 1, 10, Common};
const int mudgolem_stats[STATS_LASTINDEX]   = {1, 1, 1, 1, 1, 10, Uncommon};
const int gorgon_stats[STATS_LASTINDEX]     = {1, 1, 1, 1, 1, 10, Rare};
const int dragon_stats[STATS_LASTINDEX]     = {1, 1, 1, 1, 1, 10, Rare};

const int gorgon_upgrades[]      = {       SAPPHIRE, RUBY, EMERALD, OPAL};
const int mudgolem_upgrades[]    = {TOPAZ, SAPPHIRE, RUBY,          OPAL};
const int dragon_upgrades[]      = {TOPAZ,           RUBY, EMERALD, OPAL};
const int lionpriest_upgrades[]  = {TOPAZ, SAPPHIRE,       EMERALD, OPAL};

@implementation UnitObject
@synthesize type        = _type;
@synthesize experience  = _experience;
@synthesize level       = _level;
@synthesize stats       = _stats;
@synthesize position    = _position;

#pragma mark - Setters n Getters
- (void) setExperience:(int)experience
{
    _experience = MIN(MAXEXPERIENCE,experience);
    [self setLevel:GETLVL(experience)];
}

- (void) setLevel:(int)level
{
    int difference = level - _level;
    if ( difference > 0 ) {
        for ( int i = difference; i > 0; i-- ) [self levelup];
    }
    _level = MIN(MAXLEVEL,level);
}

#pragma mark - Inits
- (id) initWithString:(NSString *)string
{
    self = [super init];
    if ( self ) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        //int dataCount = [tokens count]; // 1 skill = 13, 2 = 18 etc
        int tokenIndex = 0;
        
        // Type
        _type = [[tokens objectAtIndex:tokenIndex++] integerValue];
        
        // Exp + Lvl
        _experience = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _level = GETLVL(_experience);
        
        // Stats
        _stats = [[StatObject alloc] init];
        _stats.strength = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.agility = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.intellect = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.spirit = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.health = [[tokens objectAtIndex:tokenIndex++] integerValue];
        
//        // Skills
//        for ( int i = tokenIndex; i + 5 < dataCount; i+=5 ) {
//            SkillObj *skill = [SkillObj skillWithType:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                                level:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                                 rank:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                          costOfSkill:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                           multiplier:[[tokens objectAtIndex:tokenIndex++] floatValue]];
//            [_skills addObject:skill];
//        }
        
        
        // Position
        _position = CGPointFromString ([tokens objectAtIndex:tokenIndex++]);
        
        // locked
        //_locked = [[tokens objectAtIndex:tokenIndex++] boolValue];
        
        //NSAssert(tokenIndex != dataCount - 1, @">[FATAL]    Unit Object dataCount!=tokens!!!");
        
        NSLog(@">[MYLOG]    Created UnitObject:\n%@",self);
    }
    return self;
}

#pragma mark - Other shit
- (void) setup:(const int *)array
{
    levelup_str = array[LVLUP_STR];
    levelup_agi = array[LVLUP_AGI];
    levelup_int = array[LVLUP_INT];
    levelup_spr = array[LVLUP_SPR];
    levelup_hp = array[LVLUP_HP];
    rarity = array[UNITRARITY];
    
//    if      ( _rarity == Common ) max_level = 40;
//    else if ( _rarity == Uncommon ) max_level = 50;
//    else if ( _rarity == Rare ) max_level = 60;
//    else if ( _rarity == Epic ) max_level = 70;
    
    for ( int i = 0; i <= UNITRARITY; ++i )
        NSLog(@"%i", array[i]);
}

- (void) levelup
{
    self.stats.strength += levelup_str;
    self.stats.agility += levelup_agi;
    self.stats.intellect += levelup_int;
    self.stats.spirit += levelup_spr;
    self.stats.health += levelup_hp;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d/%@/%@",
            self.type, self.experience, self.level,
            self.stats,
            NSStringFromCGPoint(self.position)];
}

@end
