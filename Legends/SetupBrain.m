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
#import "MudGolem.h"
#import "Dragon.h"
#import "LionMage.h"

@implementation SetupBrain
@synthesize board = _board;
@synthesize sideBoard = _sideBoard;
@synthesize unitList = _unitList;
@synthesize delegate = _delegate;
// private
@synthesize toIso = _toIso, fromIso = _fromIso;
static NSArray *unitTags = nil;

- (id) init
{
    CCLOG(@"MYLOG:  Entering SetupBrain::init");
    
    self = [super init];
    if ( self )
    {
        unitTags = @[
            // Rarities
            @"Epic",
            @"Rare",
            @"Uncommon",
            @"Common",
            // Types
            @"Minotaur",
            @"Gorgon",
            @"Mud Golem",
            @"Dragon",
            @"Lion Priest",
            // Attribute types
            @"Strength",
            @"Agility",
            @"Intelligence",
            // Other tags
            @"Melee",
            @"Ranged",
            @"Magic",
            @"Healer",
            @"Disabler",
            @"Area of effect"
        ];

        // Matrices for conversion from cartesian to isometric and vice versa.
        _toIso = CGAffineTransformMake(-SETUPHALFLENGTH, SETUPHALFWIDTH, SETUPHALFLENGTH, SETUPHALFWIDTH, SETUPOFFSETX, SETUPOFFSETY);
        _fromIso = CGAffineTransformInvert(_toIso);

        _board = [NSArray arrayWithObjects:
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
        
        _sideBoard = [NSArray arrayWithObjects:
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
                    [[self.board objectAtIndex:i] addObject:[NSNull null]];
                } else {
                    [[self.board objectAtIndex:i]
                     addObject:[SetupTile setupTileWithPosition:ccp(i,k) isReserve:NO]];
                }
            }
            for ( int k = SETUPMAPWIDTH ; k < SETUPMAPWIDTH + SETUPSIDEMAPWIDTH; k++ ) {
                [[self.sideBoard objectAtIndex:i] addObject:
                 [SetupTile setupTileWithPosition:ccp(i,k) isReserve:YES]];
            }
        }
        
        _unitList = [[UserSingleton get] units];
        [self printBoard];
    }
    
    CCLOG(@"MYLOG:  Exiting SetupBrain::init\n");
    return self;
}

- (int) findType:(SetupUnit *)unit {
    if ( [unit isKindOfClass:[Minotaur class]] ) {
        return MINOTAUR;
    } else if ( [unit isKindOfClass:[Gorgon class]] ) {
        return GORGON;
    } else if ( [unit isKindOfClass:[MudGolem class]] ) {
        return MUDGOLEM;
    } else if ( [unit isKindOfClass:[Dragon class]] ) {
        return DRAGON;
    } else if ( [unit isKindOfClass:[LionMage class]] ) {
        return LIONMAGE;
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN SETUPBRAIN:FINDTYPE");
        return -1;
    }    
}

- (void) restoreSetup
{
    for ( int i = 0; i < [[[UserSingleton get] setup] size]; i++ )
    {
        UnitObj *obj = [[[UserSingleton get] setup] getElementAt:i];
        NSLog(@">[MYLOG]    SETUPBRAIN:restoreSetup got:\n%@",obj);
        
        SetupUnit *unit = [SetupUnit setupUnitWithObj:obj];
        SetupTile *tile;
        tile = [self findTile:obj.position absPos:NO];
        tile.unit = unit;
        
        // Upload visually
        [self.delegate loadTile:tile];
    }
}

- (void) setCurrentLayerPos:(CGPoint)position
{
    currentLayerPos = position;
    self.toIso = CGAffineTransformMake(-SETUPHALFLENGTH, SETUPHALFWIDTH,
                                       SETUPHALFLENGTH, SETUPHALFWIDTH,
                                       SETUPOFFSETX + position.x, SETUPOFFSETY + position.y);
    self.fromIso = CGAffineTransformInvert(self.toIso);
}

/* findTile - Find the tile located at an absolute position
 * (CGPoint)position    - input absolute position
 * (bool)absPos         - if the position passed in was absolute or board position
 * return               - tile located at the absolute position
 */
