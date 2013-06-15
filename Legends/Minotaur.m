//
//  Minotaur.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Minotaur.h"
@interface Minotaur ()
@property (nonatomic, strong) MenuItemSprite *last;
@end
@implementation Minotaur

@synthesize idle = _idle, move = _move, attk = _attk, dead = _dead;
@synthesize moveButton = _moveButton, attkButton = _attkButton, defnButton = _defnButton, last = _last;

+ (id) minotaurWithValues:(NSArray *)values;
{
    return [[Minotaur alloc] initMinotaurFor:YES withValues:values];
}

+ (id) minotaurForEnemyValues:(NSArray *)values;
{
    return [[Minotaur alloc] initMinotaurFor:NO withValues:values];
}

+ (id) minotaurForSetupValues:(NSArray *)values;
{
    return [[Minotaur alloc] initMinotaurForSetupWithValues:values];
}

- (id) initMinotaurFor:(BOOL)side withValues:(NSArray *)values
{
    self = [super initForSide:side withValues:values];
    if (self)
    {
        // Init static ivars
        unitSpace = 1;
        moveArea = 3;
                
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mino.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mino.png"];
        
        // Create the action set for each action
        _idle = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:IDLE];
        _move = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:MOVE];
        _attk = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:ATTK];
        _dead = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:DEAD];
        
        // Create the sprite
        if (side) self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_073.gif"];
        else self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_169.gif"];
        
        // Create the unit specific menu
        if (side) [self initMenu];
        
        self.sprite.scale = 1.5;
            
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (id) initMinotaurForSetupWithValues:(NSArray *)values
{
    self = [super init];
    if (self)
    {
        // Init static ivars
        unitSpace = 1;
        moveArea = 3;
                
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mino.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mino.png"];
        
        // Create the action set for each action
        self.idle = [[CCActions alloc]initWithSpriteSheet:self.spriteSheet forAction:IDLE];
        
        // Create the sprite
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"minotaur_alpha_169.gif"];
        self.sprite.scale = 1.5;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"moveButton.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"moveButton.png"]
                                            disabledSprite:[CCSprite spriteWithFile:@"moveButton.png"]
                                                    target:self
                                                  selector:@selector(movePressed)];
    _moveButton.position = ccp(-40,10);
    _moveButton.costOfButton = 1;
    _attkButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"attkButton.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"attkButton.png"]
                                            disabledSprite:[CCSprite spriteWithFile:@"attkButton.png"]
                                                    target:self
                                                  selector:@selector(attkPressed)];
    _attkButton.position = ccp(0,55);
    _attkButton.costOfButton = 1;
    _defnButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"defnButton.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"defnButton.png"]
                                            disabledSprite:[CCSprite spriteWithFile:@"defnButton.png"]
                                                    target:self
                                                  selector:@selector(defnPressed)];
    _defnButton.position = ccp(40,10);
    _defnButton.costOfButton = 1;
    self.menu = [CCMenu menuWithItems:_moveButton, _attkButton, _defnButton, nil];
    self.menu.visible = NO;
}

- (void) action:(int)action at:(CGPoint)position
{    
    // Stop all previous actions
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position,self.sprite.position);
    
    if ( action != IDLE && action != DEAD )
    {
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
    
    if ( action == MOVE )
    {
        states[ISDEFENDING] = NO;
        [self popStepAndAnimate];
        return;
    }
    else if ( action == ATTK )
    {
        states[ISDEFENDING] = NO;
        if ( facingDirection == NE )
            [self.sprite runAction:self.attk.action_NE];
        else if ( facingDirection == SE )
            [self.sprite runAction:self.attk.action_SE];
        else if ( facingDirection == SW )
            [self.sprite runAction:self.attk.action_SW];
        else
            [self.sprite runAction:self.attk.action_NW];
        
        CCSequence *atk = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.6f position:self.sprite.position],
                           [CCCallBlock actionWithBlock:
                            ^{
                                [self.sprite stopAllActions];
                                [self action:IDLE at:CGPointZero];
                                if (isOwned) [self toggleMenu:YES];
                             }], nil];
        [self.sprite runAction:atk];
    }
    else if ( action == TURN )
    {
        [[self sprite] stopAllActions];
        NSString *string = nil ;
        if ( facingDirection == NE ) {
            string = @"minotaur_alpha_073.gif";
        } else if ( facingDirection == SE ) {
            string = @"minotaur_alpha_121.gif";
        } else if ( facingDirection == SW ) {
            string = @"minotaur_alpha_169.gif";
        } else {
            string = @"minotaur_alpha_025.gif";
        }
        
        [[self sprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:string]];
    }
    else if ( action == DEFN )
    {
        states[ISDEFENDING] = YES;
        [[self sprite] stopAllActions];
    }
    else if ( action == DEAD )
    {
        if ( facingDirection == NE )
            [self.sprite runAction:self.dead.action_NE];
        else if ( facingDirection == SE )
            [self.sprite runAction:self.dead.action_SE];
        else if ( facingDirection == SW )
            [self.sprite runAction:self.dead.action_SW];
        else
            [self.sprite runAction:self.dead.action_NW];
        
        
        CCSequence *die = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.6f position:self.sprite.position],
                           [CCCallBlock actionWithBlock:
                            ^{  self.sprite.visible = false;
                                [self.delegate kill:self.sprite.position];
                            }],
                           nil];
        [self.sprite runAction:die];
    }
    else
    {
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
        if (isOwned) [self toggleMenu:YES];
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
        facingDirection = NE;
        
    } else if (difference.x >= 0 && difference.y < 0) {
        [self.sprite runAction:self.move.action_SE];
        facingDirection = SE;
        
    } else if (difference.x < 0 && difference.y < 0) {
        [self.sprite runAction:self.move.action_SW];
        facingDirection = SW;
        
    } else {
        [self.sprite runAction:self.move.action_NW];
        facingDirection = NW;
        
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
    hp -= damage;
    if ( hp < 1 )
        [self action:DEAD at:CGPointZero];
}

- (int) calculate:(int)damage
{    
    if ( !states[ISDEFENDING] || arc4random() % 100 >= block * 100 )
        return damage;
    else
        return floor(damage * block);
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

- (void) attkPressed
{
    if ( ![self.attkButton isUsed] ) {
        if ( [self.delegate pressedButton:ATTK turn:self.attkButton.costOfButton] ) {
            self.last = self.attkButton;
            [self toggleMenu:NO];
            [self.attkButton setIsUsed:YES];
        }
    }
}
- (void) defnPressed
{
    if ( ![self.defnButton isUsed] ) {
        if ( [self.delegate pressedButton:DEFN turn:self.defnButton.costOfButton] ) {
            self.last = self.defnButton;
            [self toggleMenu:NO];
            [self.defnButton setIsUsed:YES];
        }
    }
}

- (void) reset
{
    isDelayed = NO;
    self.moveButton.isUsed = NO;
    self.attkButton.isUsed = NO;
    self.defnButton.isUsed = NO;
}

- (NSArray *) getAttkArea:(CGPoint)position
{
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:ccpAdd(position, ccp(1,0))],
            [NSValue valueWithCGPoint:ccpAdd(position, ccp(-1,0))],
            [NSValue valueWithCGPoint:ccpAdd(position, ccp(0,1))],
            [NSValue valueWithCGPoint:ccpAdd(position, ccp(0,-1))],nil];
}

- (NSString *) description
{
    return @"1";
}
@end
