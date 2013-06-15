//
//  Minotaur.h
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Unit.h"
#import "cocos2d.h"
#import "CCActions.h"
#import "MenuItemSprite.h"

@interface Minotaur : Unit

// Actions
@property (nonatomic, strong) CCActions      *idle;
@property (nonatomic, strong) CCActions      *move;
@property (nonatomic, strong) CCActions      *attk;
@property (nonatomic, strong) CCActions      *dead;

// Menu
@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *attkButton;
@property (nonatomic, strong) MenuItemSprite *defnButton;

+ (id) minotaurWithValues:(NSArray *)values;
+ (id) minotaurForEnemyValues:(NSArray *)values;
+ (id) minotaurForSetupValues:(NSArray *)values;

- (id) initMinotaurFor:(BOOL)side withValues:(NSArray *)values;
- (id) initMinotaurForSetupWithValues:(NSArray *)values;

@end
