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
    
    // Check if stats above max
    if ( strength + base_str > max_str ) strength = max_str - base_str;
    if ( agility + base_agi > max_agi ) agility = max_agi - base_agi;
    if ( intellegence + base_int > max_int ) intellegence = max_int - base_int;
}

- (void) lvlUpUpgrade
{
    NSLog(@">[MYLOG] Entering lvlUpUpgrade");
    strength += lvlup_str;
    agility += lvlup_agi;
    intellegence += lvlup_int;
    
    // Check if stats above max
    if ( strength + base_str > max_str ) strength = max_str - base_str;
    if ( agility + base_agi > max_agi ) agility = max_agi - base_agi;
    if ( intellegence + base_int > max_int ) intellegence = max_int - base_int;
}

- (id) initWithType:(int)type stats:(NSDictionary *)stats;
{
    self = [super init];
    if ( self )
    {
        strength = [[stats valueForKey:@"str"] integerValue];
        agility = [[stats valueForKey:@"agi"] integerValue];
        intellegence = [[stats valueForKey:@"int"] integerValue];
        
        if( type == MINOTAUR )
            [self setup:minotaurBase];
        else if ( type == GORGON )
            [self setup:gorgonBase];
    }
    return self;
}

- (void) setup:(int *)array
{
    // Main stats
    main = array[MAINATTRIBUTE];
    base_hp = array[BASEHP];
    base_dmg = array[BASEDMG];
    base_str = array[BASESTR];
    base_agi = array[BASEAGI];
    base_int = array[BASEINT];
    max_str = array[MAXSTR];
    max_agi = array[MAXAGI];
    max_int = array[MAXINT];
    lvlup_str = array[LVLUPSTR];
    lvlup_agi = array[LVLUPAGI];
    lvlup_int = array[LVLUPINT];
    
    // Check if stats above max
    if ( strength + base_str > max_str ) strength = max_str - base_str;
    if ( agility + base_agi > max_agi ) agility = max_agi - base_agi;
    if ( intellegence + base_int > max_int ) intellegence = max_int - base_int;
    
    // Combat stats
    if ( main == strength ) damage = base_dmg + strength;
    else if ( main == agility ) damage = base_dmg + agility;
    else if ( main == intellegence ) damage = base_dmg +intellegence;
    max_health = (base_str + strength)/HPCOEFFICIENT;
    phys_resist = (base_agi + agility)/PHYCOEFFICIENT;
    magic_resist = (base_int + intellegence)/MAGCOREFFICIENT;
    NSLog(@">[MYLOG] Finished setup of stats>> %@",self);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"str:%d,agi:%d,int:%d",strength, agility, intellegence];
}

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
@synthesize isOwned = _isOwned, canUpgrade = _canUpgrade, experience = _experience, rarity_level = _rarity_level;

- (id) initForSide:(BOOL)side withValues:(NSArray *)values
{
    self = [super init];
    if ( self )
    {        
        // values format example @"u/1/0/str:1,agi:1,int:1/[-1]",
        // iVars
        type = [[values objectAtIndex:1] integerValue];
        value = [self getValue:_rarity_level];
        speed = minotaurBase[MOVESPEED];
        facingDirection = (side) ? NE : SW;
        
        isStunned = NO;
        isEnsnared = NO;
        isFrozen = NO;
        isFocused = NO;
        
        // Properties
        _spOpenSteps = nil;
        _spClosedSteps = nil;
        _shortestPath = nil;
        
        _attribute = [Attributes attributesForType:type
                                             stats:[self parseStats:[values objectAtIndex:3]]];
        _myBuffs = [NSMutableArray array];
        _buffs = [NSMutableArray array];
        
        _isOwned = side;
        _canUpgrade = YES;
        [self setRarity_level:[[values objectAtIndex:2] integerValue]];
        [self setExperience:[[values objectAtIndex:2] integerValue]];
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
                            [stats componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",:"]]];
    NSAssert([parse_stats count] < 6, @">[ERROR] Stats passed in is corrupt!");
    return [NSDictionary dictionaryWithObjectsAndKeys:
                           [parse_stats objectAtIndex:0],[parse_stats objectAtIndex:1],
                           [parse_stats objectAtIndex:2], [parse_stats objectAtIndex:3],
                           [parse_stats objectAtIndex:4], [parse_stats objectAtIndex:5], nil];
}

- (int) getRarity:(int)xp
{
    if ( xp < 100 ) return COMMON;
    else if ( xp >= 100 ) return UNCOMMON;
    else if ( xp >= 300 ) return RARE;
    else if ( xp >= 700 ) return EPIC;
    else return -1;
}

- (int) getValue:(int)rare
{
    if ( rare == COMMON ) return 5;
    else if ( rare == UNCOMMON ) return 10;
    else if ( rare == RARE ) return 20;
    else if ( rare == EPIC ) return 40;
    else return -1;
}

// setter+getter overrides
- (void) setExperience:(int)experience
{
    NSLog(@">[MYLOG] Entering setExperience");
    int newRarity = [self getRarity:experience];
    if ( newRarity > self.rarity_level && self.canUpgrade ) {
        self.rarity_level = newRarity;
        value = [self getValue:self.rarity_level];
        [self.attribute lvlUpUpgrade];
        [self.delegate upgraded:self];
    }
    _experience = MIN ( experience, MAXLEVEL );
}

- (void) setRarity_level:(int)rarity_level
{
    if ( rarity_level == MAXLEVEL )
        self.canUpgrade = NO;
    self.rarity_level = MIN( rarity_level, MAXLEVEL );
}

// skills
- (void) action:(int)action at:(CGPoint)position { return; }
- (NSArray *) getAttkArea:(CGPoint)position { return nil; }
- (void) popStepAndAnimate { return; }

// combat
- (void) addBuff:(Buff *)buff myBuff:(BOOL)isMyBuff
{
    NSLog(@">[MYLOG] Entering addBuff");
    if ( isMyBuff ) [self.myBuffs addObject:buff];
    else [self.buffs addObject:buff];
}
- (void) take:(int)damage { return; }
- (int) calculate:(int)damage { return 0; }

// menu
- (void) toggleMenu:(BOOL)state { return; }
- (void) undoLastButton { return; }
- (void) reset
{
    for (Buff *buff in self.myBuffs) {
        [buff turnEnd];
    }
    return;
}

// delegate stubs
- (void) buffCasterFinished:(Buff *)buff { return; }
- (void) buffTargetFinished:(Buff *)buff { return; }
@end