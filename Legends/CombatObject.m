//
//  CombatObject.m
//  Legends
//
//  Created by David Zhang on 2014-01-02.
//
//

#import "CombatObject.h"

@implementation CombatObject
+ (id) combatObject
{
    return [[CombatObject alloc] init];
}

- (id) init
{
    self = [super init];
    if ( self ) {
        
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CombatObject> type:%d amount:%d",_type,_amount];
}
@end
