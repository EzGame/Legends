//
//  PlayerResources.h
//  Legends
//
//  Created by David Zhang on 2014-01-07.
//
//

#import "cocos2d.h"
#import "Constants.h"
#import "GeneralUtils.h"
#import "Unit.h"

@interface PlayerResources : CCNode
@property (nonatomic, strong)   CCProgressTimer *manaBar;
@property (nonatomic, strong)          CCSprite *manaBarFrame;
@property (nonatomic)                       int totalMana;
@property (nonatomic)                       int currMana;
@property (nonatomic)                       int manaRegen;

@property (nonatomic, strong)   CCProgressTimer *cpBar;
@property (nonatomic, strong)          CCSprite *cpBarFrame;
@property (nonatomic)                       int totalCP;
@property (nonatomic)                       int currCP;

@property (nonatomic, strong)   CCLabelBMFont *display;

+ (id) playerResource;

- (BOOL) canCastMana:(int)manaCost cmd:(int)cp;
- (void) castMana:(int)manaCost cmd:(int)cp;
- (void) deathTo:(Unit *)unit;
- (void) reset;
@end
