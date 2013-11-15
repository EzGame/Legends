//
//  CustomActions.h
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//

#import "cocos2d.h"

#define CCSHAKE_EVERY_FRAME	0

@interface CCShake : CCActionInterval
{
    float shakeInterval;
    float nextShake;
    bool dampening;
    CGPoint startAmplitude;
    CGPoint amplitude;
    CGPoint last;
}

+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude;
+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening;
+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude shakes:(int)pshakeNum;
+ (id) actionWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening shakes:(int)pshakeNum;
- (id) initWithDuration:(ccTime)t amplitude:(CGPoint)pamplitude dampening:(bool)pdampening shakes:(int)pshakeNum;

@end