//
//  UserSingleton.m
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import "UserSingleton.h"

#define PRIESTMOVE      1
#define PRIESTHEAL      2
#define RANGERMOVE      3
#define RANGERSHOOT     4
#define WARRIORMOVE     5
#define WARRIORSLASH    6
#define WITCHMOVE       7
#define WITCHWAVE       8
#define KNIGHTMOVE      9
#define KNIGHTSLASH     10
#define KNIGHTDEFEND    11
#define BERSERKERMOVE   12
#define BERSERKERSLASH  13
#define BERSERKERRAGE   14
#define PALADINMOVE     15
#define PALADINSMITE    16
#define PALADINPROT     17

@implementation UserSingleton
static UserSingleton* _sharedUserSingleton = nil;

+ (UserSingleton *) get
{
    @synchronized([UserSingleton class])
    {
        if (!_sharedUserSingleton)
            _sharedUserSingleton = [[self alloc] init];
        return _sharedUserSingleton;
    }
    NSLog(@">[ERROR]    Returning nil singleton!!!");
    return nil;
}

+ (id)alloc
{
	@synchronized([UserSingleton class])
	{
		NSAssert(_sharedUserSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedUserSingleton = [super alloc];
		return _sharedUserSingleton;
	}
    
	return nil;
}

- (id)init {
	self = [super init];
	if (self != nil) {
        // TODO: Make this singleton automatically search for information on the server side with SFSUserVariableRequest
        
        // Inventory
        _units = [NSMutableArray arrayWithCapacity:55];
        _consummables = [NSMutableArray array];
        _misc = [NSMutableArray array];
        
        // Preferences + settings
        _isFirstLaunch = NO;
        _playerLevel = 60;
        
        // Setup properties;
        _setupList = nil;
#ifdef DEVMODE
        _unitList = [NSMutableArray array];
        for ( UnitType i = 1; i <= UnitTypeLast; i++ ) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [self setDict:dict forType:i at:CGPointFlag];
            [_unitList addObject:dict];
        }
#else
        _unitList = nil;
#endif
        _unitCount = 0;
        _unitValue = 0;
        
        // Stat properties
        _ELO = DEFAULTELO;
        _TELO = DEFAULTTELO;
        
        // Game properties
        _amIPlayerOne = YES;
        _mySetup = nil;
        _oppSetup = nil;
        _me = nil;
        _opp = nil;
        
        [self createMatchObj];
    }
	return self;
}

- (void) setDict:(NSMutableDictionary *)dict forType:(UnitType)type at:(CGPoint)position
{
    NSString *name = [GeneralUtils stringFromType:type];
    [dict setObject:name forKey:@"name"];
    [dict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [dict setObject:[NSNumber numberWithInt:[GeneralUtils rarityFromType:type]]
             forKey:@"rarity"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"rank"];
    
    if ( !CGPointEqualToPoint(position, CGPointFlag) )
        [dict setObject:NSStringFromCGPoint(position) forKey:@"position"];
    
    [dict setObject:[NSNumber numberWithInt:UNITSTATS[type][0]] forKey:@"strength"];
    [dict setObject:[NSNumber numberWithInt:UNITSTATS[type][1]] forKey:@"agilty"];
    [dict setObject:[NSNumber numberWithInt:UNITSTATS[type][2]] forKey:@"intellect"];
    
    if ( type == UnitTypePriest ) {
        [dict setObject:[self shittyTempFunction:PRIESTMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:PRIESTHEAL] forKey:@"action_skill_one"];
    } else if ( type == UnitTypeRanger ) {
        [dict setObject:[self shittyTempFunction:RANGERMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:RANGERSHOOT] forKey:@"action_skill_one"];
    } else if ( type == UnitTypeWarrior ) {
        [dict setObject:[self shittyTempFunction:WARRIORMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:WARRIORSLASH] forKey:@"action_skill_one"];
    } else if ( type == UnitTypeWitch ) {
        [dict setObject:[self shittyTempFunction:WITCHMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:WITCHWAVE] forKey:@"action_skill_one"];
    } else if ( type == UnitTypeKnight ) {
        [dict setObject:[self shittyTempFunction:KNIGHTMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:KNIGHTSLASH] forKey:@"action_skill_one"];
        [dict setObject:[self shittyTempFunction:KNIGHTDEFEND] forKey:@"action_skill_two"];
    } else if ( type == UnitTypeBerserker ) {
        [dict setObject:[self shittyTempFunction:BERSERKERMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:BERSERKERSLASH] forKey:@"action_skill_one"];
        [dict setObject:[self shittyTempFunction:BERSERKERRAGE] forKey:@"action_skill_two"];
    } else if ( type == UnitTypePaladin ) {
        [dict setObject:[self shittyTempFunction:PALADINMOVE] forKey:@"action_move"];
        [dict setObject:[self shittyTempFunction:PALADINSMITE] forKey:@"action_skill_one"];
        [dict setObject:[self shittyTempFunction:PALADINPROT] forKey:@"action_skill_two"];
    }
}

- (NSMutableArray *) shittyTempFunction:(int)shit
{
    NSMutableArray *ret = [NSMutableArray array];
    [ret addObject:[NSNumber numberWithInt:UNITSKILLS[shit][0]]];
    [ret addObject:[NSNumber numberWithInt:UNITSKILLS[shit][1]]];
    [ret addObject:[NSNumber numberWithInt:UNITSKILLS[shit][2]]];
    [ret addObject:[NSNumber numberWithInt:UNITSKILLS[shit][3]]];
    return ret;
}

- (BOOL) saveOpp:(SFSUser *)user setup:(SFSArray *)array
{
    self.opp = user;
    self.oppSetup = array;
    
    return YES;
}

- (BOOL) saveSetup:(SFSArray *)array unitFood:(int)count unitValue:(int)value
{
    self.unitCount = count;
    self.unitValue = value;
    self.mySetup = array;
    return YES;
}

- (BOOL) downloadProfileFor:(NSString *)name
{
    return YES;
}

- (BOOL) uploadProfile
{
    return YES;
}

- (int) getKForMM
{
    int ret;
    if ( self.ELO < PROLVL ) // <1800
        ret = DEFAULTK;
    else if ( self.ELO >= PROLVL && self.ELO < MASTERLVL ) // 1800 - 2099
        ret = PROK;
    else if ( self.ELO >= MASTERLVL && self.ELO < GRANDMASTERK ) // 2100 - 2399
        ret = MASTERK;
    else    // >2400
        ret = GRANDMASTERK;
    return ret;
}

- (int) getKForTMM
{
    int ret;
    if ( self.TELO < PROLVL ) // <1800
        ret = DEFAULTK;
    else if ( self.TELO >= PROLVL && self.TELO < MASTERLVL ) // 1800 - 2099
        ret = PROK;
    else if ( self.TELO >= MASTERLVL && self.TELO < GRANDMASTERK ) // 2100 - 2399
        ret = MASTERK;
    else    // >2400
        ret = GRANDMASTERK;
    return ret;
}

- (void) createMatchObj
{
    _obj = [[MatchObject alloc] init];
    _obj.mySetup = self.mySetup;
    _obj.oppSetup = self.mySetup;
    _obj.myUser = [[SFSUser alloc] initWithId:101 name:@"fucker" isItMe:YES];
    _obj.oppUser = [[SFSUser alloc] initWithId:99 name:@"shit-for-brains" isItMe:NO];
    _obj.playerOne = _obj.myUser;
    _obj.myELO = 9999;
    _obj.oppELO = 1111;
}
@end
