//
//  Witch.m
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "Witch.h"
@interface Witch()
@property (nonatomic, strong)   UnitAction *idle;
@property (nonatomic, strong)   UnitAction *move;
@property (nonatomic, strong)   UnitAction *cast;
@property (nonatomic, strong)   UnitButton *moveButton;
@property (nonatomic, strong)   UnitButton *castButton;
@property (nonatomic, strong) ActionObject *moveAction;
@property (nonatomic, strong) ActionObject *castAction;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Witch
#pragma mark - Init n shit
+ (id) witch:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Witch alloc] initWitch:object isOwned:owned];
}

- (id) initWitch:(UnitObject *)object isOwned:(BOOL)owned
{
    self = [super initUnit:object isOwned:owned];
    if ( self ) {
        _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"witch_idle" andFrames:4 delay:0.1];
        _idle.tag = IDLETAG;
        
        _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"witch_walk" andFrames:4 delay:0.1];
        
        _cast = [UnitAction actionsWithSpriteSheet:self.spriteSheet forName:@"witch_cast" andFrames:3 delay:0.1 reverse:NO];
        
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
    
    _castButton = [UnitButton UnitButtonWithName:@"magic" CD:3 MC:100 target:self selector:@selector(castPressed)];
    _castButton.anchorPoint = ccp(0.5, 0.5);
    _castButton.position = ccp(50, 60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _castButton, nil];
    self.menu.visible = NO;
    self.menu.position = CGPointZero;
    self.menu.anchorPoint = ccp(0.5, 0.5);
    [self addChild:self.menu];
}

- (void) initActions
{
    _moveAction = [[ActionObject alloc] init];
    _moveAction.type = ActionMove;
    _moveAction.rangeType = RangePathFind;
    _moveAction.range = 3;
    _moveAction.effectType = RangeOne;

    
    _castAction = [[ActionObject alloc] init];
    _castAction.type = ActionSkillOne;
    _castAction.rangeType = RangeUnique;
    _castAction.areaOfRange = [GeneralUtils getWitchCast];
    _castAction.effectType = RangeUnique;
    _castAction.areaOfEffect = [GeneralUtils getWitchEffect];
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
        
        // Get action
        CCAnimation *animPtr = [self.cast getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(castFinished)];
        
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

- (void) castPressed
{
    if ( ![self.castButton isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.castAction];
    }
}

- (void) castFinished
{
    // Send effects
    for ( int i = 0; i < self.targets.count; i++ ) {
        CCParticleSystemQuad *effect = [[GameObjSingleton get] getParticleSystemForFile:@"witch_wave_effect.plist"];
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
            [unit take:10 from:self];
        }
        // Ask our delegate to handle the position and order
        [self.delegate unit:self wantsToPlace:effect];
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.castAction];
}

- (void) reset
{
    [super reset];
    if ( self.moveButton.isUsed ) self.currentCD += self.moveButton.buttonCD;
    if ( self.castButton.isUsed ) self.currentCD += self.castButton.buttonCD;
    self.moveButton.isUsed = NO;
    self.castButton.isUsed = NO;
}
@end
