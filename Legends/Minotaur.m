//
//  Minotaur.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//
#define MINOTAURSCALE 3
#define MINOTAURSETUPSCALE MINOTAURSCALE * SETUPMAPSCALE
#import "Minotaur.h"
@implementation Minotaur

@synthesize idle = _idle, move = _move, attk = _attk, dead = _dead;
@synthesize moveButton = _moveButton, attkButton = _attkButton, defnButton = _defnButton;

#pragma mark - Alloc n Init

+ (id) minotaurWithObj:(UnitObj *)obj
{
    return [[Minotaur alloc] initMinotaurFor:YES withObj:obj];
}

+ (id) minotaurForEnemyObj:(UnitObj *)obj
{
    return [[Minotaur alloc] initMinotaurFor:NO withObj:obj];
}

+ (id) minotaurForSetupObj:(UnitObj *)obj
{
    return [[Minotaur alloc] initMinotaurForSetupWithObj:obj];
}

- (id) initMinotaurFor:(BOOL)side withObj:(UnitObj *)obj;
{
    self = [super initForSide:side withObj:obj];
    if (self)
    {
        // Minos start out defending
        isDefending = YES;
        
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mino.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mino.png"];
        
        // Create the action set for each action
        _idle = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:IDLE];
        _idle.tag = IDLETAG;
        _move = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:MOVE];
        _attk = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:ATTK];
        _dead = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:DEAD];
        
        // Create the sprite
        if (side) self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_073.gif"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_169.gif"];
        
        // Create the unit specific menu
        [self initMenu];
        
        self.sprite.scale = MINOTAURSCALE;
            
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (id) initMinotaurForSetupWithObj:(UnitObj *)obj
{
    self = [super initForSide:YES withObj:obj];
    if (self)
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mino.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mino.png"];
        
        // Create the sprite
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_169.gif"];
        self.sprite.scale = MINOTAURSETUPSCALE;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_move.png"]
                                            selectedSprite:nil
                                            disabledSprite:nil
                                                    target:self
                                                  selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    _moveButton.costOfButton = 0;
    _moveButton.scale = 1.5;
    
    _attkButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_melee.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                            disabledSprite:nil
                                                    target:self
                                                  selector:@selector(attkPressed)];
    _attkButton.position = ccp(0,85);
    _attkButton.costOfButton = 1;
    
    _defnButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_shield.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                            disabledSprite:nil
                                                    target:self
                                                  selector:@selector(defnPressed)];
    _defnButton.position = ccp(50,60);
    _defnButton.costOfButton = 1;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _attkButton, _defnButton, nil];
    self.menu.visible = NO;
}

#pragma mark - Action + combat
/*
- (void) action:(int)action at:(CGPoint)position
{
    // Stop all previous actions
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position,self.sprite.position);
    
    if ( action != IDLE && action != DEAD )
    {
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
    
    if ( action == MOVE )
    {
        self.moveButton.isUsed = YES;
        [self popStepAndAnimate];
        return;
    }
    else if ( action == ATTK )
    {
        self.attkButton.isUsed = YES;
        if ( self.direction == NE )
            [self.sprite runAction:self.attk.action_NE];
        else if ( self.direction == SE )
            [self.sprite runAction:self.attk.action_SE];
        else if ( self.direction == SW )
            [self.sprite runAction:self.attk.action_SW];
        else
            [self.sprite runAction:self.attk.action_NW];
        
        CCSequence *atk = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.6f position:self.sprite.position],
                           [CCCallBlock actionWithBlock:
                            ^{
                                [self.sprite stopAllActions];
                                [self action:IDLE at:CGPointZero];
                                if (self.isOwned) [self toggleMenu:YES];
                             }], nil];
        [self.sprite runAction:atk];
    }
    else if ( action == DEFN ) {
        self.defnButton.isUsed = YES;
        [[self sprite] stopAllActions];
        
    } else if ( action == TURN ) {
        [[self sprite] stopAllActions];
        NSString *string = nil ;
        if ( self.direction == NE ) {
            string = @"minotaur_alpha_073.gif";
        } else if ( self.direction == SE ) {
            string = @"minotaur_alpha_121.gif";
        } else if ( self.direction == SW ) {
            string = @"minotaur_alpha_169.gif";
        } else {
            string = @"minotaur_alpha_025.gif";
        }
        
        [[self sprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:string]];
    }

    else if ( action == DEAD ) {
        if ( self.direction == NE )
            [self.sprite runAction:self.dead.action_NE];
        else if ( self.direction == SE )
            [self.sprite runAction:self.dead.action_SE];
        else if ( self.direction == SW )
            [self.sprite runAction:self.dead.action_SW];
        else
            [self.sprite runAction:self.dead.action_NW];
        
        
        CCSequence *die = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.6f position:self.sprite.position],
                           [CCCallBlock actionWithBlock:
                            ^{  self.sprite.visible = false;
                                [self.delegate killMe:self at:self.sprite.position];
                            }],
                           nil];
        [self.sprite runAction:die];
        
    } else {
        NSLog(@">[MYWARN]   Minotaur: I can't handle this LOL");
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
    NSLog(@"MINO! %@",s);
    CGPoint difference = ccpSub([s position], [[self sprite] position]);
    float duration = ccpLength(ccpSub([s position],self.sprite.position))/100;
    
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
    
	// Prepare the action and the callback
	id moveAction = [CCMoveTo actionWithDuration:duration position:[s position]];
	id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    
	// Remove the step
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


- (int) calculate:(int)damage type:(int)dmgType;
{
    return damage;
}

#pragma mark - Menu controls
- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate pressedButton:MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) attkPressed
{
    if ( ![self.attkButton isUsed] && [self canIDo:ATTK] ) {
        if ( [self.delegate pressedButton:ATTK] ) {
            [self toggleMenu:NO];
        }
    }
}
- (void) defnPressed
{
    if ( ![self.defnButton isUsed] && [self canIDo:DEFN] ) {
        if ( [self.delegate pressedButton:DEFN] ) {
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
    if ( self.attkButton.isUsed )
        self.coolDown+= self.attkButton.costOfButton;
    if ( self.defnButton.isUsed )
        self.coolDown+= self.defnButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.attkButton.isUsed = NO;
    self.defnButton.isUsed = NO;
}

#pragma mark - Buff Handlers

- (BOOL) canIDo:(int)action
{
    if ( action == MOVE )
        return !isStoned && !isStunned && !isFrozen && !isEnsnared;
    else if ( action == ATTK )
        return !isStoned && !isStunned && !isFrozen;
    else if ( action == DEFN )
        return !isStoned && !isStunned && !isFrozen;
    else // menu asking, always the least needy option
        return !isStoned && !isStunned && !isFrozen;
}

#pragma mark - Misc
- (CGPoint *) getAttkArea { return (CGPoint *)minotaurAttkArea; }
- (CGPoint *) getAttkEffect { return (CGPoint *)minotaurAttkEffect; }

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.attkButton.isUsed || !self.defnButton.isUsed;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Minotaur Lv.%d",self.level];
}
 */
@end
