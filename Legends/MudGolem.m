//
//  MudGolem.m
//  Legends
//
//  Created by David Zhang on 2013-06-26.
//
//
#define MUDGOLEMSCALE 0.85
#define MUDGOLEMSETUPSCALE MUDGOLEMSCALE * SETUPMAPSCALE
#import "MudGolem.h"

@interface MudGolem()
// if it has a button, it has a skill object
@property (nonatomic, strong) SkillObj *moveSkill;
@property (nonatomic, strong) SkillObj *attackSkill;
@property (nonatomic, strong) SkillObj *earthquakeSkill;
@end

@implementation MudGolem
const NSString *MUDGOLEM_ONE_DESP = @"Melee - Physical";
const NSString *MUDGOLEM_TWO_DESP = @"Range - Physical";
const NSString *MUDGOLEM_MOVE_DESP = @"Teleporting";

@synthesize idle                = _idle;
@synthesize move                = _move;
@synthesize moveEnd             = _moveEnd;
@synthesize attk                = _attk;
@synthesize earthquake          = _earthquake;
@synthesize moveButton          = _moveButton;
@synthesize attkButton          = _attkButton;
@synthesize earthquakeButton    = _earthquakeButton;
// Stuff from Unit
@synthesize direction           = _direction;
@synthesize position            = _position;


#pragma mark - Setters and getters
- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    self.sprite.position = [self convertToNodeSpace:position];
}

- (CGPoint) position
{
    return [super position];
}

- (void) setDirection:(Direction)direction
{
    if ( direction == NE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_NE_0.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_NW_0.png"]];
    else if ( direction == SE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_SE_0.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_SW_0.png"]];
    
    _direction = direction;
}


#pragma mark - Alloc n Init
+ (id) mudGolemFor:(BOOL)side withObj:(UnitObj *)obj
{
    return [[MudGolem alloc] initMudGolemFor:side withObj:obj];
}

- (id) initMudGolemFor:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super initForSide:side withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mudgolem_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mudgolem_default.png"];
        
        _idle = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"mudgolem_idle" andFrames:2 delay:0.5];
        _idle.tag = IDLETAG;

        _move = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_sink" andFrames:6 delay:0.1 reverse:NO];
        _moveEnd = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_sink" andFrames:6 delay:0.1 reverse:YES];
        _attk = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_punch" andFrames:4 delay:0.12 reverse:NO];
        _earthquake = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_smash" andFrames:7 delay:0.1 reverse:NO];
        
        if ( side ) {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"mudgolem_idle_NE_0.png"];
        } else {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"mudgolem_idle_SW_0.png"];
        }
        self.sprite.scale = MUDGOLEMSCALE;
        [self.spriteSheet addChild:self.sprite z:0];
        
        /* Other inits */
        [self initMenu];
        [self initEffects];
        
        /* add everything now */
        [self addChild:self.spriteSheet];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithActionName:@"phase" cost:1
                                              target:self selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    _moveButton.costOfButton = 1;
    _moveSkill = [[MoveSkillObj alloc] initWithRange:self.obj.movespeed];
    _moveSkill.skillType = ActionTeleport;
    _moveSkill.skillRank = 0; //#FIXITLATER
    _moveSkill.skillCost = 1;

    _attkButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_melee.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(attkPressed)];
    _attkButton.position = ccp(0,85);
    _attkButton.costOfButton = 1;
    _attackSkill = [[SkillObj alloc] init];
    _attackSkill.skillType = ActionMelee;
    _attackSkill.skillRank = 0; //#FIXITLATER
    _attackSkill.skillRange = [self getAttkArea:0];
    _attackSkill.skillEffect = [self getAttkEffect:0];
    _attackSkill.skillCost = 1;
    
    _earthquakeButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_earthquake.png"]
                                              selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                              disabledSprite:nil
                                                      target:self
                                                    selector:@selector(earthquakePressed)];
    _earthquakeButton.position = ccp(50,60);
    _earthquakeButton.costOfButton = 2;
    _earthquakeSkill = [[SkillObj alloc] init];
    _earthquakeSkill.skillType = ActionMeleeAOE;
    _earthquakeSkill.skillRank = 0; //#FIXITLATER
    _earthquakeSkill.skillRange = [self getEarthquakeArea:0];
    _earthquakeSkill.skillEffect = [self getEarthquakeEffect:0];
    _earthquakeSkill.skillCost = 2;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _attkButton, _earthquakeButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects
{
    [super initEffects];
}


#pragma mark - Actions + combat
- (void) secondaryAction:(Action)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.position);
    if ( action != ActionIdle && action != ActionDie && action != ActionMeleeAOE) {
        [self setDirectionWithDifference:difference];
    }
    
    if ( action == ActionIdle ) {
        [self.delegate unitDelegateUnit:self finishedAction:ActionIdle];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == ActionMove ) {
        [self.moveButton setIsUsed:YES];
        
        /////////
        id delay = [CCDelayTime actionWithDuration:0.4];
        /////////
        id move1 = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:[self.move getActionFor:self.direction]]; }];
        id fadeout = [CCFadeOut actionWithDuration:0.2];
        id fade1 = [CCSequence actions:delay, fadeout,  nil];
        id sink = [CCSpawn actions:move1, fade1, nil];
        /////////
        id move2 = [CCCallBlock actionWithBlock:^{
            self.position = position;
            [self.sprite runAction:[self.moveEnd getActionFor:self.direction]];
        }];
        id fadein = [CCFadeIn actionWithDuration:0.2];
        id fade2 = [CCSequence actions:fadein, delay, nil];
        id rise = [CCSpawn actions:move2, fade2, nil];
        /////////
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:sink, rise, finish, nil]];
            
    } else {
        [super secondaryAction:action at:position];
    }
}

- (void) primaryAction:(Action)action targets:(NSArray *)targets
{    
    [self.sprite stopAllActions];

    if ( action == ActionMelee ) {
        [self.attkButton setIsUsed:YES];
        [self.earthquakeButton setIsUsed:YES];
        
        /* single target */
        UnitDamage *dmgTarget = [targets objectAtIndex:0];
        CGPoint difference = ccpSub(dmgTarget.target.sprite.position,
                                    self.position);
        // Find the facing direction
        [self setDirectionWithDifference:difference];
        
        // 1
        id begin = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.attk getActionFor:self.direction]];
        }];
        // 2
        id swingdelay = [CCDelayTime actionWithDuration:0.1];
        // 3
        id hit = [CCCallBlock actionWithBlock:^{
            [dmgTarget.target damageHealth:dmgTarget.damage];
        }];
        // 4
        id swingfinish = [CCDelayTime actionWithDuration:0.3];
        // 5
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:begin, swingdelay, hit, swingfinish, finish, nil]];
        
    } else if ( action == ActionMeleeAOE ) {
        [self.earthquakeButton setIsUsed:YES];
        [self.attkButton setIsUsed:YES];
        
        CCSprite *crack = [CCSprite spriteWithSpriteFrameName:@"earthquake_crack.png"];
        [self.delegate unitDelegateAddSprite:crack z:GROUND];
        crack.position = self.position;
        crack.visible = NO;
        
        // 1
        id begin = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.earthquake getActionFor:self.direction]];
        }];
        // 2
        id swingdelay = [CCDelayTime actionWithDuration:0.6];
        // 3
        id finish = [CCCallBlock actionWithBlock:^{
            crack.visible = YES;
            for ( UnitDamage *dmgTarget in targets) {
                [dmgTarget.target damageHealth:dmgTarget.damage];
            }
            [self.delegate unitDelegateShakeScreen];
            [self.sprite stopAllActions];
            [self secondaryAction:ActionIdle at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        // 4
        id crackDelay = [CCDelayTime actionWithDuration:4.6];
        // 5
        id crackFade = [CCFadeOut actionWithDuration:2];
        // 6
        id crackEnd = [CCCallBlock actionWithBlock:^{
            [self.delegate unitDelegateRemoveSprite:crack];
        }];
        
        [self.sprite runAction:[CCSequence actions:begin, swingdelay, finish, nil]];
        [crack runAction:[CCSequence actions: crackDelay, crackFade, crackEnd, nil]];
    }
}

- (void) damageHealth:(DamageObj *)dmg
{
    NSString *directionFrame;
    if ( self.direction == NE )
        directionFrame = @"mudgolem_knockback_NE.png";
    else if ( self.direction == NW )
        directionFrame = @"mudgolem_knockback_NW.png";
    else if ( self.direction == SE )
        directionFrame = @"mudgolem_knockback_SE.png";
    else if ( self.direction == SW )
        directionFrame = @"mudgolem_knockback_SW.png";
    [self.sprite setDisplayFrame:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:directionFrame]];
    
    [super damageHealth:dmg];
}

#pragma mark - Menu controls
- (BOOL) canIDo:(Action)action
{
    if ( action == ActionMeleeAOE ) {
        return YES;
    } else {
        return [super canIDo:action];
    }
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:ActionTeleport] ) {
        if ( [self.delegate unitDelegatePressedSkill:self.moveSkill] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) attkPressed
{
    if ( ![self.attkButton isUsed] && [self canIDo:ActionMelee] ) {
        if ( [self.delegate unitDelegatePressedSkill:self.attackSkill] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) earthquakePressed
{
    if ( ![self.earthquakeButton isUsed] && [self canIDo:ActionMeleeAOE] ) {
        if ( [self.delegate unitDelegatePressedSkill:self.earthquakeSkill] ) {
            [self toggleMenu:NO];
        }
    }
}


#pragma mark - Misc
- (NSString *) description
{
    return [NSString stringWithFormat:@"Mud Golem"];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed ) self.coolDown += self.moveButton.costOfButton;
    if ( self.attkButton.isUsed ) self.coolDown += self.attkButton.costOfButton;
    if ( self.earthquakeButton.isUsed ) self.coolDown += self.earthquakeButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.attkButton.isUsed = NO;
    self.earthquakeButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed ||
            !self.attkButton.isUsed ||
            !self.earthquakeButton.isUsed;
}


#pragma mark - Mud golem shit
- (NSMutableArray *) getAttkArea:(int)rank
{
    return [GeneralUtils getDiamondArea:1];
}

- (NSMutableArray *) getAttkEffect:(int)rank
{
    return [GeneralUtils getOneArea];
}

- (NSMutableArray *) getEarthquakeArea:(int)rank
{
    return [GeneralUtils getOneArea];
}

- (NSMutableArray *) getEarthquakeEffect:(int)rank
{
    return [GeneralUtils getDiamondAreaWithMe:3];
}

@end
