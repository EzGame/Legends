//
//  LionMage.m
//  Legends
//
//  Created by David Zhang on 2013-07-16.
//
//
#define LIONMAGESCALE 1
#define LIONMAGESETUPSCALE LIONMAGESCALE * SETUPMAPSCALE
#import "LionMage.h"


@implementation LionMage
const NSString *LIONMAGE_MOVE_DESP = @"-";
const NSString *LIONMAGE_ONE_DESP = @"Heal all";

@synthesize idle            = _idle;
@synthesize move            = _move;
@synthesize heal            = _heal;
@synthesize moveButton      = _moveButton;
@synthesize healButton      = _healButton;
@synthesize healEffect      = _healEffect;
/* Unit Synthesizes */
@synthesize direction       = _direction;
@synthesize position        = _position;


#pragma mark - Setters and getters
- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    self.sprite.position = [self convertToNodeSpace:position];
}

- (CGPoint) position
{
    return [super position];
}

- (void) setDirection:(int)direction
{
    if ( direction == NE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_NE_0.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_NW_0.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_SW_0.png"]];
    else
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_SE_0.png"]];
    _direction = direction;
}


#pragma mark - Alloc n Init
+ (id) lionmageForSide:(BOOL)side withObj:(UnitObj *)obj;
{
    return [[LionMage alloc] initLionmageFor:side withObj:obj];
}

- (id) initLionmageFor:(BOOL)side withObj:(UnitObj *)obj;
{
    self = [super initForSide:side withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lionmage_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lionmage_default.png"];
        
        _idle = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"lionmage_idle" andFrames:2 delay:0.5];
        _idle.tag = IDLETAG;
        
        _move = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"lionmage_walk" andFrames:8 delay:0.1];
        
        _heal = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"lionmage_cast" andFrames:6 delay:0.1 reverse:NO];
        
        if ( side ) {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_NE_0.png"];
        } else {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_SW_0.png"];
        }
        
        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = LIONMAGESCALE;
        
        [self.spriteSheet addChild:self.sprite];
        [self addChild:self.spriteSheet];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_move.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-40,60);
    _moveButton.costOfButton = 2;
    
    _healButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_cross-coloured.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_3.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(healPressed)];
    _healButton.position = ccp(40,60);
    _healButton.costOfButton = 3;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _healButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects
{
    NSMutableArray *frames1 = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                            spriteFrameByName:[NSString stringWithFormat:@"heal_%d.png",i]]];
    }
    
    CCAnimation *animation1 = [[CCAnimation alloc] initWithSpriteFrames:frames1 delay:0.2];
    animation1.restoreOriginalFrame = NO;
    _healEffect = [[CCRepeatForever alloc] initWithAction:[[CCAnimate alloc] initWithAnimation:animation1]];
    [super initEffects];
}


#pragma mark - Actions + combat
- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.position);
    if ( action != IDLE && action != DEAD ) {
        [self setDirectionWithDifference:difference];
    }
    
    if ( action == IDLE ) {
        [self.delegate unitDelegateUnit:self finishedAction:IDLE];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == MOVE ) {
        [self.moveButton setIsUsed:YES];
        [self popStepAndAnimate];
        
    } else if ( action == DEAD ) {
        CCSprite *orb = [CCSprite spriteWithSpriteFrameName:@"deathorb_0.png"];
        [self.delegate unitDelegateAddSprite:orb z:EFFECTS];
        orb.position = self.position;
        orb.visible = NO;
        
        id fade = [CCFadeOut actionWithDuration:0.4];
        id form = [CCCallBlock actionWithBlock:^{
            orb.visible = YES;
            [orb runAction:self.death];
        }];
        id die = [CCSpawn actions:fade, form, nil];
        
        id spritefade = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:die]; }];
        id delay = [CCDelayTime actionWithDuration:0.5];
        id orbfade = [CCCallBlock actionWithBlock:^{ [orb runAction:[CCFadeOut actionWithDuration:0.2]];}];
        id finish = [CCCallBlock actionWithBlock:^{
            self.sprite.visible = false;
            [self.delegate unitDelegateRemoveSprite:orb];
            [self.delegate unitDelegateKillMe:self at:self.position];
        }];
        
        [self.sprite runAction:[CCSequence actions:spritefade, delay, orbfade, finish, nil]];
        
    } else {
        [super action:action at:position];
    }
}

