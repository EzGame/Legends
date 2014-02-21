////
////  Objects.m
////  Legends
////
////  Created by David Zhang on 2013-07-18.
////
////
//
//#import "Objects.h"
//
//#pragma mark - Stat Object
//@implementation StatObj
//@synthesize health      = _health;
//@synthesize strength    = _strength;
//@synthesize agility     = _agility;
//@synthesize intellect   = _intellect;
//@synthesize wisdom      = _wisdom;
//
//+ (id) statsWithStr:(int)str agi:(int)agi inte:(int)inte wis:(int)wis hp:(int)hp
//{
//    return [[StatObj alloc] initWithStr:str agi:agi inte:inte wis:wis hp:hp];
//}
//
//- (id) initWithStr:(int)str agi:(int)agi inte:(int)inte wis:(int)wis hp:(int)hp;
//{
//    self = [super init];
//    if ( self ) {
//        _strength = str;
//        _agility = agi;
//        _intellect = inte;
//        _wisdom = wis;
//        _health = hp;
//    }
//    
//    return self;
//}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%d/%d/%d/%d/%d",
//             self.health, self.strength, self.agility, self.intellect, self.wisdom];
//}
//@end
//
//
///*#pragma mark - Unit Object
//@implementation UnitObj
//@synthesize type        = _type;
//@synthesize rarity      = _rarity;
//@synthesize experience  = _experience;
//@synthesize level       = _level;
//
//@synthesize stats       = _stats;
//@synthesize skills      = _skills;
//@synthesize position    = _position;
//@synthesize locked      = _locked;
//
//- (void) setExperience:(int)experience
//{
//    if ( !self.locked ) {
//        _experience = MIN(MAXEXPERIENCE,experience);
//        [self setLevel:GETLVL(experience)];
//    } else {
//        NSLog(@">LOCKED<");
//    }
//}
//
//- (void) setLevel:(int)level
//{
//    int difference = level - _level;
//    if ( difference > 0 ) {
//        for ( int i = difference; i > 0; i-- ) [self levelup];
//    } else {
//        NSLog(@">REDUCING LEVEL???<");
//    }
//    _level = MIN(MAXLEVEL,level);
//}
//
//+ (id) unitObjWithString:(NSString *)string
//{
//    return [[UnitObj alloc] initWithString:string];
//}
//
//- (id) initWithString:(NSString *)string
//{
//    self = [super init];
//    if ( self ) {
//        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
//                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
//        int dataCount = [tokens count]; // 1 skill = 13, 2 = 18 etc
//        int tokenIndex = 0;
//        
//        // Type
//        _type = [[tokens objectAtIndex:tokenIndex++] integerValue];
//        
//        // Exp + Lvl
//        _experience = [[tokens objectAtIndex:tokenIndex++] integerValue];
//        _level = GETLVL(_experience);
//        
//        // Stats
//        _stats = [StatObj statsWithStr:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                   agi:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                  inte:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                   wis:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                    hp:[[tokens objectAtIndex:tokenIndex++] integerValue]];
//        
//        // Skills
//        for ( int i = tokenIndex; i + 5 < dataCount; i+=5 ) {
//            SkillObj *skill = [SkillObj skillWithType:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                                level:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                                 rank:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                          costOfSkill:[[tokens objectAtIndex:tokenIndex++] integerValue]
//                                           multiplier:[[tokens objectAtIndex:tokenIndex++] floatValue]];
//            [_skills addObject:skill];
//        }
//        
//                
//        // Position
//        _position = CGPointFromString ([tokens objectAtIndex:tokenIndex++]);
//        
//        // locked
//        _locked = [[tokens objectAtIndex:tokenIndex++] boolValue];
//        
//        NSAssert(tokenIndex != dataCount - 1, @">[FATAL]    Unit Object dataCount!=tokens!!!");
//        
//        if ( _type == GORGON )     [self setup:gorgon_stats];
//        else if ( _type == MUDGOLEM )   [self setup:mudgolem_stats];
//        else if ( _type == DRAGON )     [self setup:dragon_stats];
//        else if ( _type == LIONMAGE )   [self setup:lionpriest_stats];
//        
//        NSLog(@">[MYLOG]    Created unit:\n%@",self);
//    }
//    return self;
//}
//
//- (void) setup:(const int *)array
//{
//    levelup_str = array[LVLUP_STR];
//    levelup_agi = array[LVLUP_AGI];
//    levelup_int = array[LVLUP_INT];
//    levelup_wis = array[LVLUP_WIS];
//    levelup_hp = array[LVLUP_HP];
//    _rarity = array[UNITRARITY];
//    
//    if      ( _rarity == COMMON ) max_level = 40;
//    else if ( _rarity == UNCOMMON ) max_level = 50;
//    else if ( _rarity == RARE ) max_level = 60;
//    else if ( _rarity == EPIC ) max_level = 70;
//    
//    for ( int i=0; i<=UNITRARITY; ++i )
//        NSLog(@"%i", array[i]);
//}
//
//- (void) levelup
//{
//    NSLog(@"levelup!");
//    self.stats.strength += levelup_str;
//    self.stats.agility += levelup_agi;
//    self.stats.intellect += levelup_int;
//    self.stats.wisdom += levelup_wis;
//    self.stats.health += levelup_hp;
//}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%d/%d/%@/%@/%@/%c",
//            self.type, self.experience, self.stats, self.skills,
//            NSStringFromCGPoint(self.position),self.locked];
//}
//@end*/
//
//
//#pragma mark - Damage Object
//@implementation DamageObj
//@synthesize damage = _damage;
//@synthesize isCrit = _isCrit;
//
//+ (id) damageObjWith:(int)damage isCrit:(BOOL)isCrit
//{
//    return [[DamageObj alloc] initObjWith:damage isCrit:isCrit];
//}
//
//- (id) initObjWith:(int)damage isCrit:(BOOL)isCrit
//{
//    self = [super init];
//    if ( self ) {
//        _damage = damage;
//        _isCrit = isCrit;
//    }
//    return self;
//}
//@end
//
//
//@implementation ScrollObj
//@synthesize type = _type, experience = _experience;
//@synthesize stats = _stats;
//
//+ (id) scrollObjWithString:(NSString *)string
//{
//    return [[ScrollObj alloc] initWithString:string];
//}
//
//- (id) initWithString:(NSString *)string
//{
//    self = [super init];
//    if ( self ) {
//        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
//                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
//        _type = [[tokens objectAtIndex:0] integerValue];
//        _experience = [[tokens objectAtIndex:1] integerValue];
//        _stats = [StatObj statsWithStr:[tokens objectAtIndex:2]
//                                   agi:[tokens objectAtIndex:3]
//                                  inte:[tokens objectAtIndex:4]
//                                   wis:[tokens objectAtIndex:5]
//                                    hp:[tokens objectAtIndex:6]];
//
//        NSLog(@">[MYLOG]    Created Scroll Object:\n%@", self);
//    }
//    return self;
//}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%d/%d/%@",
//            self.type, self.experience, self.stats];
//}
//@end
