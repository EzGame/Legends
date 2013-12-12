//
//  StatObject.m
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "StatObject.h"

@implementation StatObject
- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d/%d/%d",
            _strength, _agility, _intellect, _spirit, _health];
}

- (int) getStat:(Attribute)stat
{
    if ( stat == Strength ) {
        return self.strength;
    } else if ( stat == Agility ) {
        return self.agility;
    } else if ( stat == Intellect ) {
        return self.intellect;
    } else if ( stat == Spirit ) {
        return self.spirit;
    } else {
        return self.health;
    }
}
@end
