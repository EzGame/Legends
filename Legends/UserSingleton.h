//
//  UserSingleton.h
//  LegendsReborn
//
//  Created by David Zhang on 2013-04-17.
//
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface UserSingleton : NSObject

@property (nonatomic) int ELO;
@property (nonatomic) int TELO;
@property (nonatomic) int actionsPerTurn;
@property (nonatomic) int maxActions;
@property (nonatomic) int unitCount;
@property (nonatomic) BOOL amIPlayerOne;
@property (nonatomic) BOOL isFirstLaunch;

@property (nonatomic, strong) NSArray *pieces;
@property (nonatomic, strong) NSArray *opPieces;
@property (nonatomic, strong) NSMutableArray *items;

+ (UserSingleton *) get;

- (void) loadProfile:(NSDictionary *)profile newbie:(BOOL)isFirstLoad;
- (void) loadOppSetup:(NSString *)setup;
- (bool) saveSetup:(NSArray *)setup unitCount:(int)count;

- (int) getKForMM;
- (int) getKForTMM;
- (NSString *) getPieces;

@end

