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
@property (nonatomic, strong) CCActions *idle;
@property (nonatomic, strong) CCActions *move;
@property (nonatomic, strong) CCActions *moveEnd;
@property (nonatomic, strong) CCActions *attk;
@property (nonatomic, strong) CCActions *earthquake;

@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *attkButton;
@property (nonatomic, strong) MenuItemSprite *earthquakeButton;

+ (id) mudGolemWithValues:(NSArray *)values;
+ (id) mudGolemForEnemyWithValues:(NSArray *)values;
+ (id) mudGolemForSetupWithValues:(NSArray *)values;

- (id) initMudGolemFor:(BOOL)side withValues:(NSArray *)values;
- (id) initMudGolemForSetupWithValues:(NSArray *)values;

- (CGPoint *) getEarthquakeArea;
- (CGPoint *) getEarthquakeEffect;
- (CGPoint *) getAttkArea;
- (CGPoint *) getAttkEffect;
@end
