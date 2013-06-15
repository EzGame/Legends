//
//  BattleBrain.m
//  Legend
//
//  Created by David Zhang on 2013-04-22.
//
//

#import "BattleBrain.h"
@interface BattleBrain ()

- (void)        constructPathAndStartAnimationFromStep:(ShortestPathStep *)step
                                                   for:(Tile *)tile;

- (void)        insertInOpenSteps:(ShortestPathStep *)step
                             with:(Tile *)tile;

- (int)         computeHScoreFromCoord:(CGPoint)fromCoord
                               toCoord:(CGPoint)toCoord;

- (NSArray *)   walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;

@end

@implementation BattleBrain

@synthesize board = _board;
@synthesize delegate = _delegate;

- (id) initWithMap:(CCTMXLayer *) map
{
    self = [super init];
    if (self)
    {
        // Matrices for conversion from cartesian to isometric and vice versa.
        toIso = CGAffineTransformMake(-HALFLENGTH, HALFWIDTH, HALFLENGTH, HALFWIDTH, OFFSETX, OFFSETY);
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
                  [NSMutableArray array], nil];
        
        // Populating board
        for ( int i = 0 ; i < MAPLENGTH ; i++ ) {
            for ( int k = 0 ; k < MAPWIDTH ; k++ ) {
                
                if ( ![self isValidTile:ccp(i,k)] ) {
                    [[self.board objectAtIndex:i] addObject:
                     [Tile invalidTileWithPosition:ccp(i,k) absPos:[self findAbsPos:ccp(i,k)]]];
                    
                } else {
                    [[self.board objectAtIndex:i] addObject:
                     [Tile tileWithPosition:ccp(i,k) absPos:[self findAbsPos:ccp(i,k)]]];
                    
                }
            }
        }
    }
    return self;
}

- (id) findType:(int)type owned:(BOOL)side;
{
    if (type == MINOTAUR) {
        return [[Minotaur alloc] initMinotaurFor:side];
        
    } else if ( type == GORGON ) {
        return [[Gorgon alloc] initGorgonFor:side];
        
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN BATTLEBRAIN:FINDTYPE %d", type);
        return nil;
        
    }
}

- (void) restoreSetup
{
    // Populating pieces
    for ( int i = 0; i < [[[UserSingleton get] pieces] count]; i++ )
    {
        // The stored string is in the form of @type[@x,@y]
        NSString *string = [[[UserSingleton get] pieces] objectAtIndex:i];
        NSArray *tokens;
        int type, x = -1, y = -1;
        if ( string != nil )
        {
            tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[,]"]];
            type = [(NSString *)[tokens objectAtIndex:0] integerValue];
            x = [(NSString *)[tokens objectAtIndex:1] integerValue];
            y = [(NSString *)[tokens objectAtIndex:2] integerValue];
            if ( y == 5 ) continue;
        }
        Unit *unit = [self findType:type owned:YES];
        
        // Finding tile
        Tile *tile = [self findTile:ccp(x,y) absPos:false];
        tile.unit = unit;
        tile.isOccupied = true;
        tile.isOwned = true;
        
        // Upload visually
        [self.delegate loadTile:tile];
    }
    
    // Populating opponent pieces
    for ( int i = 0; i < [[[UserSingleton get] opPieces] count]; i++ )
    {
        // The stored string is in the form of @type[@x,@y]
        NSString *string = [[[UserSingleton get] opPieces] objectAtIndex:i];
        NSArray *tokens;
        int type, x = -1, y = -1;
        if ( string != nil )
        {
            tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[,]"]];
            type = [(NSString *)[tokens objectAtIndex:0] integerValue];
            x = 9 - [(NSString *)[tokens objectAtIndex:1] integerValue];
            y = 9 - [(NSString *)[tokens objectAtIndex:2] integerValue];
            if ( y == 5 ) continue;
        }
        Unit *unit = [self findType:type owned:NO];
        
        // Finding tile, mirroring
        Tile *tile = [self findTile:ccp(x,y) absPos:false];
        tile.unit = unit;
        tile.isOccupied = true;
        tile.isOwned = false;
        
        // Upload visually
        [self.delegate loadTile:tile];
    }
}

