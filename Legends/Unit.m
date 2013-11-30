//
//  Unit.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Unit.h"

#pragma mark - Unit
@implementation Unit
#pragma mark - Setters n Getters
- (void) setDirection:(Direction)direction
{
    NSString *name = [GeneralUtils stringFromType:self.object.type];
    NSString *face = [GeneralUtils stringFromDirection:direction];
    NSString *frame = [NSString stringWithFormat:@"%@_idle_%@_0.png",name,face];
    
    [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frame]];
    [self.sprite.texture setAntiAliasTexParameters];
    _direction = direction;
}

- (void) setCurrentCD:(int)currentCD
{
    _currentCD = MAX(0, currentCD);
}

- (void) setCurrentHP:(int)currentHP
{
    _currentHP = MIN(_maximumHP, MAX(0, currentHP));
    int newPercentage = 100 * ( (float)_currentHP / (float)_maximumHP );

    [_healthBar runAction:
     [CCSequence actions:
      [CCActionTween actionWithDuration:0.25
                                    key:@"percentage"
                                   from:_healthBar.percentage
                                     to:newPercentage],
    //[CCDelayTime actionWithDuration:0.25],
      [CCCallBlock actionWithBlock:^{
         //if ( _currentHP < 1 ) [self secondaryAction:ActionDie at:CGPointZero];
     }], nil] ];
}

#pragma mark - Init n shit
- (id) initUnit:(UnitObject *)obj isOwned:(BOOL)owned;
{
    self = [super init];
    if ( self ) {
        // Save pointer to UnitObject
        _object = obj;
        
        // Initialize Attributes
        _attributes = [Attributes attributesWithObject:obj.stats];
        
        // Find sprite strings
        NSString *plist = [NSString stringWithFormat:@"%@.plist",
                           [GeneralUtils stringFromType:obj.type]];
        NSString *png = [NSString stringWithFormat:@"%@.png",
                         [GeneralUtils stringFromType:obj.type]];
        NSString *name = [NSString stringWithFormat:@"%@_idle_%@_0.png",
                          [GeneralUtils stringFromType:obj.type],
                          [GeneralUtils stringFromDirection:( owned ) ? NE : SW]];
        
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:png];
        _sprite = [CCSprite spriteWithSpriteFrameName:name];
        _sprite.anchorPoint = ccp(0.5, 0);
        [_spriteSheet addChild:self.sprite];
        [self addChild:self.spriteSheet];

        // Health bar
        _healthBar = [CCProgressTimer progressWithSprite:
                      [CCSprite spriteWithFile:@"healthbar.png"]];
        _healthBar.type = kCCProgressTimerTypeBar;
        _healthBar.color = (owned) ? ccGREEN : ccRED;
        _healthBar.midpoint = ccp(0.0, 0.5f);
        _healthBar.barChangeRate = ccp(1,0);
        _healthBar.percentage = 100;
        _healthBar.anchorPoint = ccp(0.5,1.0);
        _healthBar.position = ccpAdd(self.position,ccp(0,0));
        [self addChild:_healthBar z:1];
        
        // A*
        _spOpenSteps = nil;
        _spClosedSteps = nil;
        _shortestPath = nil;
        
        // Initialize States
        _isOwned = owned;
        _direction = (owned) ? NE : SW;
        _moveSpeed = obj.moveSpeed;
    }
    return self;
}

#pragma mark - Actions
- (void) action:(Action)action targets:(NSMutableArray *)targets{}

#pragma mark - Sender combat
- (void) damage:(NSMutableArray *)units for:(int)amount{}
- (void) heal:(NSMutableArray *)units for:(int)amount{}

#pragma mark - Receiver combat
- (void) take:(int)amount from:(Unit *)unit
{
    // Find damaged frame name
    NSString *name = [GeneralUtils stringFromType:self.object.type];
    NSString *face = [GeneralUtils stringFromDirection:self.direction];
    NSString *frame = [NSString stringWithFormat:@"%@_hurt_%@.png",name,face];
    [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frame]];
    
    // Create scrolling text
    NSString *message = [NSString stringWithFormat:@"%d", amount];
    CCLabelBMFont *scrollingText = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    scrollingText.color = ccRED;
    scrollingText.anchorPoint = ccp(0.5, 0.5);
    scrollingText.position = ccp(0, 25);
    scrollingText.visible = NO;
    [self addChild:scrollingText];
    
    // Create scrolling text animations
    id startAnim = [CCCallBlock actionWithBlock:^{scrollingText.visible = YES;}];
    id slideUp = [CCMoveBy actionWithDuration:0.5 position:ccp(0,35)];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id cleanUp = [CCCallBlock actionWithBlock:^{[self removeChild:scrollingText cleanup:YES];}];
    
    // Run animation sequence
    [self.sprite runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccRED];
         self.currentHP -= amount;
     }],
      [CCDelayTime actionWithDuration:1],
      [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255],
      [CCCallBlock actionWithBlock:^{
         self.direction = self.direction;
         [scrollingText runAction:[CCSequence actions:
                                   startAnim, slideUp, fadeOut, cleanUp, nil]];
     }], nil]];
}

- (void) gain:(int)amount from:(Unit *)unit
{
    // Create scrolling text
    NSString *message = [NSString stringWithFormat:@"+%d", amount];
    CCLabelBMFont *scrollingText = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    scrollingText.color = ccGREEN;
    scrollingText.anchorPoint = ccp(0.5, 0.5);
    scrollingText.position = ccp(0, 25);
    scrollingText.visible = NO;
    [self addChild:scrollingText];
    
    // Create scrolling text animationss
    id startAnim = [CCCallBlock actionWithBlock:^{scrollingText.visible = YES;}];
    id slideUp = [CCMoveBy actionWithDuration:0.5 position:ccp(0,35)];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id cleanUp = [CCCallBlock actionWithBlock:^{[self removeChild:scrollingText cleanup:YES];}];
    
    // Run animation sequence
    [self.sprite runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccLIGHTGREEN];
         self.currentHP += amount;
     }],
      [CCDelayTime actionWithDuration:1],
      [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255],
      [CCCallBlock actionWithBlock:^{
         self.direction = self.direction;
         [scrollingText runAction:[CCSequence actions:
                                   startAnim, slideUp, fadeOut, cleanUp, nil]];
     }], nil]];
}

- (void) reset {}
- (void) openMenu
{
    self.menu.visible = YES;
}
- (void) closeMenu
{
    self.menu.visible = NO;
}
@end


#pragma mark - A*
@implementation ShortestPathStep
- (id)initWithPosition:(CGPoint)pos;
{
	if ((self = [super init])) {
		_position = pos;
		_gScore = 0;
		_hScore = 0;
		_parent = nil;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@  pos=%@  g=%d  h=%d  f=%d", [super description], NSStringFromCGPoint(self.position), self.gScore, self.hScore, [self fScore]];
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

/* NOTE change direction after skill place selection before confirmation selection:
    this lets us provide the layer a proper direction depended confirmation hitbox
 */

/*#pragma mark - Unit:
@implementation Unit
@synthesize sprite          = _sprite;
@synthesize spriteSheet     = _spriteSheet;
@synthesize menu            = _menu;
@synthesize death           = _death;
@synthesize healthBar      = _healthBar;

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
    self.healthBar.position = [self convertToNodeSpace:ccpAdd(position, ccp(0,-20))];
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
    [_healthBar runAction:
     [CCSequence actions:
      [CCActionTween actionWithDuration:2
                                    key:@"percentage"
                                   from:self.healthBar.percentage
                                     to:new_percentage],
      [CCDelayTime actionWithDuration:2],
      [CCCallBlock actionWithBlock:^{
         if ( _current_hp < 1 ) [self secondaryAction:ActionDie at:CGPointZero];
     }], nil] ];
}

- (void) setMaximum_hp:(int)maximum_hp
{
    _maximum_hp = maximum_hp;
    if ( !self.current_hp )
        self.current_hp = maximum_hp;
    self.current_hp = self.current_hp * self.healthBar.percentage / 100;
}


#pragma mark - Skills
- (void) secondaryAction:(Action)action at:(CGPoint)position
{
    if ( action == ActionDie ) {
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

- (void) primaryAction:(Action)action targets:(NSArray *)targets
{ return; }

- (void) popStepAndAnimate
{ return; }

- (BOOL) canIDo:(Action)action
{
    for (Buff *buff in self.buffs) {
        if ( ![buff buffEffectOnEvent:EventReset forUnit:self] )
            return NO;
    }
    return YES;
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
    
    if ( state && [self canIDo:ActionUnknown] && self.coolDown == 0 && [self hasActionLeft] ) {
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
    for (Buff *buff in self.buffs) {
        [buff buffEffectOnEvent:EventReset forUnit:self];
    }
    return;
}

- (BOOL) hasActionLeft {
    NSAssert(false,@">[FATAL]  THIS FUNCTION MUST BE SUBCLASSED");
    return NO;
}


#pragma mark - Other
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

- (DamageObj *) attributesDelegateRequestObjWithSkillType:(int)skillType
{
    return nil;
}


#pragma mark - Buff Delegates
- (void) buffCasterStarted:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for %@ started",buff);
    [self.myBuffs addObject:buff];
}

- (void) buffCasterFinished:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for %@ ended",buff);
    [self.myBuffs removeObject:buff];
}

- (void) buffTargetStarted:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - target for %@ target",buff);
    [self.myBuffs addObject:buff];
}

- (void) buffTargetFinished:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for %@ started",buff);
    [self.myBuffs removeObject:buff];
}
@end


#pragma mark - UnitDamage
@implementation UnitDamage
@synthesize target      = _target;
@synthesize damage      = _damage;
@synthesize targetPos   = _targetPos;

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
        if ( _target != nil )
            _targetPos = _target.sprite.position;
    }
    return self;
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

- (DamageObj *) attributesDelegateRequestObjWithSkillType:(int)skillType
{
    return nil;
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
    if ( type == GORGON ) {
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
@end*/