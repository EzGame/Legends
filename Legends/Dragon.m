//
//  Dragon.m
//  Legends
//
//  Created by David Zhang on 2013-06-27.
//
//
#define DRAGONSCALE 0.85
#define DRAGONSETUPSCALE DRAGONSCALE * SETUPMAPSCALE
#import "Dragon.h"
@interface Dragon()
@property (nonatomic, strong) CCAction *explosion;
@property (nonatomic, strong) CCActions *firebreath;
@end


@implementation Dragon
const NSString *DRAGON_TWO_DESP = @"Range-Magic";
const NSString *DRAGON_ONE_DESP = @"Range-Magic";
const NSString *DRAGON_MOVE_DESP = @"Teleporting";

@synthesize idle                = _idle;
@synthesize move                = _move;
@synthesize moveEnd             = _moveEnd;
@synthesize fireball            = _fireball;
@synthesize flamebreath         = _flamebreath;
@synthesize moveButton          = _moveButton;
@synthesize fireballButton      = _fireballButton;
@synthesize flamebreathButton   = _flamebreathButton;
// Stuff from Unit
@synthesize direction           = _direction;
@synthesize position            = _position;


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
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dragon_idle_NE_0.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dragon_idle_NW_0.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dragon_idle_SW_0.png"]];
    else
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dragon_idle_SE_0.png"]];
    _direction = direction;
}


#pragma mark - Alloc n Init
+ (id) dragonFor:(BOOL)side withObj:(UnitObj *)obj;
{
    return [[Dragon alloc] initDragonFor:side withObj:obj];
}

- (id) initDragonFor:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super initForSide:side withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"dragon_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"dragon_default.png"];
        
        _idle = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"dragon_idle" andFrames:2 delay:0.5];
        _idle.tag = IDLETAG;
        _move = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"dragon_flight" andFrames:6 delay:0.1 reverse:NO];
        _moveEnd = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"dragon_flight" andFrames:6 delay:0.1 reverse:YES];
        _fireball = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"dragon_fireball" andFrames:6 delay:0.1 reverse:NO];
        _flamebreath = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"dragon_flamebreath" andFrames:15 delay:0.1];
        
        if ( side ) self.sprite = [CCSprite spriteWithSpriteFrameName:@"dragon_idle_NE_0.png"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"dragon_idle_SW_0.png"];
        
        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = DRAGONSCALE;
        
        [self.spriteSheet addChild:self.sprite];
        [self addChild:self.spriteSheet];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithActionName:@"fly" cost:1
                                              target:self selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    
    _fireballButton = [MenuItemSprite itemWithActionName:@"magic" cost:2
                                                  target:self selector:@selector(fireballPressed)];
    _fireballButton.position = ccp(0,85);
    
    _flamebreathButton = [MenuItemSprite itemWithActionName:@"flamebreath" cost:2
                                                     target:self selector:@selector(flamebreathPressed)];
    _flamebreathButton.position = ccp(50,60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _fireballButton, _flamebreathButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects;
{    
    // FIREBALL - EXPLOSION
    NSMutableArray *frames1 = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion_%d.png",i]]];
    }
    
    CCAnimation *animation1 = [[CCAnimation alloc] initWithSpriteFrames:frames1 delay:0.08];
    animation1.restoreOriginalFrame = NO;
    _explosion = [[CCAnimate alloc] initWithAnimation:animation1];
 
    _firebreath = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"flamethrower" andFrames:6 delay:0.1];
    
    [super initEffects];
}

