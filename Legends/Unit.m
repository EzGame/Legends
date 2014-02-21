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
- (void) setPosition:(CGPoint)position
{
    [super setPosition:ccp(floor(position.x), floor(position.y))];
}

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
    self.healthBar.percentage = newPercentage;
    if (_currentHP < 1) [self action:ActionDie targets:nil];
}










#pragma mark - Init n shit
- (id) initUnit:(UnitObject *)obj isOwned:(BOOL)owned;
{
    self = [super init];
    if ( self ) {
        // Save pointer to UnitObject and stats
        _object = obj;
        _attributes = [AttributesObject attributesWithObject:obj.stats];
        
        // Find sprite strings
        NSString *plist = [NSString stringWithFormat:@"%@.plist",
                           [GeneralUtils stringFromType:obj.type]];
        NSString *png = [NSString stringWithFormat:@"%@.png",
                         [GeneralUtils stringFromType:obj.type]];
        NSString *name = [NSString stringWithFormat:@"%@_idle_%@_0.png",
                          [GeneralUtils stringFromType:obj.type],
                          [GeneralUtils stringFromDirection:( owned ) ? NE : SW]];
        NSString *glow = [NSString stringWithFormat:@"zglow_%@.png",
                          [GeneralUtils stringFromType:obj.type]];
        
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:png];
        _sprite = [CCSprite spriteWithSpriteFrameName:name];
        [_sprite.texture setAntiAliasTexParameters];
        _sprite.anchorPoint = ccp(0.5, 0);
        
        _glowSprite = [CCSprite spriteWithSpriteFrameName:glow];
        _glowSprite.color = [GeneralUtils colorFromAttribute:obj.stats.highestAttribute];
        _glowSprite.blendFunc = (ccBlendFunc) { GL_ONE, GL_ONE };
        _glowSprite.anchorPoint = ccp(0.5, 0);
        [_glowSprite runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:0.9f opacity:150],
           [CCFadeTo actionWithDuration:0.9f opacity:255], nil] ]
         ];
        
        [_spriteSheet addChild:_glowSprite z:-1];
        [_spriteSheet addChild:_sprite];
        [self addChild:_spriteSheet];

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
        
        // Initialize Stats
        _buffList = [NSMutableArray array];
        _direction = (owned) ? NE : SW;
        _boardPos = obj.position;
        _currentHP = _attributes.health;
        _maximumHP = _attributes.health;
        _isOwned = owned;
        _isBusy = NO;
    }
    return self;
}










#pragma mark - Actions
- (void) action:(Action)action targets:(NSMutableArray *)targets{}

#pragma mark - Combat
- (void) combatSend:(CombatObject *)obj to:(Unit *)unit
{
    // Let attributes modify the damage object
    if ( obj.type != CombatTypeHeal || obj.type != CombatTypePure )
        [self.attributes attackerCalculation:obj];
    
    // Iterate through buff list with event = BuffEventAttack
    for ( BuffObject *b in self.buffList ) {
        [b onBuffInvoke:BuffEventAttack obj:obj];
    }
    
    // Send message
    [unit combatReceive:obj];
}

- (void) combatReceive:(CombatObject *)obj
{
    NSLog(@"Received combat obj %@", obj);
    // Let attributes modify the damage object
    if ( obj.type != CombatTypeHeal || obj.type != CombatTypePure )
        [self.attributes defenderCalculation:obj];
    
    // Iterate through buff list with event = BuffEventDefense
    for ( BuffObject *b in self.buffList ) {
        [b onBuffInvoke:BuffEventDefense obj:obj];
    }
    
    // Based on the combat object received/modified by buffs, display information
    [self combatMessage:obj];
}

- (void) combatMessage:(CombatObject *)obj
{
    NSMutableString *message;
    ccColor3B spriteColour;
    
    // If the object is not a heal, the combat message should be for damage
    if ( !obj.amount ) {
        return;
        
    } else if ( obj.type != CombatTypeHeal ) {
        // Find damaged frame name
        NSString *name = [GeneralUtils stringFromType:self.object.type];
        NSString *face = [GeneralUtils stringFromDirection:self.direction];
        NSString *frame = [NSString stringWithFormat:@"%@_hurt_%@.png",name,face];
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frame]];
        spriteColour = ccRED;
    } else {
        spriteColour = ccGREEN;
    }
    message = [NSMutableString stringWithFormat:@"%d", obj.amount];
    if ( obj.isCrit && !obj.isResist ) {
        [message appendString:@"!!"];
    }
    
    // Create the label for the text
    CCLabelBMFont *scrollingText = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    scrollingText.color = [GeneralUtils colorFromCombat:obj.type];
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
         [self.sprite setColor:spriteColour];
     }],
      [CCDelayTime actionWithDuration:0.5],
      [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255],
      [CCCallBlock actionWithBlock:^{
         self.direction = self.direction;
         [scrollingText runAction:[CCSequence actions:
                                   startAnim, slideUp, fadeOut, cleanUp, nil]];
         self.currentHP += ((obj.type == CombatTypeHeal)? 1 : -1 ) * obj.amount;
     }], nil]];
}










#pragma mark - Other
- (void) reset
{
    self.currentCD--;
    for (BuffObject *b in self.buffList) {
        [b onReset];
        if (b.duration == 0) {
            [b onBuffRemoved:self.attributes];
        }
    }
}

- (void) openMenu
{
    self.menu.visible = YES;
}

- (void) closeMenu
{
    self.menu.visible = NO;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ %@>",
            [GeneralUtils stringFromType:self.object.type], NSStringFromCGPoint(self.boardPos)];
}










#pragma mark - Subclassing functions
- (void) playAnimation:(CCAnimation *)animation selector:(SEL)s
{
    if ( [self.sprite numberOfRunningActions] )
        [self.sprite stopAllActions];
    
    NSLog(@"%d", [self.sprite numberOfRunningActions] );
    // For a finite animation, we want to call a selector when we're finished.
    animation.restoreOriginalFrame = YES;
    [self.sprite runAction:
     [CCSequence actions:
      [CCAnimate actionWithAnimation:animation],
      [CCCallFunc actionWithTarget:self selector:s], nil]];
        NSLog(@"%d", [self.sprite numberOfRunningActions] );
}

- (void) playAction:(CCAction *)action
{
    if ( [self.sprite numberOfRunningActions] )
        [self.sprite stopAllActions];
    [self.sprite runAction:action];
}










#pragma mark - Buff Object Delegate
- (void) buffAnimationAdded:(BuffObject *)buff
{
    buff.icon.position = self.position;
    [self.delegate unit:self wantsUnitEffect:buff.icon];
}

- (void) buffAnimationInvoked:(BuffObject *)buff
{
    buff.icon.position = self.position;
    [self.delegate unit:self wantsUnitEffect:buff.icon];
}

- (void) buffAnimationRemoved:(BuffObject *)buff
{
    buff.icon.position = self.position;
    [self.delegate unit:self wantsUnitEffect:buff.icon];
}

- (void) buffNeedsToBeAdded:(BuffObject *)buff
{
    [self.buffList addObject:buff];
    [buff onBuffAdded:self.attributes];
}

- (void) buffNeedsToBeRemoved:(BuffObject *)buff
{
    [self.buffList removeObject:buff];
    [buff onBuffRemoved:self.attributes];
}
@end










#pragma mark - A*
@implementation ShortestPathStep
- (id)initWithBoardPos:(CGPoint)pos;
{
	if ((self = [super init])) {
        _boardPos = pos;
		_gScore = 0;
		_hScore = 0;
		_parent = nil;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@  pos=%@/%@  g=%d  h=%d  f=%d", [super description], NSStringFromCGPoint(self.position), NSStringFromCGPoint(self.boardPos), self.gScore,
            self.hScore, [self fScore]];
}

- (BOOL)isEqual:(ShortestPathStep *)other
{
	return CGPointEqualToPoint(self.boardPos, other.boardPos);
}

- (int)fScore
{
	return self.gScore + self.hScore;
}
@end





/*
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