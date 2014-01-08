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
    self.menu.position = CGPointZero;
    self.menu.anchorPoint = ccp(0.5, 0.5);
    [self addChild:self.menu];
}

- (void) initActions
{
    _moveAction = [[ActionObject alloc] init];
    _moveAction.type = ActionMove;
    _moveAction.rangeType = RangePathFind;
    _moveAction.effectType = RangeOne;
    _moveAction.range = 3;
    
    _healAction = [[ActionObject alloc] init];
    _healAction.type = ActionSkillOne;
    _healAction.rangeType = RangeAllied;
    _healAction.effectType = RangeAllied;
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
        eff.position = ccp(0,25);
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
        CCParticleSystemQuad *effect = [[GameObjSingleton get] getParticleSystemForFile:@"heal_gain_effect.plist"];
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
            
            CombatObject *obj = [CombatObject combatObject];
            obj.type = CombatTypeHeal;
            obj.amount = 10;
            
            [self combatSend:obj to:unit];
        }
        // Ask our delegate to handle the position and order
        [self.delegate unit:self wantsToPlace:effect];
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.healAction];
}

- (void) reset
{
    [super reset];
    if ( self.moveButton.isUsed ) self.currentCD += self.moveButton.buttonCD;
    if ( self.healButton.isUsed ) self.currentCD += self.healButton.buttonCD;
    self.moveButton.isUsed = NO;
    self.healButton.isUsed = NO;
}
@end