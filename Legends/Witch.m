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
@property (nonatomic, strong)    UnitSkill *moveSkill;
@property (nonatomic, strong)    UnitSkill *castSkill;

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
        [self initActions];
        [self initSkills];
    }
    return self;
}

- (void) initActions
{
    _idle = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"witch_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"witch_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _cast = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"witch_cast"
                                     andFrames:3
                                         delay:0.1
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
    
    _castSkill = [UnitSkill unitSkill:@"magic"
                               target:self
                             selector:@selector(castPressed)
                                   CD:2
                                   MC:20
                                   CP:3];
    
    _castSkill.anchorPoint = ccp(0.5, 0.5);
    _castSkill.position = ccp(60, 60);
    _castSkill.type = ActionSkillOne;
    _castSkill.rangeType = RangeUnique;
    _castSkill.areaOfRange = [GeneralUtils getWitchCast];
    _castSkill.effectType = RangeUnique;
    _castSkill.areaOfEffect = [GeneralUtils getWitchEffect];
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _castSkill, nil];
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

- (void) castPressed
{
    if ( ![self.castSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.castSkill] ) {
        self.menu.visible = NO;
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
            
            CombatObject *obj = [CombatObject combatObject];
            obj.type = CombatTypeInt;
            obj.amount = 10;
            [unit combatSend:obj to:unit];
        }
        // Ask our delegate to handle the position and order
        [self.delegate unit:self wantsToPlace:effect];
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.castSkill];
}

- (void) reset
{
    [super reset];
    if ( self.moveSkill.isUsed ) self.currentCD += self.moveSkill.cdCost;
    if ( self.castSkill.isUsed ) self.currentCD += self.castSkill.cdCost;
    self.moveSkill.isUsed = NO;
    self.castSkill.isUsed = NO;
}
@end
