//
//  Ranger.m
//  Legends
//
//  Created by David Zhang on 2013-12-23.
//
//

#import "Ranger.h"
@interface Ranger()
@property (nonatomic, strong)   UnitAction *idle;
@property (nonatomic, strong)   UnitAction *move;
@property (nonatomic, strong)   UnitAction *shoot;
@property (nonatomic, strong)   UnitButton *moveButton;
@property (nonatomic, strong)   UnitButton *shootButton;
@property (nonatomic, strong) ActionObject *moveAction;
@property (nonatomic, strong) ActionObject *shootAction;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Ranger
#pragma mark - Init n shit
+ (id) ranger:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Ranger alloc] initRanger:object isOwned:owned];
}

- (id) initRanger:(UnitObject *)object isOwned:(BOOL)owned
{
    self = [super initUnit:object isOwned:owned];
    if ( self ) {
        _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"ranger_idle" andFrames:4 delay:0.1];
        _idle.tag = IDLETAG;
        
        _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"ranger_walk" andFrames:4 delay:0.1];
        
        _shoot = [UnitAction actionsWithSpriteSheet:self.spriteSheet forName:@"ranger_shoot" andFrames:3 delay:0.15 reverse:NO];
        
        [self initButtons];
        [self initActions];
    }
    return self;
}

- (void) initButtons
{
    _moveButton = [UnitButton UnitButtonWithName:@"move" CD:1 MC:100 target:self selector:@selector(movePressed)];
    _moveButton.anchorPoint = ccp(0.5, 0.5);
    _moveButton.position = ccp(-50, 60);
    
    _shootButton = [UnitButton UnitButtonWithName:@"ranged" CD:1 MC:100 target:self selector:@selector(shootPressed)];
    _shootButton.anchorPoint = ccp(0.5, 0.5);
    _shootButton.position = ccp(50, 60);
    
    self.menu = [CCMenu menuWithItems:_moveButton, _shootButton, nil];
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

    
    _shootAction = [[ActionObject alloc] init];
    _shootAction.type = ActionSkillOne;
    _shootAction.rangeType = RangeLOS;
    _shootAction.range = 4;
    _shootAction.effectType = RangeOne;
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
        CCAnimation *animPtr = [self.shoot getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(shootFinished)];
        
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

- (void) shootPressed
{
    if ( ![self.shootButton isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.shootAction];
    }
}

- (void) shootFinished
{
    for ( int i = 0; i < self.targets.count; i++ ) {
        id target = [self.targets objectAtIndex:i];
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            
        } else {
            // Type is unit, we can directly communicate with them
            Unit *unit = (Unit *)target;
            [unit take:10 from:self];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.shootAction];
}

- (void) reset
{
    [super reset];
    if ( self.moveButton.isUsed ) self.currentCD += self.moveButton.buttonCD;
    if ( self.shootButton.isUsed ) self.currentCD += self.shootButton.buttonCD;
    self.moveButton.isUsed = NO;
    self.shootButton.isUsed = NO;
}
@end