- (Tile *) doSelect:(CGPoint)position
{
    Tile * tile = [self findTile:position absPos:true];
    if ( [tile unit] == nil )
    {
        CCLOG(@">[Error]    The position did not yield a proper selection");
        return nil;
    }
    return tile;
}

- (BOOL) doAction:(int)action for:(Tile *)tile to:(CGPoint)finish dmg:(NSInteger *)dmg
{
    CCLOG(@">[MYLOG]    Entering BattleBrain::doAction for %d", action);
    BOOL ret = YES;
    
    //check for errs
    if ( action == MOVE ) {
        ret = [self moveToward:finish with:tile opp:NO];
        
    } else if ( action == ATTK ) {
        ret = [self attackToward:finish with:tile dmg:dmg opp:NO];
        
    } else if ( action == GORGON_SHOOT ) {
        ret = [self shootToward:finish with:tile dmg:dmg opp:NO];
        
    } else if ( action == GORGON_FREEZE ) {
        ret = [self freezeToward:finish with:tile opp:NO];
        
    } else if ( action == DEFN ) {
        [[tile unit] action:action at:finish];
        
    } else {
        NSAssert(false, @">[FATAL]  BATTLEBRAIN:DOACTION CAN NOT HANDLE ACTION %d", action);
        
    }
    
    CCLOG(@">[MYLOG]    BattleBrain::doAction returned with %d", ret);
    [self printBoard];
    return ret;
}

- (BOOL) doOppAction:(SFSObject *)data
{
    int xPos = [data getInt:@"xPos"];
    int yPos = [data getInt:@"yPos"];
    int action = [data getInt:@"action"];
    int effect = [data getInt:@"effect"];
    int xBoard = [data getInt:@"xBoard"];
    int yBoard = [data getInt:@"yBoard"];
    
    // Invert the positions
    CGPoint boardPos = ccp(9 - xBoard, 9 - yBoard);
    CGPoint movePos = ccp(xPos, yPos);
    movePos = [self findBrdPos:movePos];
    movePos = ccpSub(ccp(9,9), movePos);

    NSLog(@"Received package %d from [%d,%d] to [%d,%d] for %d",
          action, (int)boardPos.x, (int)boardPos.y, (int)movePos.x, (int)movePos.y, effect);
    Tile *tile = [self findTile:boardPos absPos:false];
    
    if ( action == MOVE ) {
        CCLOG(@"    Opponent MOVED to %d,%d",(int)movePos.x, (int)movePos.y);
        [self moveToward:[self findAbsPos:movePos] with:tile opp:YES];
        
    } else if ( action == ATTK ) {
        CCLOG(@"    Opponent ATTK");
        [self attackToward:[self findAbsPos:movePos] with:tile dmg:&effect opp:YES];
        
    } else if ( action == GORGON_SHOOT ) {
        NSLog(@"    Opponent GORGON_SHOOT");
        [self shootToward:[self findAbsPos:movePos] with:tile dmg:&effect opp:YES];
        
    } else if ( action == GORGON_FREEZE ) {
        NSLog(@"    Opponent GORGON_FREEZE");
        [self freezeToward:[self findAbsPos:movePos] with:tile opp:YES];
     
    } else if ( action == DEFN ) {
        CCLOG(@"    Opponent DEFN");
        [[tile unit] action:DEFN at:[self findAbsPos:movePos]];
        
    } else {
        NSAssert(false, @">[FATAL]  BATTLEBRAIN:DOOPPACTION CAN NOT HANDLE ACTION %d", action);
        
    }
    return 0;
}

- (NSArray *) findActionTiles:(Tile *)tile action:(int)action
{
    NSLog(@">[MYLOG]   findActionTiles %d",action);
    if (action == MOVE) {
        return [self findMoveTiles:tile.boardPos for:tile.unit->moveArea];
        
    } else if (action == ATTK) {
        return [[tile unit] getAttkArea:tile.boardPos];
        
    } else if ( action == GORGON_SHOOT ) {
        NSLog(@"shit son,");
        return [(Gorgon *)[tile unit] getShootArea:tile.boardPos];
        
    } else if ( action == GORGON_FREEZE ) {
        return [(Gorgon *)[tile unit] getFreezeArea:tile.boardPos];
        
    } else if (action == DEFN) {
        return nil;
        
    } else {
        NSAssert(false, @">[FATAL]  BATTLEBRAIN:FINDACTIONTILES CAN NOT HANDLE ACTION %d", action);
        return nil;
        
    }
}

