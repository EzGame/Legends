//
//  Buff.m
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import "Buff.h"
#import "Tile.h"

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
@synthesize duration = _duration, hasBuffBeenRemoved = _hasBuffBeenRemoved;

- (id) init
{
    self = [super init];
    if ( self )
    {
        _hasBuffBeenRemoved = NO;
    }
    return self;
}

- (void) setDuration:(int)duration
{
    NSLog(@">[MYLOG] Entering Buff:setDuration:%d",duration);
    _duration = duration;
    if ( _duration == 0 ) {
        [self.caster buffCasterFinished:self];
        [self.target buffTargetFinished:self];
    }
}

- (void) reset
{
    NSLog(@">[RESET]    Buff:%@", self);
    self.duration -= 1;
}

// targets says something has happened
- (void) somethingChanged:(id)target
{
    // Override me if other more than caster/target relationship
    return;
}

// targets need buffs to end
- (void) removeMyBuff:(id)target
{
    return;
}

- (void) removeMyReferences
{
    _caster = nil;
    _target = nil;
}
@end



#pragma mark - Stone Gaze

@implementation StoneGazeDebuff
@synthesize path = _path;

+ (id) stoneGazeDebuffFromCaster:(id)caster atTarget:(id)target withPath:(NSMutableArray *)path for:(int)duration
{
    return [[StoneGazeDebuff alloc] initDebuffFromCaster:caster atTarget:target withPath:path for:duration];
}

- (id) initDebuffFromCaster:(id)caster atTarget:(id)target withPath:(NSMutableArray *)path for:(int)duration
{
    self = [super init];
    if ( self )
    {
        NSLog(@">[MYLOG] Creating freeze debuff from %@ to %@\n\
              Within %@", caster, target, path);
        self.duration = duration;
        self.caster = caster;
        self.target = target;
        [self.caster buffCasterStarted:self];
        [self.target buffTargetStarted:self];
        _path = path; // has to be weak!!
        //_path = [NSMutableArray mutableArrayUsingWeakReferences];
        for (id delegate in _path)
             [delegate buffTargetStarted:self];
    }
    return self;
}

- (void) somethingChanged:(id)target
{
    NSLog(@">[MYLOG] StoneGazeDebuff:somethingChanged");
    // Basically, if anything changes to any of the targets, we cancel the buff
    [self.caster buffCasterFinished:self];
    [self.target buffTargetFinished:self];
    for ( id delegate in self.path ) {
        [delegate buffTargetFinished:self];
    }
}

- (void) removeMyBuff:(id)target
{
    NSLog(@">[MYLOG] StoneGazeDebuff:removeMyBuff");
    if ( [target isEqual:self.caster] ) {
        [self somethingChanged:nil];
    }
}

- (void) removeMyReferences
{
    NSLog(@">[MYLOG] StoneGazeDebuff:removeMyReferences");
    [super removeMyReferences];
    [_path removeAllObjects];
}
@end



#pragma mark - Blaze

@implementation BlazeDebuff
@synthesize targets = _targets;

+ (id) blazeDebuffFromCaster:(id)caster atTargets:(NSMutableArray *)targets for:(int)duration damage:(int)damage
{
    return [[BlazeDebuff alloc] initBlazeDebuffFromCaster:caster atTargets:targets for:duration damage:damage];
}

- (id) initBlazeDebuffFromCaster:(id)caster atTargets:(NSMutableArray *)targets for:(int)duration damage:(int)damage
{
    self = [super init];
    if ( self )
    {
        NSLog(@">[MYLOG] Creating Blaze debuff from %@\n\
              Within %@ for dmg %d", caster, targets, damage);
        dmg = damage;
        self.duration = duration;
        
        self.caster = caster;
        self.targets = targets;
        
        [self.caster buffCasterStarted:self];
        for ( id delegate in self.targets )
            [delegate buffTargetStarted:self];
    }
    return self;
}

- (void) somethingChanged:(id)target
{
    NSLog(@">[MYLOG] BlazeDebuff:somethingChanged! %@",target);
}

- (void) removeMyBuff:(id)target
{
    NSLog(@">[MYLOG] BlazeDebuff:removeMyBuff! %@", target);
}

- (void) removeMyReferences
{
    NSLog(@">[MYLOG] BlazeDebuff:removeMyReferences");
    [super removeMyReferences];
    [_targets removeAllObjects];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Blaze"];
}

- (void) reset
{
    [super reset];
    for ( id delegate in self.targets ) {
        [delegate damage:dmg type:SkillTypePureMagic fromBuff:self fromCaster:self.caster];
    }
}
@end



