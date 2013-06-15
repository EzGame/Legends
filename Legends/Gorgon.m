//
//  Gorgon.m
//  Legend
//
//  Created by David Zhang on 2013-05-10.
//
//

#import "Gorgon.h"
@interface Gorgon ()
@property (nonatomic, strong) MenuItemSprite *last;
@property (nonatomic, weak) Unit *target;
@end

@implementation Gorgon

@synthesize idle = _idle, move = _move, shoot = _shoot, freeze = _freeze;
@synthesize moveButton = _moveButton, shootButton = _shootButton, freezeButton = _freezeButton;

+ (id) gorgon
{
    return [[Gorgon alloc] initGorgonFor:YES];
}

+ (id) gorgonForEnemy
{
    return [[Gorgon alloc] initGorgonFor:NO];
}

+ (id) gorgonForSetup
{
    return [[Gorgon alloc] initGorgonForSetup];
}

- (id) initGorgonFor:(BOOL)side
{
    self = [super init];
    if (self)
    {
        unitSpace = 1;
        moveArea = 2;
        attack = 8;
        defense = 0;
        maxHP = 15;
        block = 0;
        isOwned = side;
        
        hp = maxHP;
        facingDirection = (side) ? NE : SW;
        
        for ( int i = 0; i < 5; i++ ) {
            upgrades[i] = EMPTY;
            states[i] = NO;
        }
        rarity = COMMON;

        // Init properties
        self.spOpenSteps = nil;
        self.spClosedSteps = nil;
        self.shortestPath = nil;

        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gorgon.plist"];

        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"gorgon.png"];

        _idle = nil;
        _move = nil;
        _shoot = nil;
        _dead = nil;

        if (side) self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_NE.png"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_SW.png"];

        if (side) [self initMenu];
        self.sprite.scale = 0.275;

        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (id) initGorgonForSetup
{
    self = [super init];
    if (self)
    {
        unitSpace = 1;
        moveArea = 2;
        attack = 8;
        defense = 0;
        maxHP = 15;
        block = 0;
        isOwned = YES;
        
        hp = maxHP;
        facingDirection = NE;
        
        for ( int i = 0; i < 5; i++ ) {
            upgrades[i] = EMPTY;
            states[i] = NO;
        }
        rarity = COMMON;
        
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gorgon.plist"];
        
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"gorgon.png"];
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"Medusa_SW.png"];
        self.sprite.scale = 0.275;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"gorgon_move.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"gorgon_move.png"]
                                        disabledSprite:[CCSprite spriteWithFile:@"gorgon_move.png"]
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,10);
    _moveButton.costOfButton = 1;
    
    _shootButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"gorgon_shoot.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"gorgon_shoot.png"]
                                        disabledSprite:[CCSprite spriteWithFile:@"gorgon_shoot.png"]
                                                target:self
                                              selector:@selector(shootPressed)];
    _shootButton.position = ccp(0,65);
    _shootButton.costOfButton = 1;
    
    _freezeButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"gorgon_freeze.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"gorgon_freeze.png"]
                                        disabledSprite:[CCSprite spriteWithFile:@"gorgon_freeze.png"]
                                                target:self
                                              selector:@selector(freezePressed)];
    _freezeButton.position = ccp(50,10);
    _freezeButton.costOfButton = 3;
    self.menu = [CCMenu menuWithItems:_moveButton, _shootButton, _freezeButton, nil];
    self.menu.visible = NO;
}

- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.sprite.position);
    if ( action != IDLE && action != DEAD ) {
        // Find the facing direction
        if (difference.x >= 0 && difference.y >= 0)
            facingDirection = NE;
        else if (difference.x >= 0 && difference.y < 0)
            facingDirection = SE;
        else if (difference.x < 0 && difference.y < 0)
            facingDirection = SW;
        else
            facingDirection = NW;
    }
    
    if ( action == MOVE ) {
        states[ISFOCUSED] = NO;
        [self.target toggleState:ISFROZEN];
        [self popStepAndAnimate];
        return;
        
    } else if ( action == GORGON_SHOOT ) {
        states[ISFOCUSED] = NO;
        [self.target toggleState:ISFROZEN];
        self.target = nil;
        
        CCSequence *atk = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.6f],
                           [CCCallBlock actionWithBlock:
                            ^{
                                [self.sprite stopAllActions];
                                [self action:IDLE at:CGPointZero];
                                if (isOwned) [self toggleMenu:YES];
                            }], nil];
        
        
        CCSprite *arrow = [CCSprite spriteWithFile:@"Medusa_ARROW.png"];
        [self.delegate addSprite:arrow z:EFFECTS];
        arrow.position = self.sprite.position;
        arrow.rotation = GetAngle(self.sprite.position.x,
                                  self.sprite.position.y,
                                  position.x, position.y);
        
        CCSequence *fly = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.2 position:position],
                           [CCCallBlock actionWithBlock:
                            ^{
                                arrow.visible = NO;
                             }], nil];
        
        [self.sprite runAction:atk];
        [arrow runAction:fly];
        
    } else if ( action == GORGON_FREEZE ) {
        states[ISFOCUSED] = YES;
        
    } else if ( action == TURN ) {
        [self.sprite stopAllActions];
        
        NSString *string = nil ;
        if ( facingDirection == NE ) {
            string = @"Medusa_NE.png";
        } else if ( facingDirection == SE ) {
            string = @"Medusa_SE.png";
        } else if ( facingDirection == SW ) {
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
                                [self.delegate kill:self.sprite.position];
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
        if (isOwned) [self toggleMenu:YES];
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
        facingDirection = NE;
    } else if (difference.x >= 0 && difference.y < 0) {
        //[self.sprite runAction:self.move.action_SE];
        facingDirection = SE;
    } else if (difference.x < 0 && difference.y < 0) {
        //[self.sprite runAction:self.move.action_SW];
        facingDirection = SW;
    } else {
        //[self.sprite runAction:self.move.action_NW];
        facingDirection = NW;
    }
    
	// Prepare the action and the callback
	id moveAction = [CCMoveTo actionWithDuration:duration position:[s position]];
	id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    [self.shortestPath removeObjectAtIndex:0];
    
	// Play actions
	[[self sprite] runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}

- (void) freeze:(Unit *) unit;
{
    NSLog(@">[MYLOG]        Freezing %@", unit);
    self.target = unit;
}

- (void) take:(int)damage
{
    states[ISFOCUSED] = NO;
    [self.target toggleState:ISFROZEN];

    hp -= damage;
    if ( hp < 1 )
        [self action:DEAD at:CGPointZero];
}

- (int) calculate:(int)damage
{
    if ( !states[ISFOCUSED] )
        return damage;
    else
        return damage * 2;
}

- (void) toggleMenu:(BOOL)state
{
    if ( state && [self canIOpenMenu] ) {
        self.menu.position = self.sprite.position;
        self.menu.visible = YES;
    } else {
        self.menu.visible = NO;
    }
}

- (void) undoLastButton
{
    [self.last setIsUsed:NO];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] ) {
        if ( [self.delegate pressedButton:MOVE turn:self.moveButton.costOfButton] ) {
            self.last = self.moveButton;
            [self toggleMenu:NO];
            [self.moveButton setIsUsed:YES];
        }
    }
}

- (void) shootPressed
{
    if ( ![self.shootButton isUsed] ) {
        if ( [self.delegate pressedButton:GORGON_SHOOT turn:self.shootButton.costOfButton] ) {
            self.last = self.shootButton;
            [self toggleMenu:NO];
            [self.shootButton setIsUsed:YES];
        }
    }
}

- (void) freezePressed
{
    if ( ![self.freezeButton isUsed] ) {
        if ( [self.delegate pressedButton:GORGON_FREEZE turn:self.freezeButton.costOfButton] ) {
            self.last = self.freezeButton;
            [self toggleMenu:NO];
            [self.freezeButton setIsUsed:YES];
        }
    }
}

- (void) notified
{
}

- (void) reset
{
    self.moveButton.isUsed = NO;
    self.shootButton.isUsed = NO;
    self.freezeButton.isUsed = NO;
}

- (NSArray *) getShootArea:(CGPoint)position
{
    NSLog(@"WHAT THE FUCK MAN");
    NSMutableArray *list = [NSMutableArray array];
    for (int i = -6; i < 6; i++) {
        for (int j = -6; j < 6; j++) {
            if ( abs(i) + abs(j) < 6 && (i != 0 || j != 0) ) {
                NSLog(@"adding %d,%d",i,j);
                [list addObject:[NSValue valueWithCGPoint:ccpAdd(position, ccp(i,j))]];
            }
        }
    }
    return [NSArray arrayWithArray:list];
}

- (NSArray *) getFreezeArea:(CGPoint)position
{
    NSMutableArray *list = [NSMutableArray array];
    for (int i = -4; i < 4; i++) {
        for (int j = -4; j < 4; j++) {
            if ( abs(i) + abs(j) < 4 && (i != 0 || j != 0) )
                [list addObject:[NSValue valueWithCGPoint:ccpAdd(position, ccp(i,j))]];
        }
    }
    return [NSArray arrayWithArray:list];
}

- (NSString *) description
{
    return @"2";
}

// Math functions
float GetAngle(float x1, float y1, float x2, float y2) {
    float dx, dy, angle;
    
    dx = x2 - x1;
    dy = y2 - y1;
    angle = atan( dy / dx );
    angle = CC_RADIANS_TO_DEGREES(angle);
    return -angle;
}

@end
