////
////  Tile.m
////  Legend
////
////  Created by David Zhang on 2013-04-23.
////
////
//
#import "Tile.h"
@implementation Tile
- (void) setUnit:(Unit *)unit
{
    if ( unit != NULL ) {
        self.isOccupied = YES;
        self.isOwned = unit.isOwned;
        unit.boardPos = self.boardPos;
    } else {
        self.isOccupied = NO;
        self.isOwned = NO;
    }
    _unit = unit;
}

- (id) init
{
    self = [super init];
    if ( self ) {
        _touched = NO;
    }
    return self;
}

- (NSString *) description
{
    NSString *ret = [NSString stringWithFormat:@"<Tile> @%@ oc:%d ow:%d touched:%d",NSStringFromCGPoint(self.boardPos), self.isOccupied, self.isOwned, self.touched];
    return ret;
}
@end
//
//@implementation Tile
//@synthesize unit = _unit, buffs = _buffs;
//@synthesize boardPos = _boardPos, isOwned = _isOwned, isOccupied = _isOccupied;
//
//+ (id)tileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite
//{
//    return [[Tile alloc] initWithPosition:boardPos sprite:sprite];
//}
//
//+ (id)invalidTileWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite;
//{
//    return [[Tile alloc] initWithPosition:boardPos sprite:sprite];
//}
//
//- (id)initWithPosition:(CGPoint)boardPos sprite:(CCSprite *)sprite
//{
//    self = [super init];
//    if (self)
//    {
//        _boardPos = boardPos;
//        _isOccupied = false;
//        _isOwned = false;
//        _buffs = [NSMutableArray array];
//
//        tileSprite = sprite;
//    }
//    return self;
//}
//
//- (NSString*) description
//{
//    return [NSString stringWithFormat:@"%@|%@ %@",
//            (self.isOwned)? @"ME" :@"OP",
//            (self.isOccupied)? @"O" :@"E",
//            NSStringFromCGPoint(self.boardPos) ];
//}
//
//- (void) setUnit:(Unit *)unit
//{
//    if ( unit == nil ) {
//        _isOccupied = NO;
//        _isOwned = NO;
//    } else {
//        _isOccupied = YES;
//        _isOwned = unit.isOwned;
//        unit.boardPos = _boardPos;
//    }
//
//    _unit = unit;
//}
//
//- (Buff *) findBuff:(Class)class
//{
//    for ( Buff *buff in self.buffs )
//    {
//        if ( [buff isKindOfClass:class] ) {
//            return buff;
//        } else {
//            continue;
//        }
//    }
//    return nil;
//}
//
//- (void) reset
//{
//    for ( Buff *buff in self.buffs ) {
//        [buff buffEffectOnEvent:EventReset forTile:self];
//    }
//}
//
//- (void) buffTargetFinished:(Buff *)buff
//{
//    NSLog(@">[MYLOG] Entering Tile %@:buffFinished",self);
//    if ( [buff isKindOfClass:[BlazeBuff class]] ) {
//        [self.delegate tileDelegateTransformTileMe:self
//                                           fromGid:PLAIN_GRASS_TO_MOLTEN_END
//                                             toGid:PLAIN_GRASS_TO_MOLTEN_START
//                                             delay:0.6];
//    }
//    [self.buffs removeObject:buff];
//}
//
//- (void) buffTargetStarted:(Buff *)buff
//{
//    NSLog(@"\n>[MYLOG] Entering Tile %@:buffStarted",self);
//    Buff * prevBuff = [self findBuff:[buff class]];
//    if ( prevBuff != nil ) {
//        NSLog(@"\n>[MYLOG]    Tile %@:\n Replacing buff %@\n With %@\n",
//              self, prevBuff, buff);
//        [self.buffs replaceObjectAtIndex:[self.buffs indexOfObject:prevBuff] withObject:buff];
//    }
//    
//    NSLog(@">[MYLOG]    Tile %@:\n Adding buff %@", self, buff);
//    if ( [buff isKindOfClass:[BlazeBuff class]] ) {
//        [self.delegate tileDelegateTransformTileMe:self
//                                           fromGid:PLAIN_GRASS_TO_MOLTEN_START
//                                             toGid:PLAIN_GRASS_TO_MOLTEN_END
//                                             delay:0.6];
//    }
//    [self.buffs addObject:buff];
//}
//@end
//
//@implementation SetupTile
//@synthesize unit = _unit;
//@synthesize boardPos = _boardPos, isOccupied = _isOccupied, isReserve = _isReserve;
//
////- (void) setUnit:(SetupUnit *)unit
////{
////    if ( unit == nil ) {
////        self.isOccupied = NO;
////    } else {
////        self.isOccupied = YES;
////        unit.direction = (self.isReserve)? SW : NE;
////        unit.obj.position = (self.isReserve)? ccp(-1,-1) : self.boardPos;
////    }
////    _unit = unit;
////}
//
//+ (id) setupTileWithPosition:(CGPoint)boardPos isReserve:(BOOL)isReserve
//{
//    return [[SetupTile alloc] initSetupTileWithPosition:boardPos isReserve:isReserve];
//}
//
//- (id) initSetupTileWithPosition:(CGPoint)boardPos isReserve:(BOOL)isReserve
//{
//    self = [super init];
//    if ( self ) {
//        _boardPos = boardPos;
//        _isOccupied = NO;
//        _isReserve = isReserve;
//    }
//    return self;
//}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%d[%@] @%@",self.isReserve, self.unit, NSStringFromCGPoint(self.boardPos)];
//}
//@end
