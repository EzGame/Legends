//
//  UnitAction.m
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//

#import "UnitAction.h"

@interface UnitAction()

@property (nonatomic, strong) CCAnimation       *animation_NE;
@property (nonatomic, strong) CCAnimation       *animation_SE;
@property (nonatomic, strong) CCAnimation       *animation_SW;
@property (nonatomic, strong) CCAnimation       *animation_NW;
@end

@implementation UnitAction

+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay reverse:(BOOL)reverse
{
    return [[UnitAction alloc] initWithSpriteSheet:spriteSheet forName:name andFrames:frames delay:delay reverse:reverse];
}

+ (id)actionsInfiniteWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay
{
    return [[UnitAction alloc] initInfiniteWithSpriteSheet:spriteSheet forName:name andFrames:frames delay:delay];
}

- (id) initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay reverse:(BOOL)reverse
{
    self = [super init];
    if ( self )
    {
        NSMutableArray *frames_NE = [[NSMutableArray alloc] init];
        NSMutableArray *frames_NW = [[NSMutableArray alloc] init];
        NSMutableArray *frames_SE = [[NSMutableArray alloc] init];
        NSMutableArray *frames_SW = [[NSMutableArray alloc] init];
        
        if ( !reverse ) {
            for (int i = 0; i < frames; i++) {
                [frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
            }
        } else {
            for (int i = frames - 1; i >= 0; i--) {
                [frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
            }
        }
        
        // Create the animation object
        _animation_NE = [[CCAnimation alloc]initWithSpriteFrames:frames_NE delay:delay];
        _animation_SE = [[CCAnimation alloc]initWithSpriteFrames:frames_SE delay:delay];
        _animation_SW = [[CCAnimation alloc]initWithSpriteFrames:frames_SW delay:delay];
        _animation_NW = [[CCAnimation alloc]initWithSpriteFrames:frames_NW delay:delay];
        
        // Create action to run
        _action_NE = [[CCAnimate alloc]initWithAnimation:_animation_NE];
        _action_SE = [[CCAnimate alloc]initWithAnimation:_animation_SE];
        _action_SW = [[CCAnimate alloc]initWithAnimation:_animation_SW];
        _action_NW = [[CCAnimate alloc]initWithAnimation:_animation_NW];
    }
    return self;
}

- (id) initInfiniteWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay
{
    self = [super init];
    if ( self )
    {
        NSMutableArray *frames_NE = [[NSMutableArray alloc] init];
        NSMutableArray *frames_NW = [[NSMutableArray alloc] init];
        NSMutableArray *frames_SE = [[NSMutableArray alloc] init];
        NSMutableArray *frames_SW = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < frames; i++) {
            [frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
        }
        
        // Create the animation object
        _animation_NE = [[CCAnimation alloc]initWithSpriteFrames:frames_NE delay:delay];
        _animation_SE = [[CCAnimation alloc]initWithSpriteFrames:frames_SE delay:delay];
        _animation_SW = [[CCAnimation alloc]initWithSpriteFrames:frames_SW delay:delay];
        _animation_NW = [[CCAnimation alloc]initWithSpriteFrames:frames_NW delay:delay];
        
        // Create action to run
        _action_NE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NE]];
        _action_SE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SE]];
        _action_SW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SW]];
        _action_NW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NW]];
    }
    return self;
}

- (void) setTag:(int)tag
{
    _tag = tag;
    _action_NE.tag = tag;
    _action_NW.tag = tag;
    _action_SE.tag = tag;
    _action_SW.tag = tag;
}

- (CCAction *) getActionFor:(Direction)direction
{
    if ( direction == NE ) return self.action_NE;
    else if ( direction == NW ) return self.action_NW;
    else if ( direction == SE ) return self.action_SE;
    else return self.action_SW;
}

- (CCAnimation *) getAnimationFor:(Direction)direction
{
    if ( direction == NE ) return self.animation_NE;
    else if ( direction == NW ) return self.animation_NW;
    else if ( direction == SE ) return self.animation_SE;
    else return self.animation_SW;
}

@end