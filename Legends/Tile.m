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
@synthesize boardPos = _boardPos;

+ (id)tileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite
{
    return [[Tile alloc] initWithPosition:boardPos status:REGULAR sprite:sprite];
}

+ (id)invalidTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite
{
    return [[Tile alloc] initWithPosition:boardPos status:INVALID sprite:sprite];
}

+ (id)setupTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite
{
    return [[Tile alloc] initWithPosition:boardPos status:SETUP sprite:sprite];
}

- (id)initWithPosition:(CGPoint)boardPos status:(int)status sprite:(CCSprite *)sprite
{
    self = [super init];
    if (self)
    {
        _boardPos = boardPos;
        _isOccupied = false;
        _isOwned = false;
        _buffs = [NSMutableArray array];
        
        tileSprite = sprite;
        isABlaze = NO;
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@",
            (self.isOwned)? @"O" :@"E",
            NSStringFromCGPoint(self.boardPos) ];
}

- (void) setUnit:(Unit *)unit
{
    NSLog(@">[MYLOG] Entering Tile:setUnit %@",unit);
    _unit = unit;
    for ( Buff *buff in self.buffs ) {
        [buff somethingChanged:self];
    }
}

- (void) buffTargetFinished:(Buff *)buff
{
    NSLog(@">[MYLOG] Entering Tile:buffFinished");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        [self.buffs removeObject:buff];
    } else if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        isABlaze = NO;
        [self.buffs removeObject:buff];
    }
}

- (void) buffTargetStarted:(Buff *)buff
{
    NSLog(@">[MYLOG] Entering Tile:buffStarted");
    if ( [buff isKindOfClass:[StoneGazeDebuff class]] ) {
        [self.buffs addObject:buff];
    } else if ( [buff isKindOfClass:[BlazeDebuff class]] ) {
        isABlaze = YES;
        [self.buffs addObject:buff];
    }
}
@end
