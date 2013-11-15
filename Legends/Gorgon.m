//
//  Gorgon.m
//  Legend
//
//  Created by David Zhang on 2013-05-10.
//
//
#define GORGONSCALE 0.5
#define GORGONSETUPSCALE GORGONSCALE * SETUPMAPSCALE
#import "Gorgon.h"


@implementation Gorgon

@synthesize idle            = _idle;
@synthesize move            = _move;
@synthesize shoot           = _shoot;
@synthesize freeze          = _freeze;
@synthesize moveButton      = _moveButton;
@synthesize shootButton     = _shootButton;
@synthesize freezeButton    = _freezeButton;
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

- (void) setDirection:(Direction)direction
{
    if ( direction == NE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Medusa_NE.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Medusa_NW.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Medusa_SW.png"]];
    else if ( direction == SE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Medusa_SE.png"]];
    _direction = direction;
}


#pragma mark - Alloc n Init
+ (id) gorgonFor:(BOOL)side withObj:(UnitObj *)obj
{
    return [[Gorgon alloc] initGorgonFor:side withObj:obj];
}

- (id) initGorgonFor:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super initForSide:side withObj:obj];
    if (self)
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gorgon.plist"];

        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"gorgon.png"];

        // Create the action set for each action
        _idle = nil;
        _move = nil;
        _shoot = nil;
        _freeze = nil;
        _dead = nil;

        // Create the sprite
        if (side) self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_NE.png"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_SW.png"];

        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = GORGONSCALE;

        [self.spriteSheet addChild:self.sprite];
        [self addChild:self.spriteSheet];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithActionName:@"move" cost:1
                                              target:self selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    
    _shootButton = [MenuItemSprite itemWithActionName:@"ranged" cost:2
                                               target:self selector:@selector(shootPressed)];
    _shootButton.position = ccp(0,85);
    
    _freezeButton = [MenuItemSprite itemWithActionName:@"magic" cost:2
                                                target:self selector:@selector(freezePressed)];
    _freezeButton.position = ccp(50,60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _shootButton, _freezeButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects
{
    [super initEffects];
}


#pragma mark - Actions + combat
- (void) primaryAction:(Action)action targets:(NSArray *)targets
{
    [self.sprite stopAllActions];
    if ( action == ActionRange ) {
        [self.shootButton setIsUsed:YES];
        [self.freezeButton setIsUsed:YES];
        
        
        /* single target */
        UnitDamage *dmgTarget = [targets objectAtIndex:0];
        CGPoint difference = ccpSub(dmgTarget.targetPos, self.position);
        [self setDirectionWithDifference:difference];
        
        
        /* projectile */
        CCSprite *arrow = [CCSprite spriteWithFile:@"Medusa_ARROW.png"];
        [self.delegate unitDelegateAddSprite:arrow z:EFFECTS];
        arrow.position = self.sprite.position;
        arrow.visible = NO;
        arrow.rotation = [GeneralUtils getAngle:self.sprite.position :dmgTarget.targetPos];
        float duration = ccpDistance(self.position, dmgTarget.targetPos)/400;

        
        /* animation */
        id begin_shoot = [CCCallBlock actionWithBlock:^{
            //[self.sprite runAction:[self.
        }];
        id delay_shoot = [CCDelayTime actionWithDuration:0.6];
        //id shoot
        //id delay_finish
        id delay_arrow = [CCDelayTime actionWithDuration:duration];
        id finish_shoot = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if (self.isOwned) [self toggleMenu:YES];
        }];
        
        
        /* projectile animation */
        id form_arrow = [CCFadeIn actionWithDuration:0.1];
        id move_arrow = [CCMoveTo actionWithDuration:duration position:dmgTarget.targetPos];
        
        id begin_arrow = [CCSpawn actions:form_arrow, move_arrow, nil];
        id finish_arrow = [CCCallBlock actionWithBlock:^{
            [dmgTarget.target damageHealth:dmgTarget.damage];
            [self.delegate unitDelegateRemoveSprite:arrow];
        }];
        

        /* run */
        [self.sprite runAction:[CCSequence actions:
                                begin_shoot, delay_shoot,
                                delay_arrow, finish_shoot, nil]];
        [arrow runAction:[CCSequence actions:
                          delay_shoot, begin_arrow,
                          finish_arrow, nil]];
        
    } else if ( action == ActionParalyze ) {
        [self.freezeButton setIsUsed:YES];
        [self.shootButton setIsUsed:YES];
    }
}

- (void) secondaryAction:(Action)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.sprite.position);
    [self setDirectionWithDifference:difference];
    
    if ( action == ActionIdle ) {
        [self.delegate unitDelegateUnit:self finishedAction:ActionIdle];
        
    } else if ( action == ActionMove ) {
        [self.moveButton setIsUsed:YES];
        [self popStepAndAnimate];
        
    } else {
        [super secondaryAction:action at:position];
    }
}

- (void) popStepAndAnimate
{
    [[self sprite] stopAllActions];
    // Check if there remains path steps to go through
	if ([[self shortestPath] count] == 0) {
        [self secondaryAction:ActionIdle at:CGPointZero];
        if (self.isOwned) [self toggleMenu:YES];
		[self setShortestPath: nil];
		return;
	}
    
	// Get the next step to move to
	ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    CGPoint difference = ccpSub([s position], [[self sprite] position]);
    float duration = ccpLength(ccpSub([s position],self.sprite.position))/100;
    
    // Find the facing direction
    if (difference.x >= 0 && difference.y >= 0) {
        //[self.sprite runAction:self.move.action_NE];
        self.direction = NE;
    } else if (difference.x >= 0 && difference.y < 0) {
        //[self.sprite runAction:self.move.action_SE];
        self.direction = SE;
    } else if (difference.x < 0 && difference.y < 0) {
        //[self.sprite runAction:self.move.action_SW];
        self.direction = SW;
    } else {
        //[self.sprite runAction:self.move.action_NW];
        self.direction = NW;
    }
    
	// Prepare the action and the callback
	id moveAction = [CCMoveTo actionWithDuration:duration position:[s position]];
	id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    [self.shortestPath removeObjectAtIndex:0];
    
	// Play actions
	[[self sprite] runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}

- (void) damageHealth:(DamageObj *)dmg
{
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

- (void) shootPressed
{
    if ( ![self.shootButton isUsed] && [self canIDo:ActionRange]) {
        if ( [self.delegate unitDelegatePressedButton:ActionRange] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) freezePressed
{
    if ( ![self.freezeButton isUsed] && [self canIDo:ActionParalyze] ) {
        if ( [self.delegate unitDelegatePressedButton:ActionParalyze] ) {
            [self toggleMenu:NO];
        }
    }
}


#pragma mark - Misc
- (CGPoint *) getShootArea { return (CGPoint *)gorgonShootArea; }
- (CGPoint *) getShootEffect { return (CGPoint *)gorgonShootEffect; }
- (CGPoint *) getFreezeArea { return (CGPoint *)gorgonFreezeArea; }
- (CGPoint *) getFreezeEffect { return (CGPoint *)gorgonFreezeEffect; }

- (NSString *) description
{
    return [NSString stringWithFormat:@"Gorgon"];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed )
        self.coolDown+= self.moveButton.costOfButton;
    if ( self.shootButton.isUsed )
        self.coolDown+= self.shootButton.costOfButton;
    if ( self.freezeButton.isUsed )
        self.coolDown+= self.shootButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.shootButton.isUsed = NO;
    self.freezeButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.shootButton.isUsed || !self.freezeButton.isUsed;
}
@end