- (SetupTile *) findTile:(CGPoint)position absPos:(bool)absPos
{
    int         tileX;
    int         tileY;
    SetupTile  *tile;
    // Convert touch location to a tile location

    if (absPos)
        position = CGPointApplyAffineTransform(position, self.fromIso);

    tileX = (int)floor(position.x);
    tileY = (int)floor(position.y);
    if ( tileY < SETUPMAPWIDTH ) {
        if ( ![self isValidTile:ccp(tileX,tileY)] )
        {
            NSLog(@">[MYWARN]    The tile [%d,%d] is out of bounds", tileX, tileY);
            return nil;
        }
        tile = [[self.board objectAtIndex:tileX] objectAtIndex:tileY];
    }
    else if ( tileY >= SETUPMAPWIDTH && tileY < SETUPSIDEMAPWIDTH + SETUPMAPWIDTH ) {
        tile = [[self.sideBoard objectAtIndex:tileX] objectAtIndex:tileY - SETUPMAPWIDTH];
    }

    return tile;
}

- (void) viewUnitsForTag:(NSString *)tag
{
    NSLog(@">[MYLOG]    viewUnitsForTag Finding for tag %@",tag);
    int index = -1;
    NSMutableArray *list = [NSMutableArray array];
    for ( NSString *string in unitTags ) {
        if ( ![string caseInsensitiveCompare:tag] ) {
            NSLog(@"%@ is the same as %@",tag,string);
            index = [unitTags indexOfObject:string];
            break;
        }
    }
    if ( index != -1 ) {
        NSLog(@"found index %d",index);
        [self clearSideBoard];
        // Find the targets
        for ( int i = index * LASTUNIT; i < (index+1) * LASTUNIT; i++ ) {
            if ( unitsByTag[i] != 0 ) {
                NSLog(@"<><><><> going to add %d",unitsByTag[i]);
                [list addObject:[NSNumber numberWithInt:unitsByTag[i]]];
            } else {
                NSLog(@"><><><>< did not add %d",unitsByTag[i]);
            }
        }
        // go through unit list
        for ( UnitObj *obj in self.unitList ) {
            NSLog(@"<><><><> Checking to add %@",obj);
            if ( [list containsObject:[NSNumber numberWithInt:obj.type]] ) {
                NSLog(@"<><><><> going to add %@",obj);
                [self addUnitWithObj:obj];
            }
        }
    } else {
        return ;
    }
    [self printBoard];
}

- (BOOL) addUnitWithObj:(UnitObj *)obj
{
    NSLog(@">[MYLOG]    addUnitWithObj got:\n%@",obj);
    SetupUnit *unit = [SetupUnit setupUnitWithObj:obj];
    SetupTile *tile;
    tile = [self findTile:[self nextEmptySpot] absPos:NO];
    tile.unit = unit;
    // Upload visually
    [self.delegate loadTile:tile];
    return YES;
}

- (BOOL) clearSideBoard
{
    for ( int k = 0; k < SETUPSIDEMAPWIDTH; k++ ) {
        for ( int i = 0; i < SETUPMAPLENGTH; i++ ) {
            SetupTile *tile = [[self.sideBoard objectAtIndex:i] objectAtIndex:k];
            if ( tile != nil && tile.isOccupied ) {
                if ( [self.delegate removeTile:tile] ) tile.unit = nil;
            }
        }
    }
    NSLog(@">[CHECK THIS AT THE END]");
    return YES;
}

- (CGPoint) nextEmptySpot
{
    for ( int k = 0; k < SETUPSIDEMAPWIDTH; k++ ) {
        for ( int i = 0; i < SETUPMAPLENGTH; i++ ) {
            SetupTile *tile = [[self.sideBoard objectAtIndex:i] objectAtIndex:k];
            if ( [tile isOccupied] ) continue;
            else return ccp(i,k+SETUPMAPWIDTH);
        }
    }
    NSAssert(NO, @">[FATAL] RAN OUT OF EMPTY SPACE?");
    return CGPointZero;
}

/* findBoardPos - Find the board position with an absolute position
 * (CGPoint)position    - input absolute position
 * return               - board position
 */
- (CGPoint) findBrdPos:(CGPoint)position
{
    CGPoint ret = CGPointApplyAffineTransform(position, self.fromIso);
    ret = ccp(floor(ret.x), floor(ret.y));
    return ret;
}

/* findBoardPos - Find the position of the absolute position with a board position
 * (CGPoint)position    - input board-position
 * return               - absolute position
 */
- (CGPoint) findAbsPos:(CGPoint)position
{
    
    CGPoint ret = CGPointApplyAffineTransform(position, self.toIso);
    ret = ccp(ret.x - currentLayerPos.x,
              ret.y + HALFWIDTH - currentLayerPos.y);
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
        (!(i && k) && i < 2 && k < 2) )
        return 0;
    return 1;
}

