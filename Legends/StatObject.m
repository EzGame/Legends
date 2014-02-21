//
//  StatObject.m
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "StatObject.h"

@implementation StatObject
- (void) setStrength:(Attribute)strength
{
    _strength = strength;
    [self findHighest];
}

- (void) setAgility:(Attribute)agility
{
    _agility = agility;
    [self findHighest];
}

- (void) setIntellect:(Attribute)intellect
{
    _intellect = intellect;
    [self findHighest];
}

- (void) findHighest
{
    if ( _strength > _agility ) {
        if ( _strength > _intellect ) {
            _highestAttribute = &_strength;
        } else {
            _highestAttribute = &_intellect;
        }
    } else {
        if ( _agility > _intellect ) {
            _highestAttribute = &_agility;
        } else {
            _highestAttribute = &_intellect;
        }
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d",
            _strength, _agility, _intellect];
}
@end
