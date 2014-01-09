//
//  Knight.m
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "Knight.h"

@interface Knight()
@property (nonatomic, strong)   UnitAction *idle;
@property (nonatomic, strong)   UnitAction *move;
@property (nonatomic, strong)   UnitAction *attk;
@property (nonatomic, strong)    UnitSkill *moveSkill;
@property (nonatomic, strong)    UnitSkill *attkSkill;
@property (nonatomic, strong)    UnitSkill *guardSkill;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Knight
#pragma mark - Init n shit
+ (id) knight:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Knight alloc] initKnight:object isOwned:owned];
}

- (id) initKnight:(UnitObject *)object isOwned:(BOOL)owned
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
                                               forName:@"knight_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"knight_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _attk = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"knight_swing"
                                     andFrames:3
                                         delay:0.15
                                       reverse:NO];
}

- (void) initSkills
{
    _moveSkill = [UnitSkill unitSkill:@"move"
                               target:self
                             selector:@selector(movePressed)
                                   CD:0
                                   MC:10
                                   CP:1];
    _moveSkill.anchorPoint = ccp(0.5, 0.5);
    _moveSkill.position = ccp(-50, 60);
    _moveSkill.type = ActionMove;
    _moveSkill.rangeType = RangePathFind;
    _moveSkill.range = 3;
    _moveSkill.effectType = RangeOne;
    
    _attkSkill = [UnitSkill unitSkill:@"melee"
                               target:self
                             selector:@selector(attkPressed)
                                   CD:1
                                   MC:10
                                   CP:0];
    _attkSkill.anchorPoint = ccp(0.5, 0.5);
    _attkSkill.position = ccp(50, 60);
    _attkSkill.type = ActionSkillOne;
    _attkSkill.rangeType = RangeNormal;
    _attkSkill.range = 1;
    _attkSkill.effectType = RangeOne;
    
    _guardSkill = [UnitSkill unitSkill:@"shield"
                                target:self
                              selector:@selector(guardPressed)
                                    CD:0
                                    MC:10
                                    CP:1];
    _guardSkill.anchorPoint = ccp(0.5, 0.5);
    _guardSkill.position = ccp(0, 120);
    _guardSkill.type = ActionSkillTwo;
    _guardSkill.rangeType = RangeOne;
    _guardSkill.effectType = RangeOne;
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _attkSkill, _guardSkill, nil];
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
        
    } else if ( action == ActionSkillTwo ) {
        // Create the buff
        BuffObject *buff = [GuardBuff guardBuffTarget:self];
        [buff start];
        
        [self.delegate unit:self didFinishAction:self.guardSkill];
        
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
    id moveCallBack = [CCCallBlock actionWithBlock:^{
        [self.delegate unit:self didMoveTo:s.boardPos];
    }];
    id moveAction = [CCMoveTo actionWithDuration:duration position:s.position];
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(actionWalk)];
    
    // Play actions
    [self runAction:[CCSequence actions:moveStart, moveCallBack, moveAction, moveCallback, nil]];
}










#pragma mark - Selectors
- (void) movePressed
{
    if ( ![self.moveSkill isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.moveSkill];
    }
}

- (void) attkPressed
{
    if ( ![self.attkSkill isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.attkSkill];
    }
}

- (void) guardPressed
{
    if ( ![self.guardSkill isUsed] ) {
        self.menu.visible = NO;
        [self.delegate unit:self didPress:self.guardSkill];
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