- (BOOL) move:(SetupTile *)tile to:(SetupTile *)target;
{
    NSLog(@">[MYLOG]    Entering SetupBrain::move");
    // Check logic
    if ( target == nil )
        return NO;
    
    if ( [target isEqual:tile] ) {
        return NO;
    }
    
    if ( target.isReserve && tile.isReserve ) {
        NSLog(@">[MYLOG]        Reserve to reserve");
        return NO;
        
    } else if ( target.isReserve && !tile.isReserve ) {
        NSLog(@">[MYLOG]        Removed unit %@ from setup",tile.unit);
        tile.unit.direction = SW;
        [[[UserSingleton get] units] addObject:tile.unit.obj];
        if ( ![[[UserSingleton get] units] containsObject:tile.unit.obj] )
            NSLog(@"<><><><><>WTF");
        
        SetupTile *newTarget = [self findTile:[self nextEmptySpot] absPos:NO];
        newTarget.unit = tile.unit;
        tile.unit = nil;
        [self.delegate reorderTile:target];
        target.unit.sprite.position = [self findAbsPos:target.boardPos];
        return YES;
        
    } else if ( !target.isReserve && tile.isReserve ) {
        NSLog(@">[MYLOG]        Added unit %@ to setup",tile.unit);
        tile.unit.direction = NE;
        [[[UserSingleton get] units] removeObject:tile.unit.obj];
        if ( [[[UserSingleton get] units] containsObject:tile.unit.obj] )
            NSLog(@"<><><><><>WTF");
        
        target.unit = tile.unit;
        tile.unit = nil;
        [self.delegate reorderTile:target];
        target.unit.sprite.position = [self findAbsPos:target.boardPos];
        return YES;
    } else {
        NSLog(@">[MYLOG]        No change in setup list, %@ %@",tile,target);
        if ( ![target isEqual:tile] ) {
            target.unit = tile.unit;
            tile.unit = nil;
            [self.delegate reorderTile:target];
            target.unit.sprite.position = [self findAbsPos:target.boardPos];
            return YES;
        } else {
            return NO;
        }
    }
}

- (bool) saveSetup
{
    CCLOG(@"MYLOG:  SetupLayer::savePressed Saving configuration");
    // The array to be saved
    int count = 0;
    int value = 0;
    SFSArray *array = [SFSArray newInstance];
    for (int i = 0; i < SETUPMAPLENGTH; i++) {
        for (int k = 0; k < SETUPMAPWIDTH; k++) {
            // Find the tile
            SetupTile *tile = [[self.board objectAtIndex:i] objectAtIndex:k];
            if ( ![tile isKindOfClass:[NSNull class]] && tile.unit != nil )
            {
                count++;
                value += [tile.unit getValue];
                [tile.unit.obj setPosition:ccp(i,k)];
                [array addClass:tile.unit.obj];
            }
        }
    }
    return [[UserSingleton get] saveSetup:array unitCount:count unitValue:value];
}

- (void) printBoard
{
    CCLOG(@"    *******************************");
    for ( int i = SETUPMAPLENGTH - 1; i >= 0 ; i-- )
    {
        NSMutableString *current = [NSMutableString string];
        for ( int k = 0; k < SETUPMAPWIDTH ; k++ )
        {
            id temp = [[self.board objectAtIndex:i] objectAtIndex:k];
            if ( [temp isKindOfClass:[NSNull class]] )
                [current appendFormat:@"%@ ", @"X"];
            else
                if (((SetupTile *)temp).unit != nil)
                    [current appendFormat:@"%d ", ((SetupTile *)temp).unit.obj.type];
                else
                    [current appendFormat:@". "];
        }
        [current appendFormat:@" ** "];
        for ( int k = 0; k < SETUPSIDEMAPWIDTH; k++ )
        {
            id temp = [[self.sideBoard objectAtIndex:i] objectAtIndex:k];
            if ( [temp isKindOfClass:[NSNull class]] )
                [current appendFormat:@"%@ ", @"X"];
            else
                if (((SetupTile *)temp).unit != nil)
                    [current appendFormat:@"%d ", ((SetupTile *)temp).unit.obj.type];
                else
                    [current appendFormat:@". "];
        }

        CCLOG(@"    %@", current);
    }
    CCLOG(@"    *******************************");
}
@end
