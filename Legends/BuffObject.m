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









@implementation RageBuff

+ (id) rageBuffTarget:(id)target
{
    return [[RageBuff alloc] initRageBuffTarget:target];
}

- (id) initRageBuffTarget:(id)target
{
    self = [super initWithTarget:target];
    if ( self ) {
        self.icon = [CCSprite spriteWithFile:@"icon_rage.png"];
        self.duration = 2;
    }
    return self;
}

- (void) onBuffAdded:(AttributesObject *)obj
{
    // change crit
    [self.target buffAnimationAdded:self];
}

- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj
{
    // ?
}

- (void) onBuffRemoved:(AttributesObject *)obj
{
    // remove crit change
    [self.target buffAnimationRemoved:self];
}

- (void) onReset
{
    [super onReset];
}

@end










@implementation ShieldBuff

+ (id) shieldBuffTarget:(id)target amount:(int)amount
{
    return [[ShieldBuff alloc] initShieldBuffTarget:target amount:amount];
}

- (id) initShieldBuffTarget:(id)target amount:(int)amount
{
    self = [super initWithTarget:target];
    if ( self ) {
        self.icon = [CCSprite spriteWithFile:@"icon-holyshield.png"];
        self.duration = -1;
        _amount = amount;
    }
    return self;
}

- (void) onBuffAdded:(AttributesObject *)obj
{
    [self.target buffAnimationAdded:self];
}

- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj
{
    if ( event == BuffEventDefense ) {
        if ( obj.type != CombatTypeHeal || obj.type != CombatTypePure ) {
            obj.amount = MAX(0, obj.amount - self.amount);
            self.amount -= obj.amount;
            if ( self.amount <= 0 ) {
                [self end];
            }
        }
    }
}

- (void) onBuffRemoved:(AttributesObject *)obj
{
    [self.target buffAnimationRemoved:self];
}

- (void) onReset
{
    [super onReset];
}
@end