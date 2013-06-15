//
//  Buff.m
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import "Buff.h"

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

- (void) turnEnd
{
    NSLog(@">[MYLOG] Entering Buff:turnEnded");
    self.duration -= 1;
}

- (void) somethingChanged:(id)target
{
    // Override me if other more than caster/target relationship
    return;
}

- (void) removeMyBuff:(id)target
{
    return;
}
@end
           
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
        self.duration = duration;
        self.caster = caster;
        self.target = target;
        _path = path; // has to be weak!!
    }
    return self;
}

- (void) somethingChanged:(id)target
{
    // end the debuff
}

- (void) removeMyBuff:(id)target
{
    // unstone the target
}

@end



