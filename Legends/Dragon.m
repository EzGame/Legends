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

- (void) setDirection:(int)direction
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
        
        if ( side ) {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"dragon_idle_NE_0.png"];
        } else {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"dragon_idle_SW_0.png"];
        }
        
        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = DRAGONSCALE;
        
        [self.spriteSheet addChild:self.sprite z:0];
        [self addChild:self.spriteSheet];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_fly.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    _moveButton.costOfButton = 1;
    
    _fireballButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_magic.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                            disabledSprite:nil
                                                    target:self
                                                  selector:@selector(fireballPressed)];
    _fireballButton.position = ccp(0,85);
    _fireballButton.costOfButton = 2;
    
    _flamebreathButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_flamebreath.png"]
                                               selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                               disabledSprite:nil
                                                       target:self
                                                     selector:@selector(flamebreathPressed)];
    _flamebreathButton.position = ccp(50,60);
    _flamebreathButton.costOfButton = 2;
    
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
- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.position);
    if ( action != IDLE && action != DEAD && action != MUDGOLEM_EARTHQUAKE) {
        [self setDirectionWithDifference:difference];
    }
    
    if ( action == IDLE ) {
        [self.delegate unitDelegateUnit:self finishedAction:IDLE];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == MOVE ) {
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
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:fly1, delay, fly2, finish, nil]];
        
    } else if ( action == DRAGON_FLAMEBREATH ) {
        [self.flamebreathButton setIsUsed:YES];
        [self.fireballButton setIsUsed:YES];
        
        /* projectile */
        CCSprite *fire;
        if ( self.direction == NE ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_NE_0.png"];
        else if ( self.direction == NW ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_NW_0.png"];
        else if ( self.direction == SE ) fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_SE_0.png"];
        else fire = [CCSprite spriteWithSpriteFrameName:@"flamethrower_SW_0.png"];
        [self.delegate unitDelegateAddSprite:fire z:EFFECTS];
        fire.position = ccpAdd(position,ccp(0,-14)); // unique offset
        fire.visible = NO;
        
        id dragon_start = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:[self.flamebreath getActionFor:self.direction]];}];
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
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:dragon_start, delay_start, fire_start, delay_fire, fire_end, delay_fire_end, finish, nil]];
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
    if ( action == DRAGON_FIREBALL ) {
        [self.fireballButton setIsUsed:YES];
        [self.flamebreathButton setIsUsed:YES];
    
        
        /* single target */
        UnitDamage *dmgTarget = [targets objectAtIndex:0];
        CGPoint targetPos = dmgTarget.target.sprite.position;
        CGPoint difference = ccpSub(targetPos, self.position);
        [self setDirectionWithDifference:difference];
        
        
        /* projectile */
        CCSprite *fireball = [CCSprite spriteWithSpriteFrameName:@"fireball_0.png"];
        [self.delegate unitDelegateAddSprite:fireball z:EFFECTS];
        fireball.position = ccpAdd(self.position,ccp(0,40));
        fireball.visible = NO;
        fireball.scale = 0.75;
        fireball.rotation = [self getAngle:self.position :targetPos];

        CCSprite *explosion = [CCSprite spriteWithSpriteFrameName:@"explosion_0.png"];
        [self.delegate unitDelegateAddSprite:explosion z:EFFECTS];
        explosion.position = dmgTarget.target.sprite.position;
        explosion.visible = NO;
        
        
        /* projectile animation */
        float duration = ccpDistance(self.position, targetPos)/400;
        id fireball_formation = [CCFadeIn actionWithDuration:0.1];
        id fireball_move = [CCMoveTo actionWithDuration:duration position:targetPos];
        id fireball_start = [CCSpawn actions:fireball_formation, fireball_move, nil];
        
        id explosion_start = [CCCallBlock actionWithBlock:^{
            explosion.visible = YES;
            fireball.visible = NO;
            [explosion runAction:self.explosion];
            [dmgTarget.target damageHealth:dmgTarget.damage];
        }];
        id explosion_run = [CCDelayTime actionWithDuration:0.4];
        id explosion_end = [CCCallBlock actionWithBlock:^{
            explosion.visible = NO;
            [self.delegate unitDelegateRemoveSprite:explosion];
            [self.delegate unitDelegateRemoveSprite:fireball];
        }];
        
        
        /* animation */
        id begincast = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.fireball getActionFor:self.direction]];}];
        id delaycast = [CCDelayTime actionWithDuration:0.3];
        id cast = [CCCallBlock actionWithBlock:^{
            fireball.visible = YES;
        }];
        id delayfinish = [CCDelayTime actionWithDuration:0.4];
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        
        /* run */
        [self.sprite runAction:[CCSequence actions:begincast, delaycast, cast, delayfinish, finish, nil]];
        [fireball runAction:[CCSequence actions:delaycast, fireball_start, explosion_start, explosion_run, explosion_end, nil]];
        
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
- (BOOL) canIDo:(int)action
{
    if ( action == DRAGON_FIREBALL )
        return YES;
    else if ( action == DRAGON_FLAMEBREATH )
        return YES;
    else
        return [super canIDo:action];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate unitDelegatePressedButton:TELEPORT_MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) fireballPressed
{
    if ( ![self.fireballButton isUsed] && [self canIDo:DRAGON_FIREBALL] ) {
        if ( [self.delegate unitDelegatePressedButton:DRAGON_FIREBALL] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) flamebreathPressed
{
    if ( ![self.flamebreathButton isUsed] && [self canIDo:DRAGON_FLAMEBREATH] ) {
        if ( [self.delegate unitDelegatePressedButton:DRAGON_FLAMEBREATH] ) {
            [self toggleMenu:NO];
        }
    }
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