- (NSArray *) findMoveTiles:(CGPoint)position for:(int)area;
{
    // THIS NEEDS OPTIMIZATION
    // Holding array
    NSMutableArray *array = [NSMutableArray array];
    
    CGPoint p = ccp(position.x - 1, position.y);
    if ( [self isValidTile:p] && area != 0 )
        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];

    p = ccp(position.x, position.y - 1);
    if ( [self isValidTile:p] && area != 0 )
        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];

    p = ccp(position.x + 1, position.y);
    if ( [self isValidTile:p] && area != 0 )
        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];

    p = ccp(position.x, position.y + 1);
    if ( [self isValidTile:p] && area != 0 )
        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];
    
    // Add ourself only if we are empty
    if ( [self isValidTile:position] && ![self isOccupiedTile:position])
        if ( ![array containsObject:[NSValue valueWithCGPoint:position]] )
            [array addObject:[NSValue valueWithCGPoint:position]];
    
    return [NSArray arrayWithArray:array];
}

- (void) setCurrentLayerPos:(CGPoint)position
{
    currentLayerPos = position;
    toIso = CGAffineTransformMake(-HALFLENGTH, HALFWIDTH,
                                  HALFLENGTH, HALFWIDTH,
                                  OFFSETX + position.x, OFFSETY + position.y);
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

/* findBoardPos - Find the position of the absolute position with a board position
 * (CGPoint)position    - input board-position
 * return               - absolute position
 */
- (CGPoint) findAbsPos:(CGPoint)position
{
    CGPoint ret = CGPointApplyAffineTransform(position, toIso);
    ret = ccp(ret.x,ret.y + HALFWIDTH);
    return ret;
}

- (BOOL) isValidTile:(CGPoint)position
{
    int i = position.x;
    int k = position.y;
    if ( i < 0 || i > 9 || k < 0 || k > 9 )
        return false;
    // don't fuck with this if
    if ( (!(abs(i-9) && abs(k-9)) && i-9 > -2 && k-9 > -2)  ||
        (!(abs(i-9) && k) && i-9 > -2 && k < 2) ||
        (!(i && abs(k-9)) && k-9 > -2 && i < 2) ||
        (!(i && k) && i < 2 && k < 2) )
        return false;
    return true;
}

- (BOOL) isOccupiedTile:(CGPoint)position
{
    return [[[[self board] objectAtIndex:position.x] objectAtIndex:position.y] isOccupied];
}

- (BOOL) isOwnedTile:(CGPoint)position
{
    return [[[[self board] objectAtIndex:position.x] objectAtIndex:position.y] isOwned];
}

- (void) killtile:(CGPoint)position
{
    Tile *tile = [self findTile:position absPos:true];
    NSLog(@">[MYLOG]    Entering BattleBrain:killtile for %@",tile);
    
    [tile.unit setDelegate:nil];
    [tile setUnit:nil];
    [tile setIsOccupied:false];
    [tile setIsOwned:false];
}

- (void) printBoard
{
    CCLOG(@"    ********TYPE*******************OWNED********");
    for ( int i = MAPLENGTH - 1; i >= 0 ; i-- )
    {
        NSMutableString *current = [NSMutableString string];
        for ( int k = 0; k < MAPWIDTH ; k++ )
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
        [current appendString:@"*** "];
        
        for ( int k = 0; k < MAPWIDTH; k++ )
        {
            Tile *temp = [[[self board] objectAtIndex:i] objectAtIndex:k];
            if ( temp.status == INVALID )
                [current appendString:@"X "];
            else if ( temp.isOccupied && temp.isOwned )
                [current appendString:@"O "];
            else if ( temp.isOccupied && !temp.isOwned )
                [current appendString:@"E "];
            else if ( !temp.isOccupied && temp.isOwned )
                [current appendString:@"_ "];
            else
                [current appendString:@". "];
        }
        CCLOG(@"    %@", current);
    }
    CCLOG(@"    *******************************************");
}

- (CGPoint) bresenham:(CGPoint)start to:(CGPoint)end
{
    // purpose is to print out the path from start to the next occupied tile or the end.
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int sx = ( start.x < end.x ) ? 1 : -1;
    int sy = ( start.y < end.y ) ? 1 : -1;
    int err = dx - dy;
    do {
        if ( start.x == end.x && start.y == end.y )
            return start;
        int err2 = err * 2;
        if ( err2 > -dy ) {
            err = err - dy;
            start.x = start.x + sx;
        }
        if ( start.x == end.x && start.y == end.y )
            return start;
        if ( err2 < dx ) {
            err = err + dx;
            start.y = start.y + sy;
        }
    } while ( [self isValidTile:start] && ![self isOccupiedTile:start] ) ;
    return start;
}

- (NSMutableArray *) bresenhamList:(CGPoint)start to:(CGPoint)end inclusive:(BOOL)inc
{
    // purpose is to print out the path from start to the next occupied tile or the end.
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int sx = ( start.x < end.x ) ? 1 : -1;
    int sy = ( start.y < end.y ) ? 1 : -1;
    int err = dx - dy;
    NSMutableArray *ret = [NSMutableArray array];
    
    if ( inc ) [ret addObject:[NSValue valueWithCGPoint:start]]; // start
    do {
        if ( start.x == end.x && start.y == end.y )
            break;
        int err2 = err * 2;
        if ( err2 > -dy ) {
            err = err - dy;
            start.x = start.x + sx;
        }
        if ( start.x == end.x && start.y == end.y ) {
            if ( inc ) [ret addObject:[NSValue valueWithCGPoint:start]]; // end
            break;
        }
        if ( err2 < dx ) {
            err = err + dx;
            start.y = start.y + sy;
        }
        [ret addObject:[NSValue valueWithCGPoint:start]]; // everything else
    } while ( [self isValidTile:start] && [self isOccupiedTile:start] ) ;
    
    return ret;
}

- (CGPoint) fixProjectile:(CGPoint)destination toLineStart:(CGPoint)start end:(CGPoint)end
{
    // Line A - P
    CGPoint startToDestination = ccp( destination.x - start.x , destination.y - start.y );
    // Line A - B
    CGPoint startToEnd = ccp( end.x - start.x, end.y - start.y );
    // Magnitude of A - B
    float startToEndSq = pow(startToEnd.x, 2) + pow(startToEnd.y, 2);
    // Dot product of A - B . A - P
    float dotProduct = startToDestination.x * startToEnd.x + startToDestination.y + startToEnd.y;
    // Normalized distance
    float t = dotProduct/startToEndSq;
    // SHIT SON EZ GAME
    CGPoint ret = ccp(start.x + startToEnd.x * t, start.y + startToEnd.y * t);
    NSLog(@">[MYLOG]        Projectile fix to %f,%f", ret.x, ret.y);
    return ret;
}

// Action functions
- (BOOL) freezeToward:(CGPoint)position with:(Tile *)tile opp:(BOOL)opp
{
    // Find the list of tiles in line of sight, set target to the last one of the list
    NSMutableArray *bresenhamList = [self bresenhamList:tile.boardPos to:[self findBrdPos:position] inclusive:YES];
    Tile *target = [self findTile:[[bresenhamList lastObject] CGPointValue] absPos:NO];
    
    // Add attacker to notification list of the list
    for ( NSValue *v in bresenhamList ) {
        CGPoint location = [v CGPointValue];
        Tile *temp = [self findTile:location absPos:NO];
        [temp.notification addObject:tile.unit];
    }
    
    // Run action + Freeze enemy
    [[tile unit] action:GORGON_FREEZE at:[self findAbsPos:target.boardPos]];
    [(Gorgon *)[tile unit] freeze:target.unit];
    
    // Toggle Freeze
    [target.unit toggleState:ISFROZEN];
    return YES;
}

- (BOOL) shootToward:(CGPoint)position with:(Tile *)tile dmg:(NSInteger *)dmg opp:(BOOL)opp
{
    CGPoint bresenham = [self bresenham:tile.boardPos to:[self findBrdPos:position]];

    Tile *target = [self findTile:bresenham absPos:NO];
    CGPoint placement = [self fixProjectile:[self findAbsPos:bresenham]
                                toLineStart:[self findAbsPos:tile.boardPos] end:position];
    [[tile unit] action:GORGON_SHOOT at:placement];
    
    if ( !opp ) *dmg = [[target unit] calculate:tile.unit->attack];
    [target.unit take:*dmg];
    
    [self.delegate displayCombatMessage:[NSString stringWithFormat:@"%d",*dmg]
                             atPosition:target.absPos with:ccRED];
    return YES;
}

- (BOOL) attackToward:(CGPoint)position with:(Tile *)tile dmg:(NSInteger *)dmg opp:(BOOL)opp
{
    Tile *target = [self findTile:position absPos:YES];
    [[tile unit] action:ATTK at:position];
    
    if ( !opp ) *dmg = [target.unit calculate:tile.unit->attack];
    [target.unit take:*dmg];
    
    [self.delegate displayCombatMessage:[NSString stringWithFormat:@"%d",*dmg]
                             atPosition:target.absPos with:ccRED];
    return YES;
}

- (BOOL) moveToward:(CGPoint)position with:(Tile *)tile opp:(BOOL)opp
{
    // Find the board tiles
    Tile *end = [self findTile:position absPos:true];
    
    // check if we're already there
    if ( CGPointEqualToPoint ([end boardPos], [tile boardPos]) )
    {
        CCLOG(@"    You're already there!");
        return NO;
    }
    
    // check if destination is occupied
    if ( [end isOccupied] )
    {
        CCLOG(@"    Destination is occupied!");
        return NO;
    }
    
    CCLOG(@"    From: %@", NSStringFromCGPoint([tile boardPos]));
    CCLOG(@"    To: %@", NSStringFromCGPoint([end boardPos]));
    
    [[tile unit] setSpOpenSteps: [[NSMutableArray alloc] init]];
    [[tile unit] setSpClosedSteps: [[NSMutableArray alloc] init]];
    
    // Start by adding the from position to the open list
    [self insertInOpenSteps:[[ShortestPathStep alloc] initWithPosition:[tile boardPos]] with:tile];
    
    do
    {
        // Get the lowest F cost step
        // Because the list is ordered, the first step is always the one with the lowest F cost
        ShortestPathStep *currentStep = [[[tile unit] spOpenSteps] objectAtIndex:0];
        
        // Add the current step to the closed set
        [[[tile unit] spClosedSteps] addObject:currentStep];
        
        // Remove it from the open list
        // Note that if we wanted to first removing from the open list, care should be taken to the memory
        [[[tile unit] spOpenSteps] removeObjectAtIndex:0];
        
        // If the currentStep is the desired tile coordinate, we are done!
        if (CGPointEqualToPoint(currentStep.position, [end boardPos])) {
            [self constructPathAndStartAnimationFromStep:currentStep for:tile];
            [[tile unit] setSpOpenSteps: nil]; // Set to nil to release unused memory
            [[tile unit] setSpClosedSteps: nil]; // Set to nil to release unused memory
            break;
            
        } else {
            int count = 0;
            ShortestPathStep *curStepPtr = currentStep;
            do {
                count ++;
                curStepPtr = curStepPtr.parent;
            } while (curStepPtr != nil);
            
            if ( count > [tile unit]->moveArea ) {
                CCLOG(@"    Tile is too far away");
                break;
            }
        }
        
        // Get the adjacent tiles coord of the current step
        NSArray *adjSteps = [self walkableAdjacentTilesCoordForTileCoord:currentStep.position
                                                                     opp:opp];
        
        for (NSValue *v in adjSteps)
        {
            ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
            
            // Check if the step isn't already in the closed set
            if ([[[tile unit] spClosedSteps] containsObject:step]) {
                 // Must releasing it to not leaking memory ;-)
                continue; // Ignore it
            }
            
            // Compute the cost from the current step to that step
            int moveCost = 1;
            
            // Check if the step is already in the open list
            NSUInteger index = [[[tile unit] spOpenSteps] indexOfObject:step];
            
            if (index == NSNotFound) { // Not on the open list, so add it
                
                // Set the current step as the parent
                step.parent = currentStep;
                
                // The G score is equal to the parent G score + the cost to move from the parent to it
                step.gScore = currentStep.gScore + moveCost;
                
                // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                step.hScore = [self computeHScoreFromCoord:step.position toCoord:[end boardPos]];
                
                // Adding it with the function which is preserving the list ordered by F score
                [self insertInOpenSteps:step with:tile];
                
                // Done, now release the step
                
            } else { // Already in the open list
                
                 // Release the freshly created one
                step = [[[tile unit] spOpenSteps] objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
                
                // Check to see if the G score for that step is lower if we use the current step to get there
                if ((currentStep.gScore + moveCost) < step.gScore) {
                    
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;
                    
                    // Because the G Score has changed, the F score may have changed too
                    // So to keep the open list ordered we have to remove the step, and re-insert it with
                    // the insert function which is preserving the list ordered by F score
                    
                    // We have to retain it before removing it from the list
                    
                    // Now we can removing it from the list without be afraid that it can be released
                    [[[tile unit] spOpenSteps] removeObjectAtIndex:index];
                    
                    // Re-insert it with the function which is preserving the list ordered by F score
                    [self insertInOpenSteps:step with:tile];
                    
                    // Now we can release it because the oredered list retain it
                }
            }
        }
    } while ([[[tile unit] spOpenSteps] count] > 0 );
    
    if ( [[tile unit] shortestPath] == nil ) {
        CCLOG(@"    Could not find path");
        return NO;
    } else {
        [end setUnit:[tile unit]];
        [end setIsOccupied:true];
        [end setIsOwned:true];
        
        [tile setUnit:nil];
        [tile setIsOccupied:false];
        [tile setIsOwned:false];
        [self.delegate unitDidMoveTo:end];
        return YES;
    }
}

// A* helper functions
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step for:(Tile *)tile
{
	[[tile unit] setShortestPath: [NSMutableArray array]];
    
	do
    {
		if ( step.parent != nil )
        { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
            [step setPosition:ccpSub([self findAbsPos:step.position], currentLayerPos)];
			[[[tile unit] shortestPath] insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
		}
		step = step.parent; // Go backward
	} while (step != nil); // Until there is no more parents
    
    for ( ShortestPathStep *s in [[tile unit] shortestPath] )
    {
        CCLOG(@"    %@", s);
    }
    
    [[tile unit] action:MOVE at:CGPointZero];
}

- (void)insertInOpenSteps:(ShortestPathStep *)step with:(Tile *)tile
{
	int stepFScore = [step fScore]; // Compute the step's F score
	int count = [[[tile unit] spOpenSteps] count];
    int i = 0;
	for (; i < count; i++)
    {
		if ( stepFScore <= [[[[tile unit] spOpenSteps] objectAtIndex:i] fScore])
        { // If the step's F score is lower or equals to the step at index i
			// Then we found the index at which we have to insert the new step
            // Basically we want the list sorted by F score
			break;
		}
	}
	// Insert the new step at the determined index to preserve the F score ordering
	[[[tile unit] spOpenSteps] insertObject:step atIndex:i];
}

- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
{
	// Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
	// final desired step from the current step, ignoring any obstacles that may be in the way
	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord opp:(BOOL)opp
{
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
    
	// SW
	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
	if ([self isValidTile:p] &&
        (![self isOccupiedTile:p] ||
         ( [self isOwnedTile:p] ^ opp ) ) ) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
	// NW
	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
	if ([self isValidTile:p] &&
        (![self isOccupiedTile:p] ||
         ( [self isOwnedTile:p] ^ opp ) ) ) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
	// NE
	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
	if ([self isValidTile:p] &&
        (![self isOccupiedTile:p] ||
         ( [self isOwnedTile:p] ^ opp ) ) ) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
	// SE
	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
	if ([self isValidTile:p] &&
        (![self isOccupiedTile:p] ||
         ( [self isOwnedTile:p] ^ opp ) ) ) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
	return [NSArray arrayWithArray:tmp];
}
@end
