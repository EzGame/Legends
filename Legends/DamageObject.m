//
//  DamageObject.m
//  Legends
//
//  Created by David Zhang on 2013-12-02.
//
//

#import "DamageObject.h"

@implementation DamageObject
+ (id) damageWithDmg:(int)damage
{
    return [[DamageObject alloc] initWithDmg:damage];
}

- (id) initWithDmg:(int)damage
{
    self = [super init];
    if ( self ) {
        _damage = damage;
    }
    return self;
}
@end
