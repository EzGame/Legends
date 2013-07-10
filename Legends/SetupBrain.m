//
//  SetupBrain.m
//  Legends
//
//  Created by David Zhang on 2013-02-08.
//
//

#import "SetupBrain.h"
#import "Gorgon.h"
#import "Minotaur.h"

@interface SetupBrain()
{
    CGPoint savedPos;
}
@property (nonatomic, strong) Tile *saved;
@end

@implementation SetupBrain
@synthesize board = _board;
@synthesize delegate = _delegate;
// private
@synthesize saved = _saved;

- (id) init
{
    CCLOG(@"MYLOG:  Entering SetupBrain::init");
    
    self = [super init];
    if ( self )
    {
        // Matrices for conversion from cartesian to isometric and vice versa.
        toIso = CGAffineTransformMake(-SETUPHALFLENGTH, SETUPHALFWIDTH, SETUPHALFLENGTH, SETUPHALFWIDTH, SETUPOFFSETX, SETUPOFFSETY);
        fromIso = CGAffineTransformInvert(toIso);

        _board = [[NSArray alloc] initWithObjects:
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],
                  [NSMutableArray array],nil];
        
        // Populating board
        for ( int i = 0 ; i < SETUPMAPLENGTH ; i++ ) {
            for ( int k = 0 ; k < SETUPMAPWIDTH ; k++ ) {
                int ret = [self isValidTile:ccp(i,k)];
                if ( !ret ) {
                    [[self.board objectAtIndex:i] addObject:
                     [Tile invalidTileWithPosition:ccp(i,k) sprite:nil]];
                    
                } else if ( ret == 2 ) {
                    [[self.board objectAtIndex:i] addObject:
                     [Tile setupTileWithPosition:ccp(i,k) sprite:nil]];
                    
                } else {
                    [[self.board objectAtIndex:i] addObject:
                     [Tile tileWithPosition:ccp(i,k) sprite:nil]];
                    
                }
            }
        }
        [self printBoard];
    }
    
    CCLOG(@"MYLOG:  Exiting SetupBrain::init\n");
    return self;
}

- (id) findUnit:(int)type withValues:(NSArray *)values;
{
    if (type == MINOTAUR) {
        return [[Minotaur alloc] initMinotaurForSetupWithValues:values];
        
    } else if ( type == GORGON ) {
        return [[Gorgon alloc] initGorgonForSetupWithValues:values];
        
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN BATTLEBRAIN:FINDUNIT %d", type);
        return nil;
        
    }
}

- (int) findType:(Unit *)unit {
    if ( [unit isKindOfClass:[Minotaur class]] ) {
        return MINOTAUR;
    } else if ( [unit isKindOfClass:[Gorgon class]] ) {
        return GORGON;
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN SETUPBRAIN:FINDTYPE");
        return -1;
    }
    
}

- (void) restoreSetup
{
    // Populating pieces
    for ( int i = 0; i < [[[UserSingleton get] pieces] count]; i++ )
    {
        // The stored string is in the form of @type[@x,@y]
        NSString *string = [[[UserSingleton get] pieces] objectAtIndex:i];
        NSArray *values = [string componentsSeparatedByCharactersInSet:[UserSingleton get].valueSeparator];
        int type, x = -1, y = -1;
        if ( [values objectAtIndex:5] != nil )
        {
            NSArray *pos = [[values objectAtIndex:5] componentsSeparatedByCharactersInSet:[UserSingleton get].stringSeparator];
            x = [(NSString *)[pos objectAtIndex:0] integerValue];
            y = [(NSString *)[pos objectAtIndex:1] integerValue];
            if ( y == 5 ) continue;
        }
        type = [[values objectAtIndex:1] integerValue];
        Unit *unit = [self findUnit:type withValues:values];
        
        // Finding tile
        Tile *tile = [self findTile:ccp(x,y) absPos:false];
        tile.unit = unit;
        tile.isOccupied = true;
        tile.isOwned = true;
        
        // Upload visually
        [self.delegate loadTile:tile];
    }
}

- (void) setCurrentLayerPos:(CGPoint)position
{
    currentLayerPos = position;
    toIso = CGAffineTransformMake(-SETUPHALFLENGTH, SETUPHALFWIDTH,
                                  SETUPHALFLENGTH, SETUPHALFWIDTH,
                                  SETUPOFFSETX + position.x, SETUPOFFSETY + position.y);
    fromIso = CGAffineTransformInvert(toIso);
}

/* findTile - Find the tile located at an absolute position
 * (CGPoint)position    - input absolute position
 * (bool)absPos         - if the position passed in was absolute or board position
 * return               - tile located at the absolute position
 */
- (Tile *) findTile:(CGPoint)position absPos:(bool)absPos
{
    int         tileX;
    int         tileY;
    Tile      * tile;
    // Convert touch location to a tile location

    if (absPos)
        position = CGPointApplyAffineTransform(position, fromIso);

    tileX = (int)floor(position.x);
    tileY = (int)floor(position.y);
    if ( ![self isValidTile:ccp(tileX,tileY)] )
    {
        CCLOG(@"    The tile [%d,%d] is out of bounds", tileX, tileY);
        return nil;
    }
    tile = [[self.board objectAtIndex:tileX] objectAtIndex:tileY];

    return tile;
}

/* findBoardPos - Find the board position with an absolute position
 * (CGPoint)position    - input absolute position
 * return               - board position
 */
- (CGPoint) findBrdPos:(CGPoint)position
{
    CGPoint ret = CGPointApplyAffineTransform(position, fromIso);
    ret = ccp(floor(ret.x), floor(ret.y));
    return ret;
}

/* findBoardPos - Find the position of the absolute position with 
 *                a board position
 * (CGPoint)position    - input board-position
 * return               - absolute position
 */
- (CGPoint) findAbsPos:(CGPoint)position
{
    
    CGPoint ret = CGPointApplyAffineTransform(position, toIso);
    ret = ccp(ret.x,ret.y + SETUPHALFWIDTH);
    return ret;
}

/* isValidTile - Find out the status of the tile at a board position
 * (CGPoint)position    - input board-position
 * return               - 0 if invalid
 *                      - 1 if valid
 *                      - 2 if setup
 */
- (int) isValidTile:(CGPoint)position
{
    int i = position.x;
    int k = position.y;
    if ( i < 0 || i > 10 || k < 0 || k > 5 )
        return 0;
    // don't fuck with this if
    if ((!(abs(i-10) && k) && i-10 > -2 && k < 2) ||
        //(!(i && abs(k-5)) && k-5 > -2 && i < 2) ||
        (!(i && k) && i < 2 && k < 2) )
        return 0;
    if ( k == 5 )
        return 2;
    return 1;
}

- (void) swapPieces:(Tile *)tile with:(Tile *)original
{
    NSLog(@">[MYLOG]    Entering SetupBrain::swapPieces");
    // Don't need to do anything if no move is made
    if ( ![original isEqual:tile] )
    {
        tile.unit = original.unit;
        tile.isOccupied = true;
        original.unit = nil;
        original.isOccupied = false;
    }
    
    // if its a setup tile, make the facing direction SW
    tile.unit.sprite.position = ccpSub([self findAbsPos:tile.boardPos], currentLayerPos);
    CGPoint temp = (tile.boardPos.y == 5)? ccp(-1,-1):ccp(1,1);
    [tile.unit action:TURN at:ccpAdd(tile.unit.sprite.position, temp)];
}

- (void) saveState:(Tile *)tile save:(bool)save
{
    NSLog(@">[MYLOG]    Entering SetupBrain::saveState:%d",save);
    if ( save )
    {
        self.saved = tile;
        savedPos = tile.unit.sprite.position;
    }
    else
    {
        // reverting saved 
        tile.boardPos = self.saved.boardPos;
        tile.isOccupied = true;
        tile.unit.sprite.position = ccpSub([self findAbsPos:self.saved.boardPos], currentLayerPos);
        
        // if its a setup tile, make the facing direction SW
        CGPoint temp = (self.saved.boardPos.y == 5)? ccp(-1,-1):ccp(1,1);
        [tile.unit action:TURN at:ccpAdd(tile.unit.sprite.position, temp)];
        
        // removing the save
        self.saved = nil;
        savedPos = CGPointZero;
    }
}

- (bool) saveSetup
{
    CCLOG(@"MYLOG:  SetupLayer::savePressed Saving configuration");
    // The array to be saved
    int count;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < SETUPMAPLENGTH; i++) {
        for (int k = 0; k < SETUPMAPWIDTH; k++) {
            // Find the tile
            NSString *string;
            Tile *tile = [[self.board objectAtIndex:i] objectAtIndex:k];
            if ( tile.unit != nil )
            {
                count++;
                // Put the tile information into a string
                string = [NSString stringWithFormat:@"%d[%d,%d]", [self findType:tile.unit],
                          (int)tile.boardPos.x, (int)tile.boardPos.y];
                [array addObject:string];
            }
        }
    }
    return [[UserSingleton get] saveSetup:array unitCount:count];
}

- (void) printBoard
{
    CCLOG(@"    *******************************");
    for ( int i = SETUPMAPLENGTH - 1; i >= 0 ; i-- )
    {
        NSMutableString *current = [NSMutableString string];
        for ( int k = 0; k < SETUPMAPWIDTH ; k++ )
        {
            Tile *temp;
            temp = [[self.board objectAtIndex:i] objectAtIndex:k];
            if ( temp.status == INVALID )
                [current appendFormat:@"%@ ", @"X"];
            else
                if (temp.unit != nil)
                    [current appendFormat:@"%@ ", temp.unit];
                else
                    [current appendFormat:@". "];
        }

        CCLOG(@"    %@", current);
    }
    CCLOG(@"    *******************************");
}
@end
