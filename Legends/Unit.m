//
//  Unit.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Unit.h"

@implementation Attributes : NSObject

+ (id) attributesForType:(int)type stats:(NSDictionary *)stats;
{
    return [[Attributes alloc] initWithType:type stats:stats];
}

- (void) scrollUpgrade:(NSDictionary *)stats;
{
    NSLog(@">[MYLOG] Entering scrollUpgrade");
    strength += [[stats valueForKey:@"str"] integerValue];
    agility += [[stats valueForKey:@"agi"] integerValue];
    intellegence += [[stats valueForKey:@"int"] integerValue];
    bonus_hp += [[stats valueForKey:@"hp"] integerValue];
    
    [self updateStats];
}

- (void) lvlUpUpgrade
{
    NSLog(@">[MYLOG] Entering lvlUpUpgrade");
    base_str += lvlup_str;
    base_agi += lvlup_agi;
    base_int += lvlup_int;
    base_hp += lvlup_hp;
    
    [self updateStats];
}

- (id) initWithType:(int)type stats:(NSDictionary *)stats;
{
    self = [super init];
    if ( self )
    {
        strength = [[stats valueForKey:@"str"] integerValue];
        agility = [[stats valueForKey:@"agi"] integerValue];
        intellegence = [[stats valueForKey:@"int"] integerValue];
        bonus_hp = [[stats valueForKey:@"hp"] integerValue];

        if( type == MINOTAUR )
            [self setup:minotaurBase];
        else if ( type == GORGON )
            [self setup:gorgonBase];
        else if ( type == MUDGOLEM )
            [self setup:mudGolemBase];
        else if ( type == DRAGON )
            [self setup:dragonBase];
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
    if ( strength + base_str > max_str && NO) strength = max_str - base_str;
    if ( agility + base_agi > max_agi && NO) agility = max_agi - base_agi;
    if ( intellegence + base_int > max_int && NO) intellegence = max_int - base_int;
    
    // Combat stats
    if ( main == STRENGTH ) damage = base_dmg + strength + base_str;
    else if ( main == AGILITY ) damage = base_dmg + agility + base_agi;
    else if ( main == INTELLIGENCE ) damage = base_dmg +intellegence + base_int;
    else NSLog(@">[ERROR] This unit did not have a correct main attribute, %d",main);
    max_health = base_hp + bonus_hp;
    
    phys_reduction = (base_str + strength)*1.0/STRCOEFFICIENT;
    acurracy = (base_agi + agility)*1.0/AGICOEFFICIENT;
    spell_pierce = (base_int + intellegence)*1.0/INTCOEFFICIENT;
    
    phys_resist = (base_str + strength)*1.0/STRCOEFFICIENT;
    evasion = (base_agi + agility)*1.0/AGICOEFFICIENT;
    magic_resist = (base_int + intellegence)*1.0/INTCOEFFICIENT;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"str:%d,agi:%d,int:%d,hp:%d",strength, agility, intellegence, bonus_hp];
}

- (int) getStr { return strength + base_str; }

- (int) getAgi { return agility + base_agi; }

- (int) getInt { return intellegence + base_int; }

@end

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

@implementation Unit
@synthesize sprite = _sprite, spriteSheet = _spriteSheet, menu = _menu;
@synthesize spOpenSteps = _spOpenSteps, spClosedSteps = _spClosedSteps, shortestPath = _shortestPath;
@synthesize attribute = _attribute, myBuffs = _myBuffs, buffs = _buffs, runes = _runes;
@synthesize isOwned = _isOwned, canUpgrade = _canUpgrade, experience = _experience, coolDown = _coolDown, direction = _direction;

- (id) initForSide:(BOOL)side withValues:(NSArray *)values
{
    self = [super init];
    if ( self )
    {
        _canUpgrade = YES;
        isStunned = NO;
        isEnsnared = NO;
        isFrozen = NO;
        isStoned = NO;
        isFocused = NO;
        _isOwned = side;
        
        // values format example @"u/1/0/str:1,agi:1,int:1/[-1]",
        type = [[values objectAtIndex:1] integerValue];
        _attribute = [Attributes attributesForType:type
                                             stats:[self parseStats:[values objectAtIndex:3]]];
        [self setExperience:[[values objectAtIndex:2] integerValue]];
        value = [self getValue:_level];
        
        // iVars
        rarity = _attribute->rarity;
        speed = _attribute->speed;
        health = _attribute->max_health;
        _direction = (side) ? NE : SW;
        
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
- (void) scrollUpgrade:(NSString *)stats experience:(int)xp;
{
    NSLog(@">[MYLOG] Entering scrollUpgrade");
    self.experience += xp;
    [self.attribute scrollUpgrade:[self parseStats:stats]];
}

- (void) runeUpgrade:(int)type
{
    NSLog(@">[MYLOG] Entering runeUpgrade");
    // =/
}

// helpers
- (NSDictionary *) parseStats:(NSString *)stats
{
    NSLog(@">[MYLOG]    Unit:parseStats got %@",stats);
    NSArray *parse_stats = [NSArray arrayWithArray:
                            [stats componentsSeparatedByCharactersInSet:[UserSingleton get].statSeparator]];
    NSAssert([parse_stats count] < 9, @">[ERROR] Stats passed in is corrupt!");
    return [NSDictionary dictionaryWithObjectsAndKeys:
                           [parse_stats objectAtIndex:0], [parse_stats objectAtIndex:1],
                           [parse_stats objectAtIndex:2], [parse_stats objectAtIndex:3],
                           [parse_stats objectAtIndex:4], [parse_stats objectAtIndex:5],
                           [parse_stats objectAtIndex:6], [parse_stats objectAtIndex:7], nil];
}

- (int) getValue:(int)level
{
    if ( level < 10 ) return 5;
    else if ( level >= 20 && level <= 29 ) return 10;
    else if ( level >= 30 && level <= 39 ) return 20;
    else if ( level >= 40 ) return 40;
    else return -1;
}

// setter+getter overrides
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
        value = [self getValue:level];
        _level = level;
    } else {
        NSLog(@">[WARN]     LEVELED PASSED MAX, IGNORED");
    }
}

- (void) setCoolDown:(int)coolDown
{
    _coolDown = MAX(0, coolDown);
}

// skills
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

// combat
- (void) take:(int)damage after:(float)delay { return; }
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

// menu
- (void) toggleMenu:(BOOL)state {
    if ( state && [self canIDo:UNKNOWN] && self.coolDown == 0 ) {
        self.menu.position = self.sprite.position;
        if ( self.menu.visible == NO ) {
            id visible = [CCCallBlock actionWithBlock:^{self.menu.visible = YES;}];
            [self.menu runAction:[CCSequence actions: visible, [CCFadeIn actionWithDuration:0.5], nil]];
        }
    } else {
        if ( self.menu.visible == YES ) {
            id invisible = [CCCallBlock actionWithBlock:^{self.menu.visible = NO;}];
            [self.menu runAction:[CCSequence actions: [CCFadeOut actionWithDuration:0.1], invisible, nil]];
        }
        
    }
}
- (void) undoLastButton { return; }
- (void) reset
{
    for (Buff *buff in self.myBuffs) {
        [buff turnEnd];
    }
    return;
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