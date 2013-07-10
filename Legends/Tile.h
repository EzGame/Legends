//
//  Tile.h
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "cocos2d.h"
#import "Unit.h"
#import "Buff.h"

@interface Tile : NSObject <BuffTargetDelegate>
{
    CCSprite *tileSprite;
    BOOL isABlaze;
}

@property (nonatomic, strong) Unit *unit;
@property (nonatomic, strong) NSMutableArray *buffs;
@property (nonatomic, readonly) int status;
// Tile coordindates
@property (nonatomic) CGPoint boardPos;

@property (nonatomic) bool isOccupied;
@property (nonatomic) bool isOwned;

+ (id)tileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
+ (id)invalidTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
+ (id)setupTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
@end
