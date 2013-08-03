//
//  CCActions.h
//  myFirstApp
//
//  Created by David Zhang on 2013-01-25.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"

// Others
#import "CCAction.h"

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

@interface CCActions : NSObject

@property (nonatomic, strong) CCAction          *action_NE;
@property (nonatomic, strong) CCAction          *action_SE;
@property (nonatomic, strong) CCAction          *action_SW;
@property (nonatomic, strong) CCAction          *action_NW;
@property (nonatomic) int tag;
- (id)initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                forAction:(int)action;

+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                   forAction:(int)action;

- (id)initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                  forName:(NSString *)name
                andFrames:(int)frames
                    delay:(float)delay
                  reverse:(BOOL)reverse;

- (id)initInfiniteWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                          forName:(NSString *)name
                        andFrames:(int)frames
                            delay:(float)delay;

+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                     forName:(NSString *)name
                   andFrames:(int)frames
                       delay:(float)delay
                     reverse:(BOOL)reverse;

+ (id)actionsInfiniteWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet
                             forName:(NSString *)name
                           andFrames:(int)frames
                               delay:(float)delay;

- (CCAction *) getActionFor:(int)direction;
@end
