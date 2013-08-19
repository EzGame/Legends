//
//  Unit.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Unit.h"

#pragma mark - Unit:
@implementation Unit
@synthesize sprite          = _sprite;
@synthesize spriteSheet     = _spriteSheet;
@synthesize menu            = _menu;
@synthesize death           = _death;
@synthesize health_bar      = _health_bar;

@synthesize spOpenSteps     = _spOpenSteps;
@synthesize spClosedSteps   = _spClosedSteps;
@synthesize shortestPath    = _shortestPath;

@synthesize attribute       = _attribute;
@synthesize obj             = _obj;
@synthesize myBuffs         = _myBuffs;
@synthesize buffs           = _buffs;

@synthesize isOwned         = _isOwned;
@synthesize coolDown        = _coolDown;
@synthesize direction       = _direction;
@synthesize boardPos        = _boardPos;
@synthesize current_hp      = _current_hp;
@synthesize maximum_hp      = _maximum_hp;

@synthesize position        = _position;

#pragma mark - Unit: inits
- (id) initForSide:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super init];
    if ( self )
    {
        _health_bar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"unit_health_bar.png"]];
        _health_bar.type = kCCProgressTimerTypeBar;
        _health_bar.color = (side) ? ccGREEN : ccRED;
        _health_bar.midpoint = ccp(0.0, 0.5f);
        _health_bar.barChangeRate = ccp(1,0);
        _health_bar.percentage = 100;
        _health_bar.position = ccpAdd(self.position,ccp(0,-10));
        [self addChild:_health_bar z:1];
        
        _spOpenSteps = nil;
        _spClosedSteps = nil;
        _shortestPath = nil;
        
        _attribute = [Attributes attributesWithStats:obj.stats delegate:self];
        _obj = obj;
        _myBuffs = [NSMutableArray array];
        _buffs = [NSMutableArray array];

        _isOwned = side;
        _direction = (side) ? NE : SW;
    }
    return self;
}

- (void) initEffects
{
    // These are public effects
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"general_default.plist"];

    // Secondary node
    CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"general_default.png"];
        
    // DEATH
    NSMutableArray *frames = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"deathorb_%d.png",i]]];
    }
    
    CCAnimation *animation = [[CCAnimation alloc] initWithSpriteFrames:frames delay:0.1];
    animation.restoreOriginalFrame = NO;
    _death = [[CCAnimate alloc] initWithAnimation:animation];
    
    [self addChild:spriteSheet2];
}


#pragma mark - Setters n Getters
- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    self.health_bar.position = [self convertToNodeSpace:ccpAdd(position, ccp(0,-20))];
}

- (CGPoint) position
{
    return [self convertToWorldSpace:_position];
}

- (void) setCoolDown:(int)coolDown
{
    _coolDown = MAX(0, coolDown);
}

- (void) setDirectionWithDifference:(CGPoint)difference
{
    if (difference.x >= 0 && difference.y >= 0)
        self.direction = NE;
    else if (difference.x >= 0 && difference.y < 0)
        self.direction = SE;
    else if (difference.x < 0 && difference.y < 0)
        self.direction = SW;
    else
        self.direction = NW;
}

- (void) setCurrent_hp:(int)current_hp
{
    _current_hp = MIN( current_hp, _maximum_hp );
    int new_percentage = (_current_hp * 1.0/ _maximum_hp) * 100;
    [_health_bar runAction:[CCSequence actions:
                            [CCActionTween actionWithDuration:2
                                                          key:@"percentage"
                                                         from:self.health_bar.percentage
                                                           to:new_percentage],
                            [CCDelayTime actionWithDuration:2],
                            [CCCallBlock actionWithBlock:^{
                                if ( _current_hp < 1 ) [self action:DEAD at:CGPointZero];
                            }], nil] ];
}

- (void) setMaximum_hp:(int)maximum_hp
{
    _maximum_hp = maximum_hp;
    if ( !self.current_hp )
        self.current_hp = maximum_hp;
    self.current_hp = self.current_hp * self.health_bar.percentage / 100;
}


#pragma mark - Skills
- (void) action:(int)action at:(CGPoint)position
{
    if ( action == DEAD ) {
        CCSprite *orb = [CCSprite spriteWithSpriteFrameName:@"deathorb_0.png"];
        [self.delegate unitDelegateAddSprite:orb z:EFFECTS];
        orb.position = self.sprite.position;
        orb.visible = NO;
        
        id towhite = [CCTintTo actionWithDuration:0.5 red:0 green:0 blue:0];
        id fade = [CCFadeOut actionWithDuration:0.5];
        id form = [CCCallBlock actionWithBlock:^{
            orb.visible = YES;
            [orb runAction:self.death];
        }];
        id die = [CCSequence actions:towhite, fade, form, nil];
        ///////
        id begin = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:die]; }];
        id delay = [CCDelayTime actionWithDuration:1.85];
        id orbfade = [CCCallBlock actionWithBlock:^{ [orb runAction:[CCFadeOut actionWithDuration:1]];}];
        id orbfadedelay = [CCDelayTime actionWithDuration:1];
        id finish = [CCCallBlock actionWithBlock:^{
            self.sprite.visible = false;
            [self.delegate unitDelegateRemoveSprite:orb];
            [self.delegate unitDelegateKillMe:self at:self.position];
        }];
        
        [self.sprite runAction:[CCSequence actions:begin, delay, orbfade, orbfadedelay, finish, nil]];
    } else {
        NSLog(@"It aint death rofl");
    }
}

- (void) combatAction:(int)action targets:(NSArray *)targets
{ return; }

- (void) popStepAndAnimate
{ return; }

- (BOOL) canIDo:(int)action
{
    if ( action == MOVE )
        return !isStoned && !isStunned && !isFrozen && !isEnsnared;
    else if ( action == ATTK )
        return !isStoned && !isStunned && !isFrozen;
    else if ( action == DEFN )
        return !isStoned && !isStunned && !isFrozen;
    else // menu asking, always the least needy option
        return !isStoned && !isStunned && !isFrozen;
}

#pragma mark - Actions
- (void) damageHealth:(DamageObj *)dmg
{    
    [self.sprite runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccRED];
         [self.delegate unitDelegateDisplayCombatMessage:[NSString stringWithFormat:@"%d",dmg.damage]
                                              atPosition:self.position
                                               withColor:ccRED
                                                  isCrit:dmg.isCrit];
     }],
      [CCDelayTime actionWithDuration:0.5],
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccWHITE];
         self.current_hp -= dmg.damage;
         self.direction = self.direction;
     }], nil]];
}

- (void) healHealth:(DamageObj *)dmg
{
    [self.sprite runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccGREEN];
         self.current_hp += dmg.damage;
         [self.delegate unitDelegateDisplayCombatMessage:[NSString stringWithFormat:@"+%d",dmg.damage]
                                              atPosition:self.position
                                               withColor:ccGREEN
                                                  isCrit:dmg.isCrit];
      }],
      [CCDelayTime actionWithDuration:0.2],
      [CCTintTo actionWithDuration:1 red:255 green:255 blue:255],
    nil]];
}

- (void) addBuff:(Buff *)buff caster:(BOOL)amICaster
{
    if ( amICaster ) {
        [self.myBuffs addObject:buff];
    } else {
        [self.buffs addObject:buff];
    }
}

- (void) removeBuff:(Buff *)buff caster:(BOOL)amICaster
{
    if ( amICaster ) {
        [self.myBuffs removeObject:buff];
    } else {
        [self.buffs removeObject:buff];
    }
}


#pragma mark - Menu
- (void) toggleMenu:(BOOL)state {
    if ( state == self.menu.visible ) return;
    
    if ( state && [self canIDo:UNKNOWN] && self.coolDown == 0 && [self hasActionLeft] ) {
        NSLog(@">[MYLOG]    Opening menu");
        self.menu.position = self.position;
        if ( self.menu.visible == NO ) {
            id visible = [CCCallBlock actionWithBlock:^{self.menu.visible = YES;}];
            [self.menu runAction:[CCSequence actions: visible, [CCFadeIn actionWithDuration:0.5], nil]];
        }
    } else {
        NSLog(@">[MYLOG]    Closing menu");
        if ( self.menu.visible == YES ) {
            id invisible = [CCCallBlock actionWithBlock:^{self.menu.visible = NO;}];
            [self.menu runAction:[CCSequence actions: [CCFadeOut actionWithDuration:0.1], invisible, nil]];
        }
        
    }
}

- (void) reset
{
    NSLog(@">[RESET]    Unit %@", self);
    for (Buff *buff in self.myBuffs) {
        [buff reset];
    }
    return;
}

- (BOOL) hasActionLeft {
    NSAssert(false,@">[FATAL]  THIS FUNCTION MUST BE SUBCLASSED");
    return NO;
}


#pragma mark - Other
- (float) getAngle:(CGPoint)p1 :(CGPoint)p2
{
    float dx, dy, angle;
    
    dx = p2.x - p1.x;
    dy = p2.y - p1.y;
    angle = atan(dy / dx) * 180 / M_PI;
    NSLog(@">>>>>>>>>>>>ANGLE IS %f",-angle);
    return ( -angle < 0 )? -angle+180 : -angle;
}

- (int) getValue
{
    return floor(self.obj.level/10.0f) * 10;
}


#pragma mark - Attribute Delegates
- (void) attributesDelegateMaximumHealth:(int)health
{
    self.maximum_hp = health;
}

- (void) attributesDelegateCurrentHealth:(int)health
{
    self.current_hp = health;
}


#pragma mark - Buff Delegates
- (void) damage:(int)damage type:(int)type fromBuff:(Buff *)buff fromCaster:(id)caster
{
    DamageObj *obj = [DamageObj damageObjWith:damage isCrit:NO];
    [self damageHealth:obj];
}

- (void) buffCasterStarted:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for buff started");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        isFocused = YES;
        [self addBuff:buff caster:YES];
    } else if ( [buff isKindOfClass:[BlazeDebuff class]] ) {
        NSLog(@"%@ just casted blaze", self);
        [self addBuff:buff caster:YES];
    }
}

- (void) buffCasterFinished:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for buff ended");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        isFocused = NO;
        [self removeBuff:buff caster:YES];
    } else if ( [buff isKindOfClass:[BlazeDebuff class]] ) {
        NSLog(@"%@'s blaze ended", self);
        [self removeBuff:buff caster:YES];
    }
}

- (void) buffTargetStarted:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - Target for buff started");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]]) {
        isStoned = YES;
        [self addBuff:buff caster:NO];
    }
}

- (void) buffTargetFinished:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - Target for buff ended");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]]) {
        isStoned = NO;
        [self removeBuff:buff caster:NO];
    }
}
@end


#pragma mark - UnitDamage
@implementation UnitDamage
@synthesize target = _target;
@synthesize damage = _damage;

+ (id) unitDamageTarget:(Unit *)target damage:(DamageObj *)damage;
{
    return [[UnitDamage alloc] initDamageTarget:target damage:damage];
}


- (id) initDamageTarget:(Unit *)target damage:(DamageObj *)damage;
{
    self = [super init];
    if ( self ) {
        _target = target;
        _damage = damage;
    }
    return self;
}
@end


#pragma mark - A*
@implementation ShortestPathStep

@synthesize position;
@synthesize boardPos;
@synthesize gScore;
@synthesize hScore;
@synthesize parent;

- (id)initWithPosition:(CGPoint)pos boardPos:(CGPoint)bpos;
{
	if ((self = [super init])) {
		position = pos;
        boardPos = bpos;
		gScore = 0;
		hScore = 0;
		parent = nil;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@  pos=%@%@  g=%d  h=%d  f=%d", [super description], NSStringFromCGPoint(position), NSStringFromCGPoint(boardPos), self.gScore, self.hScore, [self fScore]];
}

- (BOOL)isEqual:(ShortestPathStep *)other
{
	return CGPointEqualToPoint(self.position, other.position);
}

- (int)fScore
{
	return self.gScore + self.hScore;
}

@end


#pragma mark - SETUP
@interface SetupUnit ()
@end

@implementation SetupUnit
@synthesize sprite = _sprite;
@synthesize obj = _obj;
@synthesize attribute = _attribute;
@synthesize direction = _direction;
@synthesize position = _position;
- (void) attributesDelegateCurrentHealth:(int)health
{
}

- (void) attributesDelegateMaximumHealth:(int)health
{
}

- (void) setPosition:(CGPoint)position
{
    _position = position;
    self.sprite.position = position;
}

- (void) setDirection:(int)direction
{
    if ( direction == NE )
        [self.sprite setTexture:[ready texture]];
    else if ( direction == SW )
        [self.sprite setTexture:[reserve texture]];
    _direction = direction;
}

+ (id) setupUnitWithObj:(UnitObj *)obj
{
    return [[SetupUnit alloc] initSetupUnitWithObj:obj];
}

- (id) initSetupUnitWithObj:(UnitObj *)obj
{
    self = [super init];
    if ( self ) {
        _obj = obj;
        reserve = [CCSprite spriteWithFile:
                   [NSString stringWithFormat:@"%@_reserve.png",
                    [self stringForType:self.obj.type]]];
        ready = [CCSprite spriteWithFile:
                 [NSString stringWithFormat:@"%@_ready.png",
                  [self stringForType:self.obj.type]]];
        
        if ( CGPointEqualToPoint(obj.position, ccp(-1,-1)) ) {
            _direction = SW;
            _sprite = [CCSprite spriteWithTexture:[reserve texture]];
        } else {
            _direction = NE;
            _sprite = [CCSprite spriteWithTexture:[ready texture]];
        }
        _attribute = [Attributes attributesWithStats:obj.stats delegate:self];
        
        _sprite.scale = SETUPMAPSCALE;
        [self addChild:_sprite];
    }
    return self;
}

- (NSString *) stringForType:(int)type
{
    if ( type == MINOTAUR ) {
        return @"gorgon";
    } else if ( type == GORGON ) {
        return @"gorgon";
    } else if ( type == MUDGOLEM ) {
        return @"mudgolem";
    } else if ( type == DRAGON ) {
        return @"dragon";
    } else if ( type == LIONMAGE ) {
        return @"lionmage";
    } else {
        NSLog(@">[WARNING]    the type is %d",type);
        return nil;
    }
}

- (int) getValue
{
    return floor(self.obj.level/10.0f) * 10;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d Lv.%d",self.obj.type,self.obj.level];
}
@end