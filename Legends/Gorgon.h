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

+ (id) gorgon;
+ (id) gorgonForEnemy;
+ (id) gorgonForSetup;

- (id) initGorgonFor:(BOOL)side;
- (id) initGorgonForSetup;
- (NSArray *) getShootArea:(CGPoint)position;
- (NSArray *) getFreezeArea:(CGPoint)position;

- (void) freeze:(Unit *)unit;
@end
