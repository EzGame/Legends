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
        [self loadProfile:nil newbie:YES];
        _items = [NSMutableArray arrayWithObjects:
                  @"u/1/0/str:1,agi:1,int:1/[-1]",
                  @"u/1/0/str:1,agi:1,int:1/[-1]",
                  @"u/1/0/str:1,agi:1,int:1/[-1]",
                  @"u/1/0/str:1,agi:1,int:1/[-1]",
                  @"u/1/0/str:1,agi:1,int:1/[-1]",
                  @"u/2/100/str:1,agi:1,int:1/[-1]",
                  @"u/2/100/str:1,agi:1,int:1/[-1]",
                  @"u/2/100/str:1,agi:1,int:1/[-1]",
                  @"u/2/100/str:1,agi:1,int:1/[-1]",
                  @"u/2/100/str:1,agi:1,int:1/[-1]",
                  @"s/1/c/50/str:10"
                  @"s/2/c/50/agi:10",
                  @"s/3/c/50/int:10",nil];
    }
	return self;
}

- (void) loadProfile:(NSDictionary *)profile newbie:(BOOL)isFirstLoad
{
    if ( isFirstLoad ) {
        self.ELO = DEFAULTELO;
        self.TELO = DEFAULTTELO;
        self.isFirstLaunch = NO;//isFirstLoad;
        self.pieces = [NSArray arrayWithObjects:
                        @"u/1/0/str:1,agi:1,int:1/[-1]/[1,5]",
                        @"u/1/0/str:1,agi:1,int:1/[-1]/[2,5]",
                        @"u/1/0/str:1,agi:1,int:1/[-1]/[3,5]",
                        @"u/1/0/str:1,agi:1,int:1/[-1]/[4,5]",
                        @"u/2/100/str:1,agi:1,int:1/[-1][5,5]",
                        @"u/2/100/str:1,agi:1,int:1/[-1][6,5]",
                        @"u/2/100/str:1,agi:1,int:1/[-1][7,5]",
                        @"u/2/100/str:1,agi:1,int:1/[-1][8,5]",
                        @"u/2/100/str:1,agi:1,int:1/[-1][9,5]",
                        @"u/1/0/str:1,agi:1,int:1/[-1]/[0,5]",
                        nil];
    }
}

- (void) loadOppSetup:(NSString *)setup;
{
    NSAssert(setup != nil, @">[FATAL]   ERROR WHILE LOADING OPPONENTS SETUP! ITS NIL!");
    self.opPieces = [setup componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]];
}

- (bool) saveSetup:(NSArray *)setup unitCount:(int)count
{
    self.unitCount = count;
    self.pieces = setup;
    return true;
}

- (bool) saveProfile
{
    return true;
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

- (NSString *) getPieces
{
    return [self.pieces componentsJoinedByString:@"|"];
}

@end
