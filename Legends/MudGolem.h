//
//  MudGolem.h
//  Legends
//
//  Created by David Zhang on 2013-06-26.
//
//

#import <Foundation/Foundation.h>
#import "Unit.h"
#import "Defines.h"
#import "CCActions.h"
#import "MenuItemSprite.h"
#import "cocos2d.h"

@interface MudGolem : Unit
extern const NSString *MUDGOLEM_TWO_DESP;
extern const NSString *MUDGOLEM_ONE_DESP;
extern const NSString *MUDGOLEM_MOVE_DESP;

@property (nonatomic, strong) CCActions *idle;
@property (nonatomic, strong) CCActions *move;
@property (nonatomic, strong) CCActions *moveEnd;
@property (nonatomic, strong) CCActions *attk;
@property (nonatomic, strong) CCActions *earthquake;

@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *attkButton;
@property (nonatomic, strong) MenuItemSprite *earthquakeButton;

+ (id) mudGolemWithObj:(UnitObj *)obj;
+ (id) mudGolemForEnemyWithObj:(UnitObj *)obj;
+ (id) mudGolemForSetupWithObj:(UnitObj *)obj;

- (id) initMudGolemFor:(BOOL)side withObj:(UnitObj *)obj;
- (id) initMudGolemForSetupWithObj:(UnitObj *)obj;

- (CGPoint *) getEarthquakeArea;
- (CGPoint *) getEarthquakeEffect;
- (CGPoint *) getAttkArea;
- (CGPoint *) getAttkEffect;
@end
