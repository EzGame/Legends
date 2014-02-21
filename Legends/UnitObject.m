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
//#define GETEXP(X)       25 * X * X
//#define GETLVL(X)       sqrt(X)/5
//#define MAXLEVEL        100
//#define MAXEXPERIENCE   250000
//#define MAXSKILLRANK    10
//#define STATSPERLVL     10

//enum STATS_INDEX {
//    MOVE_SPEED,
//    UNIT_RARITY,
//    NUM_STATS,
//};
//const int priest_stats[NUM_STATS]     = {3, Common};
//const int mudgolem_stats[NUM_STATS]   = {5, Uncommon};
//const int gorgon_stats[NUM_STATS]     = {2, Rare};
//const int dragon_stats[NUM_STATS]     = {6, Rare};

//const int gorgon_upgrades[]      = {       SAPPHIRE, RUBY, EMERALD, OPAL};
//const int mudgolem_upgrades[]    = {TOPAZ, SAPPHIRE, RUBY,          OPAL};
//const int dragon_upgrades[]      = {TOPAZ,           RUBY, EMERALD, OPAL};
//const int lionpriest_upgrades[]  = {TOPAZ, SAPPHIRE,       EMERALD, OPAL};

// TODO: Move to server

#pragma mark - Unit Constants
#define UNITSTR 0 #define UNITAGI 1 #define UNITINT 2
#define SKILLCD 0 #define SKILLMANA 1 #define SKILLCP 2 #define SKILLRANGE 3

const int UNITSTATS[][3] =
{
    {0, 0, 0},      // UnitTypeNone
    {0, 2, 4},      // UnitTypePriest
    {5, 1, 0},      // UnitTypeWarrior
    {0, 0, 6},      // UnitTypeWitch
    {1, 4, 1},      // UnitTypeRanger
    {8, 0, 0},      // UnitTypeKnight
    {4, 4, 0},      // UnitTypeBerserker
    {5, 0, 3},      // UnitTypePaladin
};

const int UNITSKILLS[][4] =
{
    {0, 0, 0, 0},      //
    {1, 0, 1, 3},      // Priest Move
    {3, 10, 2, 0},     // Priest Heal
    {1, 0, 1, 3},      // Ranger Move
    {1, 5, 1, 4},      // Ranger shoot
    {0, 0, 1, 3},      // Warrior Move
    {1, 3, 1, 1},      // Warrior Slash
    {1, 0, 1, 3},      // Witch Move
    {2, 10, 2, 0},     // Witch Wave
    {1, 0, 1, 3},      // Knight Move
    {1, 3, 1, 1},      // Knight Slash
    {0, 5, 1, 0},      // Knight Defend
    {0, 0, 1, 4},      // Berserker Move
    {1, 3, 1, 0},      // Berserker Slash
    {0, 5, 0, 0},      // Berserker Rage
    {1, 0, 1, 3},      // Paladin Move
    {2, 10, 2, 4},     // Paladin Smite
    {1, 5, 1, 3},      // Paladin Prot
};



@implementation UnitObject
#pragma mark - Inits n shit
+ (UnitObject *) createWithDict:(NSMutableDictionary *)dict
{
    return [[UnitObject alloc] initWithDict:dict];
}

- (id) initWithDict:(NSMutableDictionary *)dict
{
    self = [super init];
    if ( self ) {
        // General
        _type = [[dict objectForKey:@"type"] integerValue];
        _rarity = [[dict objectForKey:@"rarity"] integerValue];
        _rank = [[dict objectForKey:@"rank"] integerValue];
        
        // Position
        NSString *pos = [dict objectForKey:@"position"];
        _position = (pos == nil) ? CGPointMake(-1, -1) : CGPointFromString(pos);
        _isPositioned = (pos == nil) ? NO : YES;
        
        // Skills
        _actionMove = [dict objectForKey:@"action_move"];
        _actionSkillOne = [dict objectForKey:@"action_skill_one"];
        _actionSkillTwo = [dict objectForKey:@"action_skill_two"];
        _actionSkillThree = [dict objectForKey:@"action_skill_three"];
        
        // Stats
        _stats = [[StatObject alloc] init];
        _stats.strength = [[dict objectForKey:@"strength"] integerValue];
        _stats.agility = [[dict objectForKey:@"agility"] integerValue];
        _stats.intellect = [[dict objectForKey:@"intellect"] integerValue];
        
        // Rank
        NSMutableDictionary *upgrades = [dict objectForKey:@"upgrades"];
        [self applyUpgradesFromDict:upgrades];
        _dict = dict;
    }
    return self;
}

- (void) applyUpgradesFromDict:(NSMutableDictionary *)dict
{
    
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d/%@/%@/%d",
            self.type, self.rarity, self.rank, NSStringFromCGPoint(self.position),
            self.stats, self.isPositioned];
}

/* Old init */
//- (id) initWithString:(NSString *)string
//{
//    self = [super init];
//    if ( self ) {
//        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
//                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
//        
//        // General
//        _type = [[tokens objectAtIndex:0] integerValue];
//        _rarity = [[tokens objectAtIndex:1] integerValue];
//        _moveSpeed = [[tokens objectAtIndex:2] integerValue];
//        _position = CGPointFromString([tokens objectAtIndex:3]);
//        
//        // Stats
//        _stats = [[StatObject alloc] init];
//        _stats.strength = [[tokens objectAtIndex:4] integerValue];
//        _stats.agility = [[tokens objectAtIndex:5] integerValue];
//        _stats.intellect = [[tokens objectAtIndex:6] integerValue];
//        
//        _augmentedStats = [[StatObject alloc] init];
//        _augmentedStats.strength = [[tokens objectAtIndex:7] integerValue];
//        _augmentedStats.agility = [[tokens objectAtIndex:8] integerValue];
//        _augmentedStats.intellect = [[tokens objectAtIndex:9] integerValue];
//    }
//    return self;
//}

#pragma mark - Other shit
//- (void) augment:(Attribute)attribute for:(int)amount;
//{
//    if ( attribute == Strength ) {
//        self.augmentedStats.strength += amount;
//    } else if ( attribute == Agility ) {
//        self.augmentedStats.agility += amount;
//    } else if ( attribute == Intellect ) {
//        self.augmentedStats.intellect += amount;
//    } else {
//        NSLog(@"UnitObject Augment: what the fuck?");
//    }
//    
//    self.highestAttribute = Strength;
//    for ( Attribute i = 1; i < 5; i++ ) {
//        if ( [self.augmentedStats getStat:i] >
//            [self.augmentedStats getStat:self.highestAttribute] )
//            self.highestAttribute = i;
//    }
//}
@end
