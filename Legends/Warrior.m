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
@property (nonatomic, strong)    UnitSkill *moveSkill;
@property (nonatomic, strong)    UnitSkill *attkSkill;

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
        [self initActions];
        [self initSkills];
    }
    return self;
}

- (void) initActions
{
    _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"warrior_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"warrior_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _attk = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"warrior_slice"
                                     andFrames:3
                                         delay:0.15
                                       reverse:NO];
}

- (void) initSkills
{
    _moveSkill = [UnitSkill unitSkill:@"move"
                               target:self
                             selector:@selector(movePressed)
                                   CD:[self.object.actionMove objectAtIndex:0]
                                   MC:[self.object.actionMove objectAtIndex:1]
                                   CP:[self.object.actionMove objectAtIndex:2]];
    _moveSkill.anchorPoint = ccp(0.5, 0.5);
    _moveSkill.position = ccp(-60, 60);
    _moveSkill.type = ActionMove;
    _moveSkill.rangeType = RangePathFind;
    _moveSkill.range = [self.object.actionMove objectAtIndex:3];
    _moveSkill.effectType = RangeOne;
    
    _attkSkill = [UnitSkill unitSkill:@"melee"
                               target:self
                             selector:@selector(attkPressed)
                                   CD:[self.object.actionSkillOne objectAtIndex:0]
                                   MC:[self.object.actionSkillOne objectAtIndex:1]
                                   CP:[self.object.actionSkillOne objectAtIndex:2]];
    _attkSkill.anchorPoint = ccp(0.5, 0.5);
    _attkSkill.position = ccp(60, 60);
    _attkSkill.type = ActionSkillOne;
    _attkSkill.rangeType = RangeNormal;
    _attkSkill.range = [self.object.actionSkillOne objectAtIndex:3];
    _attkSkill.effectType = RangeOne;
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _attkSkill, nil];
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

- (void) attkPressed
{
    if ( ![self.attkSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.attkSkill] ) {
        self.menu.visible = NO;
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
            obj.amount = self.attributes.strength;
            
            [self combatSend:obj to:unit];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.attkSkill];
}

- (void) reset
{
    [super reset];
    if ( self.moveSkill.isUsed ) self.currentCD += self.moveSkill.cdCost;
    if ( self.attkSkill.isUsed ) self.currentCD += self.attkSkill.cdCost;
    self.moveSkill.isUsed = NO;
    self.attkSkill.isUsed = NO;
}
@end
