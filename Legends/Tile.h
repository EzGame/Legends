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

@class Tile;
@protocol TileDelegate <NSObject>
@required
- (void)    transformTileMe:(Tile *)tile
                      toGid:(int)start
                      toGid:(int)end;
@end

@interface Tile : NSObject <BuffTargetDelegate>
{
    CCSprite *tileSprite;
    BOOL isABlaze;
}

@property (nonatomic, strong) id<TileDelegate> delegate;
@property (nonatomic, strong) Unit *unit;
@property (nonatomic, strong) NSMutableArray *buffs;
@property (nonatomic, readonly) int status;
// Tile coordindates
@property (nonatomic) CGPoint boardPos;

@property (nonatomic) bool isOccupied;
@property (nonatomic) bool isOwned;

+ (id)tileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
+ (id)invalidTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
@end

@interface SetupTile : NSObject
@property (nonatomic, strong) SetupUnit *unit;
@property (nonatomic) CGPoint boardPos;
@property (nonatomic) BOOL isOccupied;
@property (nonatomic) BOOL isReserve;

+ (id) setupTileWithPosition:(CGPoint)boardPos isReserve:(BOOL)isReserve;
@end

