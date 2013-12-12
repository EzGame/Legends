//
//  Priest.m
//  Legends
//
//  Created by David Zhang on 2013-11-06.
//
//

#import "Priest.h"
@interface Priest()
@property (nonatomic, strong)   UnitAction *idle;
@property (nonatomic, strong)   UnitAction *move;
@property (nonatomic, strong)   UnitAction *heal;
@property (nonatomic, strong)   UnitAction *cast;
@property (nonatomic, strong)   UnitButton *moveButton;
@property (nonatomic, strong)   UnitButton *healButton;
@property (nonatomic, strong)   UnitButton *castButton;
@property (nonatomic, strong) ActionObject *moveAction;
@property (nonatomic, strong) ActionObject *healAction;
@property (nonatomic, strong) ActionObject *castAction;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Priest
#pragma mark - Init n shit
+ (id) priest:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Priest alloc] initPriest:object isOwned:owned];
}

- (id) initPriest:(UnitObject *)object isOwned:(BOOL)owned
{
    self = [super initUnit:object isOwned:owned];
    if ( self ) {
        _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"priest_idle" andFrames:4 delay:0.1];
        _idle.tag = IDLETAG;
        
        _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"priest_walk" andFrames:4 delay:0.1];
        
        _heal = [UnitAction actionsWithSpriteSheet:self.spriteSheet forName:@"priest_pray" andFrames:4 delay:0.15 reverse:NO];
        
        _cast = [UnitAction actionsWithSpriteSheet:self.spriteSheet forName:@"priest_cast" andFrames:4 delay:0.1 reverse:NO];
        
        [self initMenu];
        [self initActions];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [UnitButton UnitButtonWithName:@"move" CD:2 MC:100 target:self selector:@selector(movePressed)];
    _moveButton.anchorPoint = ccp(0.5, 0.5);
    _moveButton.position = ccp(-50, 60);
    
    _healButton = [UnitButton UnitButtonWithName:@"cross-coloured" CD:3 MC:100 target:self selector:@selector(healPressed)];
    _healButton.anchorPoint = ccp(0.5, 0.5);
    _healButton.position = ccp(50, 60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _healButton, nil];
    self.menu.visible = NO;
    self.menu.anchorPoint = ccp(0.5, 0.5);
    self.menu.position = ccp(0,0);
    [self addChild:self.menu];
}

- (void) initActions
{
    _moveAction = [[ActionObject alloc] init];
    _moveAction.type = ActionMove;
    _moveAction.rangeType = RangePathFind;
    _moveAction.areaOfEffect = [GeneralUtils getDiamondAreaWithMe:0];
    _moveAction.range = 3;
    
    _healAction = [[ActionObject alloc] init];
    _healAction.type = ActionSkillOne;
    _healAction.rangeType = RangeAllied;
    
    _castAction = [[ActionObject alloc] init];
    _castAction.type = ActionSkillTwo;
    _castAction.rangeType = RangeNormal;
}

#pragma mark - Action
- (void) action:(Action)action targets:(NSMutableArray *)targets
{
    if ( action == ActionIdle ) {
        // Get action
        CCAction *actPtr = [self.idle getActionFor:self.direction];
        
        // Run action
        [self playAction:actPtr];
        
    } else if ( action == ActionMove ) {
        // Run action
        [self actionWalk];
        
    } else if ( action == ActionSkillOne ) {
        // Save targets
        self.targets = targets;
        
        // Run our particle effect
        CCParticleSystemQuad *eff = [[GameObjSingleton get] getParticleSystemForFile:@"priest_heal_effect.plist"];
//        [eff runAction:[CCActionTween actionWithDuration:0.4 key:@"maxParticles" from:0 to:50]];
        eff.position = ccp(0,15);
        if ( eff.parent ) {
            [eff.parent removeChild:eff cleanup:NO];
        }
        [self addChild:eff z:1];
        
        // Get action
        CCAnimation *animPtr = [self.heal getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(healFinished)];
        
    } else if ( action == ActionStop ) {
        // Stop actions
        [self.sprite stopAllActions];
        self.direction = self.direction;
    }
}

