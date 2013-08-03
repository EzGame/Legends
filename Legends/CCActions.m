//
//  CCActions.m
//  myFirstApp
//
//  Created by David Zhang on 2013-01-25.
//
//

#import "CCActions.h"

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

@interface CCActions()
@property (nonatomic, strong) NSMutableArray    *frames_NE;
@property (nonatomic, strong) NSMutableArray    *frames_SE;
@property (nonatomic, strong) NSMutableArray    *frames_SW;
@property (nonatomic, strong) NSMutableArray    *frames_NW;

@property (nonatomic, strong) CCAnimation       *animation_NE;
@property (nonatomic, strong) CCAnimation       *animation_SE;
@property (nonatomic, strong) CCAnimation       *animation_SW;
@property (nonatomic, strong) CCAnimation       *animation_NW;
@end

@implementation CCActions
@synthesize tag = _tag;
@synthesize frames_NE = _frames_NE;
@synthesize frames_NW = _frames_NW;
@synthesize frames_SE = _frames_SE;
@synthesize frames_SW = _frames_SW;

@synthesize animation_NE = _animation_NE;
@synthesize animation_NW = _animation_NW;
@synthesize animation_SE = _animation_SE;
@synthesize animation_SW = _animation_SW;

@synthesize action_NE = _action_NE;
@synthesize action_NW = _action_NW;
@synthesize action_SE = _action_SE;
@synthesize action_SW = _action_SW;

- (void) setTag:(int)tag
{
    _tag = tag;
    _action_NE.tag = tag;
    _action_NW.tag = tag;
    _action_SE.tag = tag;
    _action_SW.tag = tag;
}

- (CCAction *) getActionFor:(int)direction
{
    if ( direction == NE ) return self.action_NE;
    else if ( direction == NW ) return self.action_NW;
    else if ( direction == SE ) return self.action_SE;
    else return self.action_SW;
}

+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay reverse:(BOOL)reverse
{
    return [[CCActions alloc] initWithSpriteSheet:spriteSheet forName:name andFrames:frames delay:delay reverse:reverse];
}

+ (id)actionsInfiniteWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay
{ 
    return [[CCActions alloc] initInfiniteWithSpriteSheet:spriteSheet forName:name andFrames:frames delay:delay];
}

- (id) initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forName:(NSString *)name andFrames:(int)frames delay:(float)delay reverse:(BOOL)reverse
{
    self = [super init];
    if ( self )
    {
        _frames_NE = [[NSMutableArray alloc] init];
        _frames_SE = [[NSMutableArray alloc] init];
        _frames_SW = [[NSMutableArray alloc] init];
        _frames_NW = [[NSMutableArray alloc] init];
        
        if ( !reverse ) {
            for (int i = 0; i < frames; i++) {
                [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
            }
            for (int i = 0; i < frames; i++) {
                [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
            }
        } else {
            for (int i = frames - 1; i >= 0; i--) {
                [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
            }
            for (int i = frames - 1; i >= 0; i--) {
                [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
            }
        }
        
        // Create the animation object
        _animation_NE = [[CCAnimation alloc]initWithSpriteFrames:_frames_NE delay:delay];
        _animation_SE = [[CCAnimation alloc]initWithSpriteFrames:_frames_SE delay:delay];
        _animation_SW = [[CCAnimation alloc]initWithSpriteFrames:_frames_SW delay:delay];
        _animation_NW = [[CCAnimation alloc]initWithSpriteFrames:_frames_NW delay:delay];
    
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
        _frames_NE = [[NSMutableArray alloc] init];
        _frames_SE = [[NSMutableArray alloc] init];
        _frames_SW = [[NSMutableArray alloc] init];
        _frames_NW = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < frames; i++) {
            [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NE_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SE_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_SW_%d.png",name,i]]];
        }
        for (int i = 0; i < frames; i++) {
            [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_NW_%d.png",name,i]]];
        }
        
        // Create the animation object
        _animation_NE = [[CCAnimation alloc]initWithSpriteFrames:_frames_NE delay:delay];
        _animation_SE = [[CCAnimation alloc]initWithSpriteFrames:_frames_SE delay:delay];
        _animation_SW = [[CCAnimation alloc]initWithSpriteFrames:_frames_SW delay:delay];
        _animation_NW = [[CCAnimation alloc]initWithSpriteFrames:_frames_NW delay:delay];
        
        // Create action to run
        _action_NE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NE]];
        _action_SE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SE]];
        _action_SW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SW]];
        _action_NW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NW]];
    }
    return self;
}

- (id)initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forAction:(int)action
{
    self = [super init];
    if ( self )
    {
        _frames_NE = [[NSMutableArray alloc] init];
        _frames_SE = [[NSMutableArray alloc] init];
        _frames_SW = [[NSMutableArray alloc] init];
        _frames_NW = [[NSMutableArray alloc] init];
        
        // Gather the list of frames
#if TEST
        /* #NOTE! For this example,
         * x - x+3    : idle
         * x+4 - x+11 : move
         * x+12 - x+17: attack
         * x+18 - x+23: death
         */
        if ( action == IDLE )
            for (int i = 25 ; i <= 192 ; i++ )
            {
                if ( i >= 25 && i <= 28 )
                    [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 73 && i <= 76 )
                    [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 121 && i <= 124 )
                    [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
                else if ( i >= 169 && i <= 172 )
                    [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
            }
        else if ( action == MOVE )
            for (int i = 25 ; i <= 192 ; i++ )
            {
                if ( i >= 29 && i <= 36 )
                    [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 77 && i <= 84 )
                    [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 125 && i <= 132 )
                    [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
                else if ( i >= 173 && i <= 180 )
                    [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
            }
        else if ( action == ATTK )
            for (int i = 25 ; i <= 192 ; i++ )
            {
                if ( i >= 37 && i <= 42 )
                    [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 85 && i <= 90 )
                    [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 133 && i <= 138 )
                    [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
                else if ( i >= 181 && i <= 186 )
                    [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
            }
        else if ( action == DEAD )
            for (int i = 25 ; i <= 192 ; i++ )
            {
                if ( i >= 43 && i <= 48 )
                    [_frames_NW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 91 && i <= 96 )
                    [_frames_NE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_0%d.gif", i]]];
                else if ( i >= 139 && i <= 144 )
                    [_frames_SE addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
                else if ( i >= 187 && i <= 192 )
                    [_frames_SW addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"minotaur_alpha_%d.gif", i]]];
            }
#else
#endif
        // Create the animation object
        _animation_NE = [[CCAnimation alloc]initWithSpriteFrames:_frames_NE delay:0.1f];
        _animation_SE = [[CCAnimation alloc]initWithSpriteFrames:_frames_SE delay:0.1f];
        _animation_SW = [[CCAnimation alloc]initWithSpriteFrames:_frames_SW delay:0.1f];
        _animation_NW = [[CCAnimation alloc]initWithSpriteFrames:_frames_NW delay:0.1f];
        
        /* #NOTE! Run _move_minotaur when need to move the bear
         * But make sure init has been run for Minotaur class
         */
        
        if ( action == ATTK || action == DEAD )
        {
            _animation_NE.restoreOriginalFrame = (action == DEAD)?false:true;
            _animation_SE.restoreOriginalFrame = (action == DEAD)?false:true;
            _animation_SW.restoreOriginalFrame = (action == DEAD)?false:true;
            _animation_NW.restoreOriginalFrame = (action == DEAD)?false:true;
            _action_NE = [[CCAnimate alloc]initWithAnimation:_animation_NE];
            _action_SE = [[CCAnimate alloc]initWithAnimation:_animation_SE];
            _action_SW = [[CCAnimate alloc]initWithAnimation:_animation_SW];
            _action_NW = [[CCAnimate alloc]initWithAnimation:_animation_NW];
        }
        else
        {
            _action_NE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NE]];
            _action_SE = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SE]];
            _action_SW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_SW]];
            _action_NW = [[CCRepeatForever alloc]initWithAction:[[CCAnimate alloc]initWithAnimation:_animation_NW]];
        }
    }
    return self;
}

+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forAction:(int)action
{
    return [[self alloc] initWithSpriteSheet:spriteSheet forAction:action];
}


@end
