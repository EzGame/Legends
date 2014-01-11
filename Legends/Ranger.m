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
@property (nonatomic, strong)    UnitSkill *moveSkill;
@property (nonatomic, strong)    UnitSkill *shootSkill;

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
        [self initActions];
        [self initSkills];
    }
    return self;
}

- (void) initActions
{
    _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"ranger_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"ranger_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _shoot = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                        forName:@"ranger_shoot"
                                      andFrames:3
                                          delay:0.15
                                        reverse:NO];
}

- (void) initSkills
{
    _moveSkill = [UnitSkill unitSkill:@"move"
                               target:self
                             selector:@selector(movePressed)
                                   CD:1
                                   MC:10
                                   CP:1];
    _moveSkill.anchorPoint = ccp(0.5, 0.5);
    _moveSkill.position = ccp(-60, 60);
    _moveSkill.type = ActionMove;
    _moveSkill.rangeType = RangePathFind;
    _moveSkill.range = 3;
    _moveSkill.effectType = RangeOne;
    
    _shootSkill = [UnitSkill unitSkill:@"ranged"
                                target:self
                              selector:@selector(shootPressed)
                                    CD:1
                                    MC:10
                                    CP:1];
    _shootSkill.anchorPoint = ccp(0.5, 0.5);
    _shootSkill.position = ccp(60, 60);
    _shootSkill.type = ActionSkillOne;
    _shootSkill.rangeType = RangeLOS;
    _shootSkill.range = 4;
    _shootSkill.effectType = RangeOne;
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _shootSkill, nil];
    self.menu.visible = NO;
    self.menu.position = CGPointZero;
    self.menu.anchorPoint = ccp(0.5, 0.5);
    [self addChild:self.menu];
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
        [self.delegate unit:self didFinishAction:self.moveSkill];
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
    id moveDelegate = [CCCallBlock actionWithBlock:^{
        [self.delegate unit:self didMoveTo:s.boardPos];
    }];
    id moveAction = [CCMoveTo actionWithDuration:duration position:s.position];
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(actionWalk)];
    
    // Play actions
    [self runAction:[CCSequence actions:moveStart, moveDelegate, moveAction, moveCallback, nil]];
}




#pragma mark - Selectors
- (void) movePressed
{
    if ( ![self.moveSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.moveSkill] ) {
        self.menu.visible = NO;
    }
}

- (void) shootPressed
{
    if ( ![self.shootSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.shootSkill] ) {
        self.menu.visible = NO;
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
            
            CombatObject *obj = [CombatObject combatObject];
            obj.type = CombatTypeAgi;
            obj.amount = 10;
            
            [self combatSend:obj to:unit];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.moveSkill];
}

- (void) reset
{
    [super reset];
    if ( self.moveSkill.isUsed ) self.currentCD += self.moveSkill.cdCost;
    if ( self.shootSkill.isUsed ) self.currentCD += self.shootSkill.cdCost;
    self.moveSkill.isUsed = NO;
    self.shootSkill.isUsed = NO;
}
@end
