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

@property (nonatomic, strong) Unit *unit;
@property (nonatomic, strong) NSMutableArray *buffs;
@property (nonatomic, readonly) int status;
// Tile coordindates
@property (nonatomic) CGPoint boardPos;
@property (nonatomic) CGPoint absPos;

@property (nonatomic) bool isOccupied;
@property (nonatomic) bool isOwned;

+ (id)tileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos;
+ (id)invalidTileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos;
+ (id)setupTileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos;

@end
