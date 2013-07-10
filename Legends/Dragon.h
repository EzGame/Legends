//
//  Dragon.h
//  Legends
//
//  Created by David Zhang on 2013-06-27.
//
//

#import "Unit.h"
#import "Defines.h"
#import "CCActions.h"
#import "MenuItemSprite.h"
#import "cocos2d.h"

@interface Dragon : Unit
@property (nonatomic, strong) CCActions *idle;
@property (nonatomic, strong) CCActions *move;
@property (nonatomic, strong) CCActions *moveEnd;
@property (nonatomic, strong) CCActions *fireball;
@property (nonatomic, strong) CCActions *flamebreath;

@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *fireballButton;
@property (nonatomic, strong) MenuItemSprite *flamebreathButton;

+ (id) dragonWithValues:(NSArray *)values;
+ (id) dragonForEnemyWithValues:(NSArray *)values;
+ (id) dragonForSetupWithValues:(NSArray *)values;

- (id) initDragonFor:(BOOL)side withValues:(NSArray *)values;
- (id) initDragonForSetupWithValues:(NSArray *)values;

- (CGPoint *) getFireballArea;
- (CGPoint *) getFireballEffect;
- (CGPoint *) getFlamebreathArea;
- (CGPoint *) getFlamebreathEffect;
@end