#pragma mark - Actions + combat
- (void) primaryAction:(Action)action targets:(NSArray *)targets
{
    [self.sprite stopAllActions];
    if ( action == ActionMagic ) {
        [self.fireballButton setIsUsed:YES];
        [self.flamebreathButton setIsUsed:YES];
        
        
        /* single target */
        UnitDamage *dmgTarget = [targets objectAtIndex:0];
        CGPoint difference = ccpSub(dmgTarget.targetPos, self.position);
        [self setDirectionWithDifference:difference];
        
        
        /* projectile */
        CCSprite *fireball = [CCSprite spriteWithSpriteFrameName:@"fireball_0.png"];
        [self.delegate unitDelegateAddSprite:fireball z:EFFECTS];
        fireball.position = ccpAdd(self.position,ccp(0,40));
        fireball.visible = NO;
        fireball.rotation = [self getAngle:self.position :dmgTarget.targetPos];
        float duration = ccpDistance(self.position, dmgTarget.targetPos)/400;

        
        /* effect */
        CCSprite *explosion = [CCSprite spriteWithSpriteFrameName:@"explosion_0.png"];
        [self.delegate unitDelegateAddSprite:explosion z:EFFECTS];
        explosion.position = dmgTarget.target.sprite.position;
        explosion.visible = NO;
        
        
        /* animation */
        id begin_cast = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.fireball getActionFor:self.direction]];}];
        id delay_cast = [CCDelayTime actionWithDuration:0.3];
        id cast = [CCCallBlock actionWithBlock:^{
            fireball.visible = YES;
        }];
        id delay_finish = [CCDelayTime actionWithDuration:0.4];
        id delay_fireball = [CCDelayTime actionWithDuration:duration+0.4];
        id finish_cast = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        
        /* projectile animation */
        id form_fireball = [CCFadeIn actionWithDuration:0.1];
        id move_fireball = [CCMoveTo actionWithDuration:duration position:dmgTarget.targetPos];
        id begin_fireball = [CCSpawn actions:form_fireball, move_fireball, nil];
        
        id begin_explosion = [CCCallBlock actionWithBlock:^{
            explosion.visible = YES;
            fireball.visible = NO;
            [explosion runAction:self.explosion];
            [dmgTarget.target damageHealth:dmgTarget.damage];
        }];
        id delay_explosion = [CCDelayTime actionWithDuration:0.4];
        id finish_explosion = [CCCallBlock actionWithBlock:^{
            explosion.visible = NO;
            [self.delegate unitDelegateRemoveSprite:explosion];
            [self.delegate unitDelegateRemoveSprite:fireball];
        }];
        
        
        /* run */
        [self.sprite runAction:[CCSequence actions:
                                begin_cast, delay_cast, cast, delay_finish,
                                delay_fireball, finish_cast, nil]];
        [fireball runAction:[CCSequence actions:
                             delay_cast, begin_fireball, begin_explosion,
                             delay_explosion, finish_explosion, nil]];
        
    } else if ( 0 ) {
        [self.flamebreathButton setIsUsed:YES];
        [self.fireballButton setIsUsed:YES];
        
        
        /* single target */
        UnitDamage *dmgTarget = [targets objectAtIndex:0];
        CGPoint difference = ccpSub(dmgTarget.targetPos, self.position);
        [self setDirectionWithDifference:difference];
        
        
        /* projectile */
        CCSprite *fire;
        if ( self.direction == NE ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_NE_0.png"];
        else if ( self.direction == NW ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_NW_0.png"];
        else if ( self.direction == SE ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_SE_0.png"];
        else fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_SW_0.png"];
        [self.delegate unitDelegateAddSprite:fire z:EFFECTS];
        fire.position = ccpAdd(dmgTarget.targetPos,ccp(0,-14)); // unique offset
        fire.visible = NO;
        
        
        /* animation */
        id dragon_start = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.flamebreath getActionFor:self.direction]];
        }];
        id delay_start = [CCDelayTime actionWithDuration:0.5];
        id fire_start = [CCCallBlock actionWithBlock:^{
            fire.visible = YES;
            [fire runAction:[self.firebreath getActionFor:self.direction]];
        }];
        id delay_fire = [CCDelayTime actionWithDuration:0.6];
        id fire_end = [CCCallBlock actionWithBlock:^{
            [fire stopAllActions];
            [fire runAction:[CCFadeOut actionWithDuration:0.4]];
        }];
        id delay_fire_end = [CCDelayTime actionWithDuration:0.4];
        id finish = [CCCallBlock actionWithBlock:^{
            [self.delegate unitDelegateRemoveSprite:fire];
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        
        /* projectile animation */
        [self.sprite runAction:[CCSequence actions:dragon_start, delay_start, fire_start, delay_fire, fire_end, delay_fire_end, finish, nil]];
    }
}

