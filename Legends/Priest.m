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
@property (nonatomic, strong)    UnitSkill *moveSkill;
@property (nonatomic, strong)    UnitSkill *healSkill;
@property (nonatomic, strong)    UnitSkill *castSkill;
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

        
        [self initActions];
        [self initSkills];
    }
    return self;
}
- (void) initActions
{
    _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"priest_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"priest_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _heal = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"priest_pray"
                                     andFrames:4
                                         delay:0.15
                                       reverse:NO];
    
    _cast = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"priest_cast"
                                     andFrames:4
                                         delay:0.1
                                       reverse:NO];
}

- (void) initSkills
{
    _moveSkill = [UnitSkill unitSkill:@"move"
                               target:self
                             selector:@selector(movePressed)
                                   CD:UNITSTATS[PRIESTMOVE][0]
                                   MC:UNITSTATS[PRIESTMOVE][1]
                                   CP:UNITSTATS[PRIESTMOVE][2]];
    _moveSkill.anchorPoint = ccp(0.5, 0.5);
    _moveSkill.position = ccp(-50, 60);
    _moveSkill.type = ActionMove;
    _moveSkill.rangeType = RangePathFind;
    _moveSkill.effectType = RangeOne;
    _moveSkill.range = 3;
    
    _healSkill = [UnitSkill unitSkill:@"cross-coloured"
                               target:self
                             selector:@selector(healPressed)
                                   CD:UNITSTATS[PRIESTHEAL][0]
                                   MC:UNITSTATS[PRIESTHEAL][1]
                                   CP:UNITSTATS[PRIESTHEAL][2]];
    _healSkill.anchorPoint = ccp(0.5, 0.5);
    _healSkill.position = ccp(50, 60);
    _healSkill.type = ActionSkillOne;
    _healSkill.rangeType = RangeAllied;
    _healSkill.effectType = RangeAllied;
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _healSkill, nil];
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
        // Save targets
        self.targets = targets;
        
        // Run our particle effect
        CCParticleSystemQuad *eff = [[GameObjSingleton get] getParticleSystemForFile:@"priest_cast_effect.plist"];
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

- (void) healPressed
{
    if ( ![self.healSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.healSkill] ) {
        self.menu.visible = NO;
    }
}

- (void) healFinished
{
    // Send effects??????????????????????????????????????????
    for ( int i = 0; i < self.targets.count; i++ ) {
        CCParticleSystemQuad *effect = [[GameObjSingleton get] getParticleSystemForFile:@"heal_gain_effect.plist"];

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
            obj.amount = self.attributes.intellect;
            
            [self combatSend:obj to:unit];
        }
        // Ask our delegate to handle the position and order
        [self.delegate unit:self wantsToPlace:effect];
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.healSkill];
}

- (void) reset
{
    [super reset];
    if ( self.moveSkill.isUsed ) self.currentCD += self.moveSkill.cdCost;
    if ( self.healSkill.isUsed ) self.currentCD += self.healSkill.cdCost;
    self.moveSkill.isUsed = NO;
    self.healSkill.isUsed = NO;
}
@end