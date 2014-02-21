//
//  SetupBrain.m
//  Legends
//
//  Created by David Zhang on 2013-02-08.
//
//

#import "SetupBrain.h"
@interface SetupBrain()
@property (nonatomic, strong) Tile *currentTilePtr;
@end

@implementation SetupBrain
#pragma mark - Setters n Getters
- (void) setCurrentLayerPosition:(CGPoint)currentLayerPosition
{
    self.toScn = CGAffineTransformMake(-GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                       GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                       SETUPTILEOFFSETX + currentLayerPosition.x,
                                       SETUPTILEOFFSETY + currentLayerPosition.y);
    self.toIso = CGAffineTransformInvert(self.toScn);
    _currentLayerPosition = currentLayerPosition;
}










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Init n shit
- (id) initWithMap:(CCTMXLayer *)tmxLayer delegate:(id)delegate
{
    self = [super init];
    if ( self ) {
        // Set delegate
        _delegate = delegate;
        
        // Create setup board
        _setupBoard = [[NSArray alloc] initWithObjects:
                       [NSMutableArray array],       // 0
                       [NSMutableArray array],       // 1
                       [NSMutableArray array],       // 2
                       [NSMutableArray array],       // 3
                       [NSMutableArray array],       // 4
                       [NSMutableArray array],       // 5
                       [NSMutableArray array],       // 6
                       [NSMutableArray array],       // 7
                       [NSMutableArray array],       // 8
                       [NSMutableArray array],       // 9
                       [NSMutableArray array], nil]; // 10
        
        // Save weak pointer to tmxLayer
        _tmxLayer = tmxLayer;
        
        // Populating board with tiles
        for ( int i = 0; i < SETUPMAPWIDTH; i++ ) {
            for ( int k = 0; k < SETUPMAPHEIGHT; k++ ) {
                CGPoint pos = CGPointMake(i, k);
                Tile *tile = [[Tile alloc] init];
                if ( [self isValidPos:pos] ) {
                    tile.boardPos = pos;
                    tile.sprite = [tmxLayer tileAt:[self getInvertedPos:pos]];
                }
                [[_setupBoard objectAtIndex:i] addObject:tile];
            }
        }
        
        // Setting isometric - world transforms
        _toWld = CGAffineTransformMake( -GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                       GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                       SETUPTILEOFFSETX, SETUPTILEOFFSETY);
        _toScn = _toWld;
        _toIso = CGAffineTransformInvert(_toWld);
        
        // Fill board with player owned units
        //[self initSetup];
    }
    return self;
}

- (Unit *) touchStarted:(CGPoint)position
{
    // Turn off color
    if ( self.currentTilePtr != nil ) self.currentTilePtr.sprite.color = ccWHITE;
    
    // Get tile
    CGPoint boardPos = [self getIsoPosFromScreen:position];
    Tile *tilePtr = [self getTileWithPos:boardPos];
    if ( tilePtr == nil ) return nil;
    
    // Save this tile ptr and return unit
    _currentTilePtr = tilePtr;
    if ( tilePtr.unit !=  nil ) return tilePtr.unit;
    return nil;
}

- (void) touchEnded:(CGPoint)position unit:(Unit *)unit
{
    CGPoint boardPos = [self getIsoPosFromScreen:position];
    Tile *tilePtr = [self getTileWithPos:boardPos];
    
    if ( unit != nil && tilePtr != nil) {
        NSLog(@"Moving unit");
        // Move unit
        _currentTilePtr.unit = nil;
        tilePtr.unit = unit;
        tilePtr.unit.position = [self getWorldPosFromIso:tilePtr.boardPos];
        [self.delegate setupBrainDidMoveUnitTo:tilePtr];
        
    } else if ( unit != nil && tilePtr == nil ) {
        NSLog(@"Deleting unit");
        // Delete unit
        _currentTilePtr.unit = nil;
        [self.delegate setupBrainDidRemoveUnit:unit];
        
    } else if ( unit == nil && tilePtr != nil ) {
        // Open menu for new unit
        tilePtr.sprite.color = ccGREENYELLOW;
        
        // Find screen pos
        CGPoint scrPos = [self getScreenPosFromIso:boardPos];
        [self.delegate setupBrainNeedsUnitMenuAt:scrPos];
        
    } else {
        // no use yet for nil unit and nil ptr
    }
    [self printBoard];
}

- (void) addUnit:(UnitObject *)obj
{
    // Make unit
    Unit *unitPtr;
    if ( obj.type == UnitTypePriest ) {
        unitPtr = [Priest priest:obj isOwned:YES];
    } else if ( obj.type == UnitTypeWarrior ) {
        unitPtr = [Warrior warrior:obj isOwned:YES];
    } else if ( obj.type == UnitTypeRanger ) {
        unitPtr = [Ranger ranger:obj isOwned:YES];
    } else if ( obj.type == UnitTypeWitch ) {
        unitPtr = [Witch witch:obj isOwned:YES];
    } else if ( obj.type == UnitTypeKnight ) {
        unitPtr = [Knight knight:obj isOwned:YES];
    } else if ( obj.type == UnitTypeBerserker ) {
        unitPtr = [Berserker berserker:obj isOwned:YES];
    } else if ( obj.type == UnitTypePaladin ) {
        unitPtr = [Paladin paladin:obj isOwned:YES];
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN BATTLEBRAIN:FINDTYPE %d", obj.type);
    }
    unitPtr.delegate = self;
    
    // get tile
    Tile *tilePtr = (obj.isPositioned) ? [self getTileWithPos:obj.position] : self.currentTilePtr;
    tilePtr.unit = unitPtr;
    tilePtr.sprite.color = ccWHITE;
    tilePtr.unit.position = [self getWorldPosFromIso:tilePtr.boardPos];
    
    // Upload visually
    [self.delegate setupBrainDidLoadUnitAt:tilePtr];
}

#pragma mark - Utility
/* Print out the current state of the board by unit type and ownership */
- (void) printBoard
{
    CCLOG(@"    ********TYPE*******************OWNED***********");
    for ( int i = SETUPMAPWIDTH - 1; i >= 0 ; i-- ) {
        NSMutableString *current = [NSMutableString string];
        for ( int k = 0; k < SETUPMAPHEIGHT ; k++ ) {
            Tile *temp = [[self.setupBoard objectAtIndex:i] objectAtIndex:k];
            if (temp.unit != nil)
                [current appendFormat:@"%d ", temp.unit.object.type];
            else
                [current appendFormat:@". "];
        }
        [current appendString:@"*** "];
        
        for ( int k = 0; k < SETUPMAPHEIGHT; k++ ) {
            NSString *gid = [NSString stringWithFormat:@"%d ",
                             [self.tmxLayer tileGIDAt:[self getInvertedPos:CGPointMake(i, k)]]];
            [current appendString:gid];
        }
        CCLOG(@"    %@", current);
    }
    CCLOG(@"    ***********************************************");
}

- (BOOL) isValidPos:(CGPoint)position
{
    int i = position.x;
    int j = position.y;
    if ( i < 0 || i >= SETUPMAPWIDTH || j < 0 || j >= SETUPMAPHEIGHT )
        return false;
    return !([self.tmxLayer tileGIDAt:[self getInvertedPos:position]] == 0);
}

/* Returns if position is an occupied board position*/
- (BOOL) isOccupiedPos:(CGPoint)position
{
    Tile *tilePtr = [self getTileWithPos:position];
    return tilePtr.isOccupied;
}

/* Returns a tile at the position */
- (Tile *) getTileWithPos:(CGPoint)position
{
    if ( ![self isValidPos:position] ) {
        return nil;
    } else {
        return [[self.setupBoard objectAtIndex:position.x] objectAtIndex:position.y];
    }
}

/* Returns a world position transformed from a board position */
- (CGPoint) getWorldPosFromIso:(CGPoint)position
{
    return CGPointApplyAffineTransform(position, self.toWld);
}

/* Returns a screen position transformed from a board position */
- (CGPoint) getScreenPosFromIso:(CGPoint)position
{
    return CGPointApplyAffineTransform(position, self.toScn);
}

/* Returns a board position transformed from a screen position */
- (CGPoint) getIsoPosFromScreen:(CGPoint)position
{
    CGPoint pos = CGPointApplyAffineTransform(position, self.toIso);
    return ccp(floor(pos.x), floor(pos.y));
}

/* Returns a inverted board position */
- (CGPoint) getInvertedPos:(CGPoint)position
{
    return CGPointMake(SETUPMAPWIDTH - 1 - floor(position.x),
                       SETUPMAPHEIGHT - 1 - floor(position.y));
}
@end

//
//- (bool) saveSetup
//{
//    CCLOG(@"MYLOG:  SetupLayer::savePressed Saving configuration");
//    // The array to be saved
//    SFSArray *array = [SFSArray newInstance];
//    for (int i = 0; i < SETUPMAPLENGTH; i++) {
//        for (int k = 0; k < SETUPMAPWIDTH; k++) {
//            // Find the tile
//            SetupTile *tile = [[self.board objectAtIndex:i] objectAtIndex:k];
//            if ( ![tile isKindOfClass:[NSNull class]] && tile.unit != nil )
//            {
//                [tile.unit.obj setPosition:ccp(i,k)];
//                [array addClass:tile.unit.obj];
//            }
//        }
//    }
//    return [[UserSingleton get] saveSetup:array
//                                 unitFood:totalFood
//                                unitValue:totalValue];
//}