//
//  UnitAction.h
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//
#import "cocos2d.h"
#import "CCAction.h"
#import "GeneralUtils.h"

//typedef enum {
//    NE,
//    SE,
//    SW,
//    NW,
//}Direction;

@interface UnitAction : NSObject

@property (nonatomic, strong)  CCAction *action_NE;
@property (nonatomic, strong)  CCAction *action_SE;
@property (nonatomic, strong)  CCAction *action_SW;
@property (nonatomic, strong)  CCAction *action_NW;
@property (nonatomic)               int tag;

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

- (CCAction *) getActionFor:(Direction)direction;
@end