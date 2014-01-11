//
//  Paladin.m
//  Legends
//
//  Created by David Zhang on 2014-01-11.
//
//
#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Paladin.h"

@interface Paladin ()
@property (nonatomic, strong) UnitAction *idle;
@property (nonatomic, strong) UnitAction *move;
@property (nonatomic, strong) UnitAction *cast;
@property (nonatomic, strong) UnitSkill *moveSkill;
@property (nonatomic, strong) UnitSkill *smiteSkill;
@property (nonatomic, strong) UnitSkill *shieldSkill;

@property (nonatomic, strong) NSMutableArray *targets;
@end

@implementation Paladin
+ (id) paladin:(UnitObject *)object isOwned:(BOOL)owned
{
    return [[Paladin alloc] initPaladin:object isOwned:owned];
}

- (id) initPaladin:(UnitObject *)object isOwned:(BOOL)owned
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
                                               forName:@"paladin_idle"
                                             andFrames:4
                                                 delay:0.1];
    _idle.tag = IDLETAG;
    
    _move = [UnitAction actionsInfiniteWithSpriteSheet:self.spriteSheet
                                               forName:@"paladin_walk"
                                             andFrames:4
                                                 delay:0.1];
    
    _cast = [UnitAction actionsWithSpriteSheet:self.spriteSheet
                                       forName:@"paladin_cast"
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
    
    _smiteSkill = [UnitSkill unitSkill:@"flamebreath"
                               target:self
                             selector:@selector(smitePressed)
                                   CD:1
                                   MC:10
                                   CP:0];
    _smiteSkill.anchorPoint = ccp(0.5, 0.5);
    _smiteSkill.position = ccp(50, 60);
    _smiteSkill.type = ActionSkillOne;
    _smiteSkill.rangeType = RangeNormal;
    _smiteSkill.range = 2;
    _smiteSkill.effectType = RangeOne;
    
    _shieldSkill = [UnitSkill unitSkill:@"shield"
                                target:self
                              selector:@selector(shieldPressed)
                                    CD:0
                                    MC:10
                                    CP:1];
    _shieldSkill.anchorPoint = ccp(0.5, 0.5);
    _shieldSkill.position = ccp(0, 120);
    _shieldSkill.type = ActionSkillTwo;
    _shieldSkill.rangeType = RangeNormalIncForce;
    _shieldSkill.range = 3;
    _shieldSkill.effectType = RangeOne;
    
    self.menu = [CCMenu menuWithItems:_moveSkill, _smiteSkill, _shieldSkill, nil];
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
        CCAnimation *animPtr = [self.cast getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(smiteFinished)];
        
    } else if ( action == ActionSkillTwo ) {
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
        CCAnimation *animPtr = [self.cast getAnimationFor:self.direction];
        
        // Run action
        [self playAnimation:animPtr selector:@selector(shieldFinished)];
        
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

- (void) smitePressed
{
    if ( ![self.smiteSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.smiteSkill] ) {
        self.menu.visible = NO;
    }
}

- (void) shieldPressed
{
    if ( ![self.shieldSkill isUsed] &&
        [self.delegate unit:self wishesToUse:self.shieldSkill] ) {
        self.menu.visible = NO;
    }
}

- (void) smiteFinished
{
    for ( int i = 0; i < self.targets.count; i++ ) {
        id target = [self.targets objectAtIndex:i];
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            
        } else {
            // Type is unit, we can directly communicate with them
            Unit *unit = (Unit *)target;
            
            CombatObject *obj = [CombatObject combatObject];
            obj.type = CombatTypePure;
            obj.amount = 10;
            
            [self combatSend:obj to:unit];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.smiteSkill];
}

- (void) shieldFinished
{
    for ( int i = 0; i < self.targets.count; i++ ) {
        id target = [self.targets objectAtIndex:i];
        if ( [target isKindOfClass:[NSValue class]] ) {
            // Type is NSValue, extract position
            
        } else {
            // Type is unit, we can directly communicate with them
            Unit *unit = (Unit *)target;

            ShieldBuff *buff = [ShieldBuff shieldBuffTarget:unit amount:5];
            [buff start];
        }
    }
    
    // Call our finish delegate function
    [self.delegate unit:self didFinishAction:self.shieldSkill];
}
@end
