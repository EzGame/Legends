//
//  Unit.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Unit.h"

#pragma mark - Attributes:
@implementation Attributes : NSObject

+ (id) attributesForType:(int)type stats:(StatObj *)stats;
{
    return [[Attributes alloc] initWithType:type stats:stats];
}

- (void) scrollUpgrade:(StatObj *)stats;
{
    NSLog(@">[MYLOG] Entering scrollUpgrade");
    bonus_str += stats.strength;
    bonus_agi += stats.agility;
    bonus_int += stats.intelligence;
    bonus_hp += stats.health;
    
    [self updateStats];
}

- (void) lvlUpUpgrade
{
    //NSLog(@">[MYLOG] Entering lvlUpUpgrade");
    base_str += lvlup_str;
    base_agi += lvlup_agi;
    base_int += lvlup_int;
    base_hp += lvlup_hp;
    
    [self updateStats];
}

- (id) initWithType:(int)type stats:(StatObj *)stats;
{
    self = [super init];
    if ( self )
    {
        bonus_str += stats.strength;
        bonus_agi += stats.agility;
        bonus_int += stats.intelligence;
        bonus_hp += stats.health;

        if( type == MINOTAUR )
            [self setup:minotaurBase];
        else if ( type == GORGON )
            [self setup:gorgonBase];
        else if ( type == MUDGOLEM )
            [self setup:mudGolemBase];
        else if ( type == DRAGON )
            [self setup:dragonBase];
        else if ( type == LIONMAGE )
            [self setup:lionMageBase];
    }
    return self;
}

- (void) setup:(const int *)array
{
    // Main stats
    main = array[MAINATTRIBUTE];
    base_hp = array[BASEHP];
    base_dmg = array[BASEDMG];
    base_str = array[BASESTR];
    base_agi = array[BASEAGI];
    base_int = array[BASEINT];
    lvlup_hp = array[LVLUPHP];
    lvlup_str = array[LVLUPSTR];
    lvlup_agi = array[LVLUPAGI];
    lvlup_int = array[LVLUPINT];
    speed = array[MOVESPEED];
    rarity = array[RARITY];
    
    [self updateStats];
    NSLog(@">[MYLOG] Finished setup of stats>> %@",self);
}

- (void) updateStats
{
    // Check if stats above max DEPREVATED
    if ( bonus_str + base_str > max_str && NO) bonus_str = max_str - base_str;
    if ( bonus_agi + base_agi > max_agi && NO) bonus_agi = max_agi - base_agi;
    if ( bonus_int + base_int > max_int && NO) bonus_int = max_int - base_int;
    
    // Combat stats
    if ( main == STRENGTH )
        damage = base_dmg + bonus_str + base_str;
    else if ( main == AGILITY )
        damage = base_dmg + bonus_agi + base_agi;
    else
        damage = base_dmg +bonus_int + base_int;
    max_health = base_hp + bonus_hp;
    
    phys_reduction = (base_str + bonus_str)*1.0/STRCOEFFICIENT;
    acurracy = (base_agi + bonus_agi)*1.0/AGICOEFFICIENT;
    spell_pierce = (base_int + bonus_int)*1.0/INTCOEFFICIENT;
    
    phys_resist = (base_str + bonus_str)*1.0/STRCOEFFICIENT;
    evasion = (base_agi + bonus_agi)*1.0/AGICOEFFICIENT;
    magic_resist = (base_int + bonus_int)*1.0/INTCOEFFICIENT;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"str:%d,agi:%d,int:%d,hp:%d",bonus_str, bonus_agi, bonus_int, bonus_hp];
}

- (int) getStr { return bonus_str + base_str; }

- (int) getAgi { return bonus_agi + base_agi; }

- (int) getInt { return bonus_int + base_int; }

- (int) getDamageForType:(int)type { return damage; }

@end

#pragma mark - Unit:
@implementation Unit
// Sprite
@synthesize sprite = _sprite, spriteSheet = _spriteSheet, menu = _menu;
// A*
@synthesize spOpenSteps = _spOpenSteps, spClosedSteps = _spClosedSteps, shortestPath = _shortestPath;
// Upgrades
@synthesize attribute = _attribute, myBuffs = _myBuffs, buffs = _buffs, runes = _runes, experience = _experience;
// Flags
@synthesize isOwned = _isOwned, canUpgrade = _canUpgrade, coolDown = _coolDown, direction = _direction;
// Others
@synthesize targets = _targets, obj = _obj;

#pragma mark - Unit: inits
- (id) initForSide:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super init];
    if ( self )
    {        
        type = obj.type;

        _obj = obj;
        _isOwned = side;
        _canUpgrade = YES;
        _direction = (side) ? NE : SW;
        _attribute = [Attributes attributesForType:type stats:obj.stats];
        [self setExperience:obj.experience];

        isStunned = NO;
        isEnsnared = NO;
        isFrozen = NO;
        isStoned = NO;
        isFocused = NO;

        rarity = _attribute->rarity;
        speed = _attribute->speed;
        health = _attribute->max_health;
        
        // Properties
        _spOpenSteps = nil;
        _spClosedSteps = nil;
        _shortestPath = nil;
    
        _myBuffs = [NSMutableArray array];
        _buffs = [NSMutableArray array];
    }
    return self;
}

// upgrades
- (void) scrollUpgrade:(StatObj *)stats experience:(int)xp
{
    NSLog(@">[MYLOG] Entering scrollUpgrade");
    self.experience += xp;
    [self.attribute scrollUpgrade:stats];
}

- (void) runeUpgrade:(int)type
{
    NSLog(@">[MYLOG] Entering runeUpgrade");
    // =/
}

#pragma mark - Setters n Getters
- (void) setExperience:(int)experience
{
    NSLog(@">[MYLOG] Entering setExperience");
    if ( experience >= _experience ) {
        _experience = MIN (experience, MAXEXPERIENCE);
        self.level = _experience / (MAXEXPERIENCE / MAXLEVEL);
        if ( experience == MAXEXPERIENCE )
            self.canUpgrade = NO;
    } else {
        NSLog(@">[WARN]     TRYING TO REDUCE EXP, IGNORED");
    }
}

- (void) setLevel:(int)level
{
    NSLog(@">[MYLOG] Entering setLevel from %d to %d, is setExperience above me?", _level, level);
    if ( level >= _level && level <= MAXLEVEL ) {
        for (int i = level - _level; i > 0; i--) {
            [self.delegate levelUp:self];
            [self.attribute lvlUpUpgrade];
        }
        _level = level;
    } else {
        NSLog(@">[WARN]     LEVELED PASSED MAX, IGNORED");
    }
}

- (void) setCoolDown:(int)coolDown
{
    _coolDown = MAX(0, coolDown);
}

#pragma mark - Skills
- (void) action:(int)action at:(CGPoint)position { return; }
- (void) popStepAndAnimate { return; }
- (BOOL) canIDo:(int)action {
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
- (void) take:(int)damage after:(float)delay { return; }
- (void) heal:(int)damage after:(float)delay { return; }
- (int) calculate:(int)damage type:(int)dmgType { return 0; }
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
        self.menu.position = self.sprite.position;
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
- (BOOL) putTargets:(NSArray *)targets
{
    self.targets = targets;
    return YES;
}

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
    if ( self.level < 10 ) return 5;
    else if ( self.level >= 20 && self.level <= 29 ) return 10;
    else if ( self.level >= 30 && self.level <= 39 ) return 20;
    else if ( self.level >= 40 ) return 40;
    else return -1;
}

// delegate stubs
- (void) buffCasterStarted:(Buff *)buff
{
    NSLog(@">[MYLOG]    Unit - caster for buff started");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        //NSLog(@">[MYWARN] How does a Unit cast stone gaze?");
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
        //NSLog(@">[MYWARN] How does a Unit cast stone gaze?");
        isFocused = NO;
        [self removeBuff:buff caster:YES];
    } else if ( [buff isKindOfClass:[BlazeDebuff class]] ) {
        NSLog(@"%@'s blaze ended", self);
        [self removeBuff:buff caster:YES];
    }
}

- (void) damage:(int)damage type:(int)type fromBuff:(Buff *)buff fromCaster:(id)caster
{
    [self take:damage after:0];
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

#pragma mark - A*
@implementation ShortestPathStep

@synthesize position;
@synthesize gScore;
@synthesize hScore;
@synthesize parent;

- (id)initWithPosition:(CGPoint)pos
{
	if ((self = [super init])) {
		position = pos;
		gScore = 0;
		hScore = 0;
		parent = nil;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@  pos=[%.0f;%.0f]  g=%d  h=%d  f=%d", [super description], self.position.x, self.position.y, self.gScore, self.hScore, [self fScore]];
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
@synthesize experience = _experience, level = _level, direction = _direction;
@synthesize position = _position;

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

- (void) setExperience:(int)experience
{
    NSLog(@">[MYLOG] Entering setExperience");
    if ( experience >= _experience ) {
        _experience = MIN (experience, MAXEXPERIENCE);
        self.level = _experience / (MAXEXPERIENCE / MAXLEVEL);
    }
}

- (void) setLevel:(int)level
{
    NSLog(@">[MYLOG] Entering setLevel from %d to %d, is setExperience above me?", _level, level);
    if ( level >= _level && level <= MAXLEVEL ) {
        for (int i = level - _level; i > 0; i--) {
            [self.attribute lvlUpUpgrade];
        }
        _level = level;
    }
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
        _attribute = [Attributes attributesForType:obj.type stats:obj.stats];
        
        _sprite.scale = SETUPMAPSCALE;
        [self setExperience:obj.experience];
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
    if ( self.level < 10 ) return 5;
    else if ( self.level >= 20 && self.level <= 29 ) return 10;
    else if ( self.level >= 30 && self.level <= 39 ) return 20;
    else if ( self.level >= 40 ) return 40;
    else return -1;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d Lv.%d",self.obj.type,self.level];
}
@end