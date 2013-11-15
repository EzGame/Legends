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
@end