- (void) actionWalk {
    // Final check
    if ( self.shortestPath.count == 0 ) {
        [self action:ActionStop targets:nil];
        [self.delegate unit:self didFinishAction:self.moveAction];
        self.shortestPath = nil;
        return;
    }
    
    // Get variables
    ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    CGPoint difference = ccpSub(s.position, self.position);
    float duration = 0.41;
    
    // Find the facing direction
    if (difference.x >= 0 && difference.y >= 0) {
        self.direction = NE;
    } else if (difference.x >= 0 && difference.y < 0) {
        self.direction = SE;
    } else if (difference.x < 0 && difference.y < 0) {
        self.direction = SW;
    } else {
        self.direction = NW;
    }
    
    // Get action and set position
    CCAction *actPtr = [self.move getActionFor:self.direction];
    [self.shortestPath removeObjectAtIndex:0];
    
    // Prepare the action and the callback
    id moveStart = [CCCallBlock actionWithBlock:^{
        [self playAction:actPtr];
    }];
    id moveAction = [CCMoveTo actionWithDuration:duration position:s.position];
    id moveComplete = [CCCallBlock actionWithBlock:^{
        [self.delegate unit:self didMoveTo:s.boardPos];
    }];
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(actionWalk)];
    
    // Play actions
    [self runAction:[CCSequence actions:moveStart, moveAction, moveComplete, moveCallback, nil]];
}

#pragma mark - Selectors
- (void) movePressed
{
    if ( ![self.moveButton isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.moveAction];
    }
}

- (void) healPressed
{
    if ( ![self.healButton isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.healAction];
    }
}

- (void) healFinished
{
    // Send effects??????????????????????????????????????????
    for ( int i = 0; i < self.targets.count; i++ ) {
        CCParticleSystemQuad *effect = [[GameObjSingleton get] getParticleSystemForFile:@"healEffect.plist"];
        if ( effect.parent ) {
            [effect.parent removeChild:effect cleanup:NO];
        }
        
        id target = [self.targets objectAtIndex:i];
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            effect.position = [(NSValue *)target CGPointValue];
            
        } else {
            // Type is unit, we can directly communicate with them
            Unit *unit = (Unit *)target;
            effect.position = unit.position;
            //[unit gain:10 from:self];
        }
        // Ask our delegate to handle the position and order
        [self.delegate unit:self wantsToPlace:effect];
    }
    
    // Call our finish delegate function
    [self action:ActionStop targets:nil];
    [self.delegate unit:self didFinishAction:self.healAction];
    
}

- (void) reset
{
    self.currentCD--;
    if ( self.moveButton.isUsed ) self.currentCD += self.moveButton.buttonCD;
    if ( self.healButton.isUsed ) self.currentCD += self.healButton.buttonCD;
    self.moveButton.isUsed = NO;
    self.healButton.isUsed = NO;
}


@end
/*
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

- (void) setDirection:(Direction)direction
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
        
        if ( side ) self.sprite = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_NE_0.png"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_SW_0.png"];
        
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
    _moveButton = [MenuItemSprite itemWithActionName:@"move" cost:2
                                              target:self selector:@selector(movePressed)];
    _moveButton.position = ccp(-40,60);
    
    _healButton = [MenuItemSprite itemWithActionName:@"cross-coloured" cost:3
                                              target:self selector:@selector(healPressed)];
    _healButton.position = ccp(40,60);
    
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
- (void) primaryAction:(Action)action targets:(NSArray *)targets
{
    [self.sprite stopAllActions];
    if ( action == ActionHeal ) {
        [self.healButton setIsUsed:YES];
        
        
 
        CCParticleSystem *heal = [CCParticleSystem particleWithFile:@"heal"];
        [heal setLife:1];
        heal.autoRemoveOnFinish = YES;
        
        
 
        id startcast = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.heal getActionFor:self.direction]];
        }];
        id delaycast = [CCDelayTime actionWithDuration:0.6];
        id finishcast = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        
 
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
            //[dmgPtr.target addChild:[heal copy]];
        }

        [self.sprite runAction:[CCSequence actions:startcast, delaycast, finishcast, nil]];
    }
}

- (void) secondaryAction:(Action)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.position);
    if ( action != ActionIdle && action != ActionDie ) {
        [self setDirectionWithDifference:difference];
    }
    
    if ( action == ActionIdle ) {
        [self.delegate unitDelegateUnit:self finishedAction:ActionIdle];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == ActionMove ) {
        [self.moveButton setIsUsed:YES];
        [self popStepAndAnimate];
        
    } else {
        [super secondaryAction:action at:position];
    }
}

- (void) popStepAndAnimate {
    // Check if there remains path steps to go through
    [[self sprite] stopAllActions];
    if ([[self shortestPath] count] == 0) {
        [self secondaryAction:ActionIdle at:CGPointZero];
        if (self.isOwned) [self toggleMenu:YES];
        [self setShortestPath: nil];
        return;
    }
    
    // Get the next step to move to
    ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
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
- (BOOL) canIDo:(Action)action
{
    return [super canIDo:action];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:ActionMove] ) {
        if ( [self.delegate unitDelegatePressedButton:ActionMove] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) healPressed
{
    if ( ![self.healButton isUsed] && [self canIDo:ActionHeal] ) {
        if ( [self.delegate unitDelegatePressedButton:ActionHeal] ) {
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

 */