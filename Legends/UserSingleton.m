//
//  UserSingleton.m
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import "UserSingleton.h"

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
	if (self != nil)
    {
        // Inventory
        _units = [NSMutableArray arrayWithCapacity:55];
        _consummables = [NSMutableArray array];
        _misc = [NSMutableArray array];
        
        // Preferences + settings
        _isFirstLaunch = NO;
        _playerLevel = 60;
        
        // Setup properties;
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
        
        for ( int i = 0; i < 30; i++ )
            [self createUnit];
    }
	return self;
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

//- (void) createUnit
//{
//    int type = (arc4random() % (LAST_UNIT)) + 1;
//    int experience = (arc4random() % MAXEXPERIENCE);
//    int str = (arc4random() % 100 );
//    int agi = (arc4random() % 100 );
//    int inte = (arc4random() % 100 );
//    int wis = (arc4random() % 100 );
//    int hp = (arc4random() % 100 );
//    int primary = (arc4random() % 11 );
//    int secondary = (arc4random() % 11 );
//    int tertiary = (arc4random() % 11 );
//    NSString *string = [NSString stringWithFormat:
//                        @"%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/{-1,-1}/0",
//                        type, experience, str, agi, inte, wis, hp,
//                        primary, secondary, tertiary];
//    UnitObj *unit = [UnitObj unitObjWithString:string];
//    [self.units addObject:unit];
//}
//
//- (void) createMaxUnit
//{
//    int type = (arc4random() % LAST_UNIT - 1) + 1;
//    int experience = MAXEXPERIENCE;
//    int str = 100;
//    int agi = 100;
//    int inte = 100;
//    int wis = 100;
//    int hp = 100;
//    int primary = 10;
//    int secondary = 10;
//    int tertiary = 10;
//    NSString *string = [NSString stringWithFormat:
//                        @"%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/{-1,-1}/0",
//                        type, experience, str, agi, inte, wis, hp,
//                        primary, secondary, tertiary];
//    UnitObj *unit = [UnitObj unitObjWithString:string];
//    [self.units addObject:unit];
//}
@end
