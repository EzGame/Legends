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


@interface CCActions : NSObject

@property (nonatomic, strong) CCAction          *action_NE;
@property (nonatomic, strong) CCAction          *action_SE;
@property (nonatomic, strong) CCAction          *action_SW;
@property (nonatomic, strong) CCAction          *action_NW;

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
