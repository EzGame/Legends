//
//  Tile.m
//  Legend
//
//  Created by David Zhang on 2013-04-23.
//
//

#import "Tile.h"

@implementation Tile
@synthesize unit = _unit, status = _status, buffs = _buffs;
@synthesize boardPos = _boardPos, absPos = _absPos;

+ (id)tileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos
{
    return [[Tile alloc] initWithPosition:boardPos absPos:absPos status:REGULAR];
}

+ (id)invalidTileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos
{
    return [[Tile alloc] initWithPosition:boardPos absPos:absPos status:INVALID];
}

+ (id)setupTileWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos
{
    return [[Tile alloc] initWithPosition:boardPos absPos:absPos status:SETUP];
}

- (id)initWithPosition:(CGPoint)boardPos absPos:(CGPoint)absPos status:(int)status
{
    self = [super init];
    if (self)
    {
        _boardPos = boardPos;
        _absPos = absPos;
        _isOccupied = false;
        _isOwned = false;
        _buffs = [NSMutableArray array];
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ @[%d,%d]", (self.isOwned)? @"O" :@"E", (int)self.boardPos.x, (int)self.boardPos.y ];
}

- (void) setUnit:(Unit *)unit
{
    NSLog(@">[MYLOG] Entering Tile:setUnit");
    _unit = unit;
    for ( Buff *buff in self.buffs ) {
        [buff somethingChanged:self];
    }
}

- (void) buffTargetFinished:(Buff *)buff
{
    NSLog(@">[MYLOG] Entering Tile:buffFinished");
    for ( Buff *buffs in self.buffs ) {
        if ( [buff isEqual:buffs] ) {
            [self.buffs removeObject:buffs];
        }
    }
}
@end
