//
//  BuffObject.m
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "BuffObject.h"

@implementation BuffObject
- (void) onBuffAdded:(AttributesObject *)obj{}
- (void) onBuffRemoved:(AttributesObject *)obj{}
- (void) onBuffInvoke:(BuffEvent)event{}
- (void) onReset
{
    self.duration--;
}
@end

@implementation GuardBuff
+ (id) guardBuff
{
    return [[GuardBuff alloc] init];
}

- (id) initGuardBuff
{
    self = [super init];
    if ( self ) {
        self.icon = [CCSprite spriteWithFile:@"icon_guard.png"];
        self.duration = -1;
    }
    return self;
}

- (void) onBuffAdded:(AttributesObject *)obj
{
    // does not add stats
}

- (void) onBuffRemoved:(AttributesObject *)obj
{
    // does not add stats
    [self.target buffToBeRemoved:self];
}

- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj
{
    if ( event == BuffEventDefense ) {
        // alternate params to make damage 0
        NSLog(@"Make damage 0");
        obj.amount = 0;
    }
}
@end