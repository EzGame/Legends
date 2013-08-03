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
{
}

// Actions
@property (nonatomic, strong) CCActions      *idle;
@property (nonatomic, strong) CCActions      *move;
@property (nonatomic, strong) CCActions      *attk;
@property (nonatomic, strong) CCActions      *dead;

// Menu
@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *attkButton;
@property (nonatomic, strong) MenuItemSprite *defnButton;

+ (id) minotaurWithObj:(UnitObj *)obj;
+ (id) minotaurForEnemyObj:(UnitObj *)obj;
+ (id) minotaurForSetupObj:(UnitObj *)obj;

- (id) initMinotaurFor:(BOOL)side withObj:(UnitObj *)obj;
- (id) initMinotaurForSetupWithObj:(UnitObj *)obj;

- (CGPoint *) getAttkArea;
- (CGPoint *) getAttkEffect;
@end
