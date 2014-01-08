//
//  Warrior.m
//  Legends
//
//  Created by David Zhang on 2013-12-23.
//
//

#import "Warrior.h"
@interface Warrior()
@property (nonatomic, strong)   UnitAction *idle;
@property (nonatomic, strong)   UnitAction *move;
@property (nonatomic, strong)   UnitAction *attk;
@property (nonatomic, strong)   UnitButton *moveButton;
@property (nonatomic, strong)   UnitButton *attkButton;
@property (nonatomic, strong) ActionObject *moveAction;
@property (nonatomic, strong) ActionObject *attkAction;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Warrior
#pragma mark - Init n shit
+ (id) warrior:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Warrior alloc] initWarrior:object isOwned:owned];
}

- (id) initWarrior:(UnitObject *)object isOwned:(BOOL)owned
{
    self = [super initUnit:object isOwned:owned];
    if ( self ) {
        _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"warrior_idle" andFrames:4 delay:0.1];
        _idle.tag = IDLETAG;
        
        _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"warrior_walk" andFrames:4 delay:0.1];
        
        _attk = [UnitAction actionsWithSpriteSheet:self.spriteSheet forName:@"warrior_slice" andFrames:3 delay:0.15 reverse:NO];
        
        [self initButtons];
        [self initActions];
    }
    return self;
}

- (void) initButtons
{
    _moveButton = [UnitButton UnitButtonWithName:@"move" CD:0 MC:100 target:self selector:@selector(movePressed)];
    _moveButton.anchorPoint = ccp(0.5, 0.5);
    _moveButton.position = ccp(-50, 60);
    
    _attkButton = [UnitButton UnitButtonWithName:@"melee" CD:1 MC:100 target:self selector:@selector(attkPressed)];
    _attkButton.anchorPoint = ccp(0.5, 0.5);
    _attkButton.position = ccp(50, 60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _attkButton, nil];
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

    
    _attkAction = [[ActionObject alloc] init];
    _attkAction.type = ActionSkillOne;
    _attkAction.rangeType = RangeNormal;
    _attkAction.range = 1;
    _attkAction.effectType = RangeOne;
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
        // Save target
        self.targets = targets;
        
        // Get action
        id target = [self.targets firstObject];
        CGPoint targetPos;
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            targetPos = [target CGPointValue];
        } else {
            // Type is unit, we can directly communicate with them
            targetPos = ((Unit *)target).boardPos;
            
        }
        self.direction = [GeneralUtils getDirection:self.boardPos to:targetPos];
        NSLog(@"%@ %@",NSStringFromCGPoint(self.boardPos), NSStringFromCGPoint(targetPos));
        CCAnimation *animPtr = [self.attk getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(attkFinished)];
        
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

- (void) attkPressed
{
    if ( ![self.attkButton isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.attkAction];
    }
}

- (void) attkFinished
{
    for ( int i = 0; i < self.targets.count; i++ ) {
        id target = [self.targets objectAtIndex:i];
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            
        } else {
            // Type is unit, we can directly communicate with them
            Unit *unit = (Unit *)target;
            
            CombatObject *obj = [CombatObject combatObject];
            obj.type = CombatTypeStr;
            obj.amount = 10;
            
            [self combatSend:obj to:unit];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.attkAction];
}

- (void) reset
{
    [super reset];
    if ( self.moveButton.isUsed ) self.currentCD += self.moveButton.buttonCD;
    if ( self.attkButton.isUsed ) self.currentCD += self.attkButton.buttonCD;
    self.moveButton.isUsed = NO;
    self.attkButton.isUsed = NO;
}
@end
