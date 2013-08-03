//
//  Gorgon.h
//  Legend
//
//  Created by David Zhang on 2013-05-10.
//
//

#import "Unit.h"
#import "cocos2d.h"
#import "CCActions.h"
#import "MenuItemSprite.h"

@interface Gorgon : Unit

@property (nonatomic, strong) CCActions     *idle;
@property (nonatomic, strong) CCActions     *move;
@property (nonatomic, strong) CCActions     *shoot;
@property (nonatomic, strong) CCActions     *freeze;
@property (nonatomic, strong) CCActions     *dead;

@property (nonatomic, strong) MenuItemSprite *moveButton;
@property (nonatomic, strong) MenuItemSprite *shootButton;
@property (nonatomic, strong) MenuItemSprite *freezeButton;

+ (id) gorgonWithObj:(UnitObj *)obj;
+ (id) gorgonForEnemyWithObj:(UnitObj *)obj;
+ (id) gorgonForSetupWithObj:(UnitObj *)obj;

- (id) initGorgonFor:(BOOL)side withObj:(UnitObj *)obj;
- (id) initGorgonForSetupWithObj:(UnitObj *)obj;

- (CGPoint *) getShootArea;
- (CGPoint *) getShootEffect;
- (CGPoint *) getFreezeArea;
- (CGPoint *) getFreezeEffect;
@end
