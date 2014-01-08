//
//  BuffObject.m
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "BuffObject.h"

@implementation BuffObject
- (id) initWithTarget:(id)target
{
    self = [super init];
    if ( self ) {
        self.target = target;
    }
    return self;
}

/* Calls from unit to buff */
- (void) onBuffAdded:(AttributesObject *)obj{}
- (void) onBuffRemoved:(AttributesObject *)obj{}
- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj{}
- (void) onReset
{
    self.duration--;
    if ( self.duration == 0 ) [self end];
}

/* Calls from anywhere */
- (void) start
{
    NSLog(@"%@ gained %@", self.target, self);
    [self.target buffNeedsToBeAdded:self];
}

- (void) end
{
    NSLog(@"%@ loses %@", self.target, self);
    [self.target buffNeedsToBeRemoved:self];
}
@end









@implementation GuardBuff
+ (id) guardBuffTarget:(id)target
{
    return [[GuardBuff alloc] initGuardBuffTarget:target];
}

- (id) initGuardBuffTarget:(id)target
{
    self = [super initWithTarget:target];
    if ( self ) {
        self.icon = [CCSprite spriteWithFile:@"icon_guard.png"];
        self.duration = -1;
    }
    return self;
}

- (void) onBuffAdded:(AttributesObject *)obj
{
    // does not add stats
    [self.target buffAnimationAdded:self];
    
}

- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj
{
    if ( event == BuffEventDefense ) {
        obj.amount = 0;
        // no invoke animation, we just end
        [self end];
    }
}

- (void) onBuffRemoved:(AttributesObject *)obj
{
    // does not add stats
    [self.target buffAnimationRemoved:self];
}

- (void) onReset
{
    [super onReset];
}
@end