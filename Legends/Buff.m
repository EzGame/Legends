//
//  Buff.m
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import "Buff.h"
#import "Tile.h"

#pragma mark - NSMutableArray Weak (for delegation)
@implementation NSMutableArray (WeakReferences)

+ (id)mutableArrayUsingWeakReferences
{
    return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity
{
    // The two NULLs are for the CFArrayRetainCallBack and CFArrayReleaseCallBack methods.  Since they are
    // NULL no retain or releases sill be done.
    //
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    
    // We create a weak reference array
    return (__bridge id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

@end


#pragma mark - Buff
@implementation Buff
- (void) setDuration:(int)duration
{
    NSLog(@">TEST<  Buff setDuration");
    _duration = duration;
    if ( _duration == 0 ) {
        [self stop];
    }
}

- (id) init
{
    self = [super init];
    if ( self )
    {
        
    }
    return self;
}

- (BOOL) buffEffectOnEvent:(Event)event forUnit:(Unit *)unit
{
}

- (BOOL) buffEffectOnEvent:(Event)event forTile:(Tile *)tile
{
}

- (void) start
{
    NSLog(@">TEST<  Buff start");
    [self.target buffTargetStarted:self];
}

- (void) stop
{
    NSLog(@">TEST<  Buff stop");
    [self.target buffTargetFinished:self];
}
@end


#pragma mark - Blaze
@implementation BlazeBuff
+ (id) blazeBuffAtTarget:(id)target for:(int)duration damage:(int)damage
{
    return [[BlazeBuff alloc] initBlazeBuffAtTarget:target for:duration damage:damage];
}

- (id) initBlazeBuffAtTarget:(id)target for:(int)duration damage:(int)damage;
{
    self = [super init];
    if ( self )
    {
        _damage = damage;
        
        self.duration = duration;
        self.target = target;
    }
    return self;
}

- (BOOL) buffEffectOnEvent:(Event)event forUnit:(Unit *)unit
{
}

- (BOOL) buffEffectOnEvent:(Event)event forTile:(Tile *)tile
{
}

- (void) start
{
    NSLog(@">TEST<  Blaze Buff start");
    [super start];
}

- (void) stop
{
    NSLog(@">TEST<  Blaze Buff stop");
    [super stop];
}
@end


#pragma mark - Paralyze Buff
@implementation ParalyzeBuff

+ (id) paralyzeBuffFromCaster:(id)caster atTarget:(id)target
{
    return [[ParalyzeBuff alloc] initBuffFromCaster:caster atTarget:target];
}

- (id) initBuffFromCaster:(id)caster atTarget:(id)target
{
    self = [super init];
    if ( self )
    {
        self.caster = caster;
        self.target = target;
    }
    return self;
}

- (BOOL) buffEffectOnEvent:(Event)event forUnit:(Unit *)unit
{
}

- (void) start
{
    NSLog(@">TEST<  Paralyze Buff start");
    [super start];
    [self.caster buffCasterStarted:self];

}

- (void) stop
{
    NSLog(@">TEST<  Paralyze Buff end");
    [super stop];
    [self.caster buffCasterFinished:self];
}
@end



