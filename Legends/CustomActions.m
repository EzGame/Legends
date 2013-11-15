//
//  CustomActions.m
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//

#import "CustomActions.h"

@implementation CCShake

+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude
{
    return [self actionWithDuration:t amplitude:pamplitude dampening:true shakes:CCSHAKE_EVERY_FRAME];
}

+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening
{
    return [self actionWithDuration:t amplitude:pamplitude dampening:pdampening shakes:CCSHAKE_EVERY_FRAME];
}

+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude shakes:(int)pshakeNum
{
    return [self actionWithDuration:t amplitude:pamplitude dampening:true shakes:pshakeNum];
}

+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening shakes:(int)pshakeNum
{
    return [[self alloc] initWithDuration:t amplitude:pamplitude dampening:pdampening shakes:pshakeNum];;
}

- (id) initWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening shakes:(int)shakeNum
{
    if((self=[super initWithDuration:t]) != nil)
    {
        startAmplitude    = pamplitude;
        dampening    = pdampening;
        
        // calculate shake intervals based on the number of shakes
        if(shakeNum == CCSHAKE_EVERY_FRAME)
            shakeInterval = 0;
        else
            shakeInterval = 1.f/shakeNum;
    }
    
    return self;
}

- (id) copyWithZone: (NSZone*) zone
{
    CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] amplitude:amplitude dampening:dampening shakes:shakeInterval == 0 ? 0 : 1/shakeInterval];
    return copy;
}

- (void) startWithTarget:(CCNode *)aTarget
{
    [super startWithTarget:aTarget];
    
    amplitude    = startAmplitude;
    last        = CGPointZero;
    nextShake    = 0;
}

- (void) stop
{
    // undo the last shake
    [target_ setPosition:ccpSub(((CCNode*)target_).position, last)];
    
    [super stop];
}

- (void) update:(ccTime)t
{
    // waits until enough time has passed for the next shake
    if(shakeInterval == CCSHAKE_EVERY_FRAME)
    {} // shake every frame!
    else if(t < nextShake)
        return; // haven't reached the next shake point yet
    else
        nextShake += shakeInterval; // proceed with shake this time and increment for next shake goal
    
    // calculate the dampening effect, if being used
    if(dampening)
    {
        float dFactor = (1-t);
        amplitude.x = dFactor * startAmplitude.x;
        amplitude.y = dFactor * startAmplitude.y;
    }
    
    CGPoint new = ccp((CCRANDOM_0_1()*amplitude.x*2) - amplitude.x,(CCRANDOM_0_1()*amplitude.y*2) - amplitude.y);
    
    // simultaneously un-move the last shake and move the next shake
    [target_ setPosition:ccpAdd(ccpSub(((CCNode*)target_).position, last),new)];
    
    // store the current shake value so it can be un-done
    last = new;
}

@end
