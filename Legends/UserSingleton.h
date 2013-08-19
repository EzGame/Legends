//
//  UserSingleton.h
//  LegendsReborn
//
//  Created by David Zhang on 2013-04-17.
//
//

#import <Foundation/Foundation.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "Defines.h"
#import "Objects.h"
#import "UICKeyChainStore.h"

@interface UserSingleton : NSObject
// Inventory
@property (nonatomic, strong, readonly) NSMutableArray *units;
@property (nonatomic, strong, readonly) NSMutableArray *consummables;
@property (nonatomic, strong, readonly) NSMutableArray *misc;

// Preferences + settings
@property (nonatomic) BOOL isFirstLaunch;
@property (nonatomic) int playerLevel;

// Setup properties
@property (nonatomic) int unitCount;
@property (nonatomic) int unitValue;

// Stat properties
@property (nonatomic) int ELO;
@property (nonatomic) int TELO;

// Game properties
@property (nonatomic) BOOL amIPlayerOne;
@property (nonatomic, strong) SFSArray *mySetup;
@property (nonatomic, strong) SFSArray *oppSetup;
@property (nonatomic, strong) SFSUser *me;
@property (nonatomic, strong) SFSUser *opp;

+ (UserSingleton *) get;

- (BOOL) saveOpp:(SFSUser *)user setup:(SFSArray *)array;
- (BOOL) saveSetup:(SFSArray *)array unitFood:(int)count unitValue:(int)value;

- (BOOL) downloadProfileFor:(NSString *)name;
- (BOOL) uploadProfile;
- (int) getKForMM;
- (int) getKForTMM;

/* TESTING FUNCTIONS DELETE AT RELEASE */
- (void) createUnit;
- (void) createMaxUnit;
@end

