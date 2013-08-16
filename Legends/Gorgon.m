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

@synthesize idle = _idle, move = _move, shoot = _shoot, freeze = _freeze;
@synthesize moveButton = _moveButton, shootButton = _shootButton, freezeButton = _freezeButton;

#pragma mark - Alloc n Init

+ (id) gorgonWithObj:(UnitObj *)obj;
{
    return [[Gorgon alloc] initGorgonFor:YES withObj:obj];
}

+ (id) gorgonForEnemyWithObj:(UnitObj *)obj;
{
    return [[Gorgon alloc] initGorgonFor:NO withObj:obj];
}

+ (id) gorgonForSetupWithObj:(UnitObj *)obj;
{
    return [[Gorgon alloc] initGorgonForSetupWithObj:obj];
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

        // Create the menu
        if (side) [self initMenu];
        
        self.sprite.scale = GORGONSCALE;

        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (id) initGorgonForSetupWithObj:(UnitObj *)obj
{
    self = [super initForSide:YES withObj:obj];
    if (self)
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gorgon.plist"];
        
        // Create the sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"gorgon.png"];
        
        //Create the sprite
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_SW.png"];
        
        self.sprite.scale = GORGONSETUPSCALE;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_move.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    _moveButton.costOfButton = 1;
    
    _shootButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_ranged.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(shootPressed)];
    _shootButton.position = ccp(0,85);
    _shootButton.costOfButton = 1;
    
    _freezeButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"gorgon_freeze.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_3.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(freezePressed)];
    _freezeButton.position = ccp(50,60);
    _freezeButton.costOfButton = 3;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _shootButton, _freezeButton, nil];
    self.menu.visible = NO;
}

#pragma mark - Actions + combat
/*
- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.sprite.position);
    if ( action != IDLE && action != DEAD ) {
        // Find the facing direction
        if (difference.x >= 0 && difference.y >= 0)
            self.direction = NE;
        else if (difference.x >= 0 && difference.y < 0)
            self.direction = SE;
        else if (difference.x < 0 && difference.y < 0)
            self.direction = SW;
        else
            self.direction = NW;
    }
    
    if ( action == MOVE ) {
        [self.moveButton setIsUsed:YES];
        [self popStepAndAnimate];
        return;
        
    } else if ( action == GORGON_SHOOT ) {
        [self.shootButton setIsUsed:YES];
        CCSequence *atk = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.6f],
                           [CCCallBlock actionWithBlock:
                            ^{
                                [self.sprite stopAllActions];
                                [self action:IDLE at:CGPointZero];
                                if (self.isOwned) [self toggleMenu:YES];
                            }], nil];
        
        
        CCSprite *arrow = [CCSprite spriteWithFile:@"Medusa_ARROW.png"];
        [self.delegate addSprite:arrow z:EFFECTS];
        arrow.position = self.sprite.position;
        arrow.rotation = [self getAngle:self.sprite.position :position];
        
        CCSequence *fly = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.2 position:position],
                           [CCCallBlock actionWithBlock:
                            ^{
                                arrow.visible = NO;
                             }], nil];
        
        [self.sprite runAction:atk];
        [arrow runAction:fly];
        
    } else if ( action == GORGON_FREEZE ) {
        [self.freezeButton setIsUsed:YES];
        [self.sprite stopAllActions];
        
    } else if ( action == TURN ) {
        [self.sprite stopAllActions];
        
        NSString *string = nil ;
        if ( self.direction == NE ) {
            string = @"Medusa_NE.png";
        } else if ( self.direction == SE ) {
            string = @"Medusa_SE.png";
        } else if ( self.direction == SW ) {
            string = @"Medusa_SW.png";
        } else {
            string = @"Medusa_NW.png";
        }
        
        [[self sprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:string]];
        
    } else if ( action == DEAD ) {
        CCSequence *die = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.6f],
                           [CCCallBlock actionWithBlock:
                            ^{
                                self.sprite.visible = NO;
                                [self.delegate killMe:self at:self.sprite.position];
                             }], nil];
        [self.sprite runAction:die];
        
    } else {
        NSLog(@">[MYWARN]   Gorgon: I can't handle this LOL");
    }
}

- (void) popStepAndAnimate
{
    [[self sprite] stopAllActions];
    // Check if there remains path steps to go through
	if ([[self shortestPath] count] == 0) {
        [[self sprite] stopAllActions];
        [self action:IDLE at:CGPointZero];
        if (self.isOwned) [self toggleMenu:YES];
		[self setShortestPath: nil];
		return;
	}
    
	// Get the next step to move to
	ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    NSLog(@"GORGON! %@",s);
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

- (void) take:(int)damage
{
    health -= damage;
    if ( health < 1 )
        [self action:DEAD at:CGPointZero];
}

- (void) heal:(int)damage after:(float)delay
{
    [self.sprite stopAllActions];
    health = MIN(health+damage, self.attribute->max_health);
    
    [self.sprite runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:delay],
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccGREEN];
         [self.delegate displayCombatMessage:[NSString stringWithFormat:@"+%d",damage]
                                  atPosition:self.sprite.position withColor:ccGREEN];
     }],
      [CCDelayTime actionWithDuration:0.2],
      [CCTintTo actionWithDuration:1 red:255 green:255 blue:255], nil]];
}

- (int) calculate:(int)damage type:(int)dmgType
{
    return damage;
}

#pragma mark - Menu controls
- (BOOL) canIDo:(int)action
{
    if ( action == MOVE )
        return !isStoned && !isStunned && !isFrozen && !isEnsnared;
    else if ( action == GORGON_SHOOT )
        return !isStoned && !isStunned && !isFrozen;
    else if ( action == GORGON_FREEZE )
        return !isStoned && !isStunned && !isFrozen;
    else // menu asking, always the least needy option
        return !isStoned && !isStunned && !isFrozen;
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate pressedButton:MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) shootPressed
{
    if ( ![self.shootButton isUsed] && [self canIDo:GORGON_SHOOT]) {
        if ( [self.delegate pressedButton:GORGON_SHOOT] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) freezePressed
{
    if ( ![self.freezeButton isUsed] && [self canIDo:GORGON_FREEZE] ) {
        if ( [self.delegate pressedButton:GORGON_FREEZE] ) {
            [self toggleMenu:NO];
        }
    }
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

#pragma mark - Misc

- (CGPoint *) getShootArea { return (CGPoint *)gorgonShootArea; }
- (CGPoint *) getShootEffect { return (CGPoint *)gorgonShootEffect; }
- (CGPoint *) getFreezeArea { return (CGPoint *)gorgonFreezeArea; }
- (CGPoint *) getFreezeEffect { return (CGPoint *)gorgonFreezeEffect; }

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.shootButton.isUsed || !self.freezeButton.isUsed;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Gorgon Lv.%d",self.level];
}*/
@end
