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

- (SFSArray *)mySetup
{
    if ( !_mySetup ) {
        _mySetup = [SFSArray newInstance];
        for ( int i = UnitTypeNone+1; i <= UnitTypeLast; i++)
            [_mySetup addClass:[self createMaxUnit:i]];
    }
    return _mySetup;
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
        
        [self createMatchObj];
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

- (void) createUnit
{
//    int type = (arc4random() % (UnitTypePriest)) + 1;
//    int experience = (arc4random() % 10000);
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
//    UnitObject *unit = [[UnitObject alloc] initWithString:string];
//    [self.units addObject:unit];
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

- (UnitObject *) createMaxUnit:(int)type
{
    NSLog(@"creating %d", type);
    int str = 100;
    int agi = 100;
    int inte = 100;
    int spr = 100;
    int hp = 100;
    int aug_str = 0;
    int aug_agi = 0;
    int aug_inte = 25;
    int aug_spr = 50;
    int aug_hp = 0;
    Heart heart = (arc4random() % UnholyHeart) + 1;
    
    
//    int primary = 10;
//    int secondary = 10;
//    int tertiary = 10;
    NSString *string = [NSString stringWithFormat:
                        @"%d/%d/%d/{%d,2}/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d",
                        type, Common, 4, type,
                        str, agi, inte, spr, hp,
                        aug_str, aug_agi, aug_inte, aug_spr, aug_hp,
                        heart, 15 ];
    UnitObject *unit = [[UnitObject alloc] initWithString:string];
    return unit;
}
@end
