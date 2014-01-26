//
//  UnitObject.m
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "UnitObject.h"

#pragma mark - Attribute Constants

/* @MOVETOSERVER */
// Level
//#define GETEXP(X)       25 * X * X
//#define GETLVL(X)       sqrt(X)/5
//#define MAXLEVEL        100
//#define MAXEXPERIENCE   250000
//#define MAXSKILLRANK    10
//#define STATSPERLVL     10

enum STATS_INDEX {
    MOVE_SPEED,
    UNIT_RARITY,
    NUM_STATS,
};
// Default Stats
const int priest_stats[NUM_STATS]     = {3, Common};
const int mudgolem_stats[NUM_STATS]   = {5, Uncommon};
const int gorgon_stats[NUM_STATS]     = {2, Rare};
const int dragon_stats[NUM_STATS]     = {6, Rare};

//const int gorgon_upgrades[]      = {       SAPPHIRE, RUBY, EMERALD, OPAL};
//const int mudgolem_upgrades[]    = {TOPAZ, SAPPHIRE, RUBY,          OPAL};
//const int dragon_upgrades[]      = {TOPAZ,           RUBY, EMERALD, OPAL};
//const int lionpriest_upgrades[]  = {TOPAZ, SAPPHIRE,       EMERALD, OPAL};
/* @MOVETOSERVER */


@implementation UnitObject
#pragma mark - Setters n Getters
#pragma mark - Inits
- (id) initWithString:(NSString *)string
{
    self = [super init];
    if ( self ) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        int tokenIndex = 0;
        
        // General
        _type = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _rarity = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _moveSpeed = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _position = CGPointFromString([tokens objectAtIndex:tokenIndex++]);
        
        // Stats
        _stats = [[StatObject alloc] init];
        _stats.strength = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.agility = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _stats.intellect = [[tokens objectAtIndex:tokenIndex++] integerValue];
        
        _augmentedStats = [[StatObject alloc] init];
        _augmentedStats.strength = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _augmentedStats.agility = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _augmentedStats.intellect = [[tokens objectAtIndex:tokenIndex++] integerValue];
        
        _heart = [[tokens objectAtIndex:tokenIndex++] integerValue];
        _augmentationCount = [[tokens objectAtIndex:tokenIndex++] integerValue];
    }
    return self;
}

#pragma mark - Other shit
- (void) augment:(Attribute)attribute for:(int)amount;
{
    if ( _augmentationCount >= UNIT_MAXAUGMENTATION_COUNT )
        return;
    
    if ( attribute == Strength ) {
        self.augmentedStats.strength += amount;
    } else if ( attribute == Agility ) {
        self.augmentedStats.agility += amount;
    } else if ( attribute == Intellect ) {
        self.augmentedStats.intellect += amount;
    } else {
        NSLog(@"UnitObject Augment: what the fuck?");
    }
    
    self.highestAttribute = Strength;
    for ( Attribute i = 1; i < 5; i++ ) {
        if ( [self.augmentedStats getStat:i] >
            [self.augmentedStats getStat:self.highestAttribute] )
            self.highestAttribute = i;
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d/%@/%@/%d/%d",
            self.type, self.rarity, self.moveSpeed, NSStringFromCGPoint(self.position),
            self.stats, self.heart, self.augmentationCount];
}
@end