- (void) combatAction:(int)action targets:(NSArray *)targets
{
    [self.sprite stopAllActions];
    if ( action == HEAL_ALL ) {
        [self.healButton setIsUsed:YES];
        
        /* cast */
        id startcast = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.heal getActionFor:self.direction]];
        }];
        id delaycast = [CCDelayTime actionWithDuration:0.6];
        id finishcast = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        [self.sprite runAction:[CCSequence actions:startcast, delaycast, finishcast, nil]];
        
        /* effect */
        for ( UnitDamage *dmgPtr in targets )
        {
            CCSprite *heal = [CCSprite spriteWithSpriteFrameName:@"heal_0.png"];
            heal.position = ccpAdd(ccp(0,10),dmgPtr.target.sprite.position);
            heal.visible = NO;
            [self.delegate unitDelegateAddSprite:heal z:EFFECTS];
            
            id effectDelay = [CCDelayTime actionWithDuration:0.7];
            id effectStart = [CCCallBlock actionWithBlock:^{
                [dmgPtr.target healHealth:dmgPtr.damage];
                heal.visible = YES;
                [heal runAction:[self.healEffect copy]];
            }];
            id effectRun = [CCDelayTime actionWithDuration:0.75];
            id effectFade = [CCCallBlock actionWithBlock:^{
                [heal runAction:[CCFadeOut actionWithDuration:0.75]];
            }];
            id effectFinish = [CCCallBlock actionWithBlock:^{
                [self.delegate unitDelegateRemoveSprite:heal];
            }];
            
            [heal runAction:[CCSequence actions:
                             effectDelay, effectStart, effectRun,
                             effectFade, effectRun, effectFinish, nil]];
        }
    }
}

- (void) popStepAndAnimate {
    // Check if there remains path steps to go through
    [[self sprite] stopAllActions];
    if ([[self shortestPath] count] == 0) {
        [self action:IDLE at:CGPointZero];
        if (self.isOwned) [self toggleMenu:YES];
        [self setShortestPath: nil];
        return;
    }
    
    // Get the next step to move to
    ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    NSLog(@"%@! %@",self,s);
    CGPoint difference = ccpSub([s position], [[self sprite] position]);
    float duration = ccpLength(ccpSub([s position],self.position))/60;
    
    // Find the facing direction
    if (difference.x >= 0 && difference.y >= 0) {
            [self.sprite runAction:self.move.action_NE];
            self.direction = NE;
    } else if (difference.x >= 0 && difference.y < 0) {
            [self.sprite runAction:self.move.action_SE];
            self.direction = SE;
    } else if (difference.x < 0 && difference.y < 0) {
            [self.sprite runAction:self.move.action_SW];
            self.direction = SW;
    } else {
            [self.sprite runAction:self.move.action_NW];
            self.direction = NW;
    }
    
    [self.delegate unitDelegateUnit:self updateLayer:s.boardPos];
    
    // Prepare the action and the callback
    id moveAction = [CCMoveTo actionWithDuration:duration position:[s position]];
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    [self.shortestPath removeObjectAtIndex:0];
    
    // Play actions
    [[self sprite] runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}


- (void) damageHealth:(DamageObj *)dmg
{
    NSString *directionFrame;
    if ( self.direction == NE )
        directionFrame = @"lionmage_knockback_NE.png";
    else if ( self.direction == NW )
        directionFrame = @"lionmage_knockback_NW.png";
    else if ( self.direction == SE )
        directionFrame = @"lionmage_knockback_SE.png";
    else if ( self.direction == SW )
        directionFrame = @"lionmage_knockback_SW.png";
    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:directionFrame];
    
    [super damageHealth:dmg];
}

- (void) healHealth:(DamageObj *)dmg
{
    [super healHealth:dmg];
}


#pragma mark - Menu controls
- (BOOL) canIDo:(int)action
{
    return [super canIDo:action];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate unitDelegatePressedButton:MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) healPressed
{
    if ( ![self.healButton isUsed] && [self canIDo:HEAL_ALL] ) {
        if ( [self.delegate unitDelegatePressedButton:HEAL_ALL] ) {
            [self toggleMenu:NO];
        }
    }
}


#pragma mark - Misc
- (NSString *) description
{
    return [NSString stringWithFormat:@"Lionmage"];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed ) self.coolDown += self.moveButton.costOfButton;
    if ( self.healButton.isUsed ) self.coolDown += self.healButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.healButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.healButton.isUsed;
}
@end