- (void) secondaryAction:(Action)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.position);
    if ( action != ActionIdle && action != ActionDie) {
        [self setDirectionWithDifference:difference];
    }
    
    if ( action == ActionIdle ) {
        [self.delegate unitDelegateUnit:self finishedAction:ActionIdle];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == ActionMove ) {
        [self.moveButton setIsUsed:YES];
        
        /////////
        id delay = [CCDelayTime actionWithDuration:0.2];
        /////////
        id flyup = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:[self.move getActionFor:self.direction]]; }];
        id fadeout = [CCFadeOut actionWithDuration:0.4];
        id fade1 = [CCSequence actions:delay, fadeout,  nil];
        id fly1 = [CCSpawn actions:flyup, fade1, nil];
        /////////
        id flydown = [CCCallBlock actionWithBlock:^{
            self.position = position;
            [self.sprite runAction:[self.moveEnd getActionFor:self.direction]];
        }];
        id fadein = [CCFadeIn actionWithDuration:0.4];
        id fade2 = [CCSequence actions:fadein, delay, nil];
        id fly2 = [CCSpawn actions:flydown, fade2, nil];
        /////////
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:fly1, delay, fly2, finish, nil]];
        
    } else if ( action == ActionDie ) {
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
        [super secondaryAction:action at:position];
    }
}

- (void) damageHealth:(DamageObj *)dmg
{
    NSString *directionFrame;
    if ( self.direction == NE )
        directionFrame = @"dragon_knockback_NE.png";
    else if ( self.direction == NW )
        directionFrame = @"dragon_knockback_NW.png";
    else if ( self.direction == SE )
        directionFrame = @"dragon_knockback_SE.png";
    else if ( self.direction == SW )
        directionFrame = @"dragon_knockback_SW.png";
    
    [super damageHealth:dmg];
}


#pragma mark - Menu controls
- (BOOL) canIDo:(Action)action
{
    if ( action == ActionMagic )
        return YES;
    else
        return [super canIDo:action];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:ActionTeleport] ) {
        if ( [self.delegate unitDelegatePressedButton:ActionTeleport] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) fireballPressed
{
    if ( ![self.fireballButton isUsed] && [self canIDo:ActionMagic] ) {
        if ( [self.delegate unitDelegatePressedButton:ActionMagic] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) flamebreathPressed
{
    /*if ( ![self.flamebreathButton isUsed] && [self canIDo:DRAGON_FLAMEBREATH] ) {
        if ( [self.delegate unitDelegatePressedButton:DRAGON_FLAMEBREATH] ) {
            [self toggleMenu:NO];
        }
    }*/
}


#pragma mark - Misc
- (NSString *) description
{
    return [NSString stringWithFormat:@"Dragon"];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed ) self.coolDown += self.moveButton.costOfButton;
    if ( self.fireballButton.isUsed ) self.coolDown += self.fireballButton.costOfButton;
    if ( self.flamebreathButton.isUsed ) self.coolDown += self.flamebreathButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.fireballButton.isUsed = NO;
    self.flamebreathButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.fireballButton.isUsed || !self.flamebreathButton.isUsed;
}


#pragma mark - Areas
- (CGPoint *) getFireballArea { return (CGPoint *)dragonFireballArea; }
- (CGPoint *) getFireballEffect { return (CGPoint *)dragonFireballEffect; }
- (CGPoint *) getFlamebreathArea { return (CGPoint *)dragonFlamebreathArea; }
- (CGPoint *) getFlamebreathEffect { return (CGPoint *)dragonFlamebreathEffect; }
@end
