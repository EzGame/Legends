////
////  BattleBrain.m
////  Legend
////
////  Created by David Zhang on 2013-04-22.
////
////

#import "BattleBrain.h"
@interface BattleBrain()
@property (nonatomic, weak)             Unit *currentUnitPtr;
@property (nonatomic, weak)        UnitSkill *currentActionPtr;
@property (nonatomic)                CGPoint currentHighlightPos;
@property (nonatomic, strong) NSMutableArray *currentHighlightedTiles;
@property (nonatomic)              TurnState turnState;
@end

@implementation BattleBrain
#pragma mark - Setters n Getters
- (void) setCurrentLayerPosition:(CGPoint)currentLayerPosition
{
    self.toScn = CGAffineTransformMake(-GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                                       GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                                       GAMETILEOFFSETX + currentLayerPosition.x,
                                                       GAMETILEOFFSETY + currentLayerPosition.y);
    self.toIso = CGAffineTransformInvert(self.toScn);
    _currentLayerPosition = currentLayerPosition;
}

- (void) setTurnState:(TurnState)turnState
{
    if ( turnState == TurnStateA ) {
        NSLog(@"==================TURN STATE A: Make a selection==================");
        [self.currentUnitPtr closeMenu];
        self.currentUnitPtr = nil;
        self.currentActionPtr = nil;
    } else if ( turnState == TurnStateB ) {
        NSLog(@"==================TURN STATE B: Highlight action==================");
        [self.currentUnitPtr openMenu];
        self.currentActionPtr = nil;
    } else if ( turnState == TurnStateC ) {
        NSLog(@"==================TURN STATE C: Confirm the action================");
        
    } else if ( turnState == TurnStateD ) {
        NSLog(@"==================TURN STATE D: Perform an action=================");
        
    } else if ( turnState == TurnStateX ) {
        NSLog(@"==================TURN STATE X: WTF is this again?================");
        
    }
    _turnState = turnState;
}

- (void) setCurrentUnitPtr:(Unit *)currentUnitPtr
{
    if ( currentUnitPtr )
        [currentUnitPtr action:ActionIdle targets:nil];
    else
        [_currentUnitPtr action:ActionStop targets:nil];
    
    _currentUnitPtr = currentUnitPtr;
}









/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Init n Shit
- (id) initWithMap:(CCTMXLayer *)tmxLayer delegate:(id)delegate
{
    self = [super init];
    if ( self ) {
        // Set delegate
        _delegate = delegate;
        
        // Create gameboard
        _gameBoard = [[NSArray alloc] initWithObjects:
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
        for ( int i = 0 ; i < GAMEMAPWIDTH ; i++ ) {
            for ( int k = 0 ; k < GAMEMAPHEIGHT ; k++ ) {
                CGPoint pos = CGPointMake(i, k);
                Tile *tile = [[Tile alloc] init];
                if ( [self isValidPos:pos] ) {
                    tile.boardPos = pos;
                    tile.sprite = [tmxLayer tileAt:[self getInvertedPos:pos]];
                }
                [[_gameBoard objectAtIndex:i] addObject:tile];
            }
        }
        
        // Setting isometric - world transforms
        _toWld = CGAffineTransformMake( -GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                         GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                         GAMETILEOFFSETX, GAMETILEOFFSETY);
        _toScn = _toWld;
        _toIso = CGAffineTransformInvert(_toWld);
        
        // Fill board with player owned units
        [self initSetup];
    }
    return self;
}

- (void) initSetup
{
    MatchObject *matchObj = [self.delegate battleBrainNeedsMatchObj];
    
    // Populating our pieces
    for ( int i = 0; i < [matchObj.mySetup size]; i++ )
    {
        // create unit
        UnitObject *obj = [matchObj.oppSetup getElementAt:i];
        Unit *unit = [self createUnitWith:obj isOwned:YES];
        unit.delegate = self;
        
        // get tile
        Tile *tilePtr = [self getTileWithPos:obj.position];
        tilePtr.unit = unit;
        tilePtr.unit.position = [self getWorldPosFromIso:tilePtr.boardPos];
        
        // Upload visually
        [self.delegate battleBrainDidLoadUnitAt:tilePtr];
    }

    // Populating opponent pieces
    for ( int i = 0; i < [matchObj.oppSetup size]; i++ )
    {
        // create unit
        UnitObject *obj = [matchObj.oppSetup getElementAt:i];
        Unit *unit = [self createUnitWith:obj isOwned:NO];
        unit.delegate = self;
        
        // get tile
        Tile *tilePtr = [self getTileWithPos:[self getInvertedPos:obj.position]];
        tilePtr.unit = unit;
        tilePtr.unit.position = [self getWorldPosFromIso:tilePtr.boardPos];

        // Upload visually
        [self.delegate battleBrainDidLoadUnitAt:tilePtr];
    }
}

- (Unit *) createUnitWith:(UnitObject *)obj isOwned:(BOOL)isOwned
{
    if ( obj.type == UnitTypePriest ) {
        return [Priest priest:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypeWarrior ) {
        return [Warrior warrior:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypeRanger ) {
        return [Ranger ranger:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypeWitch ) {
        return [Witch witch:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypeKnight ) {
        return [Knight knight:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypeBerserker ) {
        return [Berserker berserker:obj isOwned:isOwned];
    } else if ( obj.type == UnitTypePaladin ) {
        return [Paladin paladin:obj isOwned:isOwned];
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN BATTLEBRAIN:FINDTYPE %d", obj.type);
        return nil;
    }
}










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Turn State Machine
- (void) turn_driver:(CGPoint)position
{
    // Turn touch position into board position
    CGPoint brdPos = [self getIsoPosFromScreen:position];
    
    // Find tile at board position
    Tile *tilePtr = [self getTileWithPos:brdPos];
    
    // If selection is outside of board, return to state A
    if ( tilePtr == nil && !CGPointEqualToPoint(position, CGPointFlag) ) {
        self.turnState = TurnStateA;
        return;
    }
    
    if ( self.turnState == TurnStateA ) {
        // Display information of that location
        [self.delegate battleBrainWantsToDisplayInfo:tilePtr.unit];

        // If unit is not owned or nil, return to state A
        if ( ![tilePtr.unit isOwned] ) {
            NSLog(@"<Regress to state A>");
            self.turnState = TurnStateA;
            return;
        }
        
        // set Current Unit Pointer
        self.currentUnitPtr = tilePtr.unit;
        // Advance turn state
        NSLog(@"<Moving to state B>");
        self.turnState = TurnStateB;

    } else if ( self.turnState == TurnStateB ) {
        // If current action was not set, return to state A
        if ( self.currentActionPtr == nil ) {
            NSLog(@"<Regress to state A>");
            self.turnState = TurnStateA;
            return;
        }

        // Save highlight pos and highlight with mode HighlightModeRange
        self.currentHighlightPos = self.currentUnitPtr.boardPos;
        //NSLog(@"B set currentHighlightPos to %@",NSStringFromCGPoint(self.currentHighlightPos));
        [self highlightTilesWithMode:HighlightModeRange];
        
        // Advance turn state
        NSLog(@"<Moving to state C>");
        self.turnState = TurnStateC;
        
    } else if ( self.turnState == TurnStateC ) {
        // If selection is white, return to state B
        if ( [GeneralUtils ccColor3BCompare:tilePtr.sprite.color :ccWHITE] ) {
            // Turn off highlight
            [self highlightTilesWithMode:HighlightModeRangeOff];
            
            NSLog(@"<Regress to state B>");
            self.turnState = TurnStateB;
            return;
        }
        
        // Turn off highlight
        [self highlightTilesWithMode:HighlightModeRangeOff];
        
        // Save highlight pos and highlight with mode HighlightModeEffect
        self.currentHighlightPos = brdPos;
        //NSLog(@"C set currentHighlightPos to %@",NSStringFromCGPoint(self.currentHighlightPos));
        [self highlightTilesWithMode:HighlightModeEffect];
        
        // Advance turn state
        NSLog(@"<Moving to state D>");
        self.turnState = TurnStateD;
        
    } else if ( self.turnState == TurnStateD ) {
        // If selection is not animated, return to state B
        if ( ![tilePtr.sprite numberOfRunningActions] ) {
            // Turn off highlight
            [self highlightTilesWithMode:HighlightModeEffectOff];
            
            NSLog(@"<Regress to state B>");
            self.turnState = TurnStateB;
            return;
        }

        // Save targets
        NSMutableArray *targets = [NSMutableArray array];
        for ( NSValue *v in self.currentHighlightedTiles ) {
            Tile *tilePtr = [self getTileWithPos:[v CGPointValue]];
            CGPoint position = [self getScreenPosFromIso:[v CGPointValue]];
            [targets addObject:(tilePtr.unit) ?
             tilePtr.unit : [NSValue valueWithCGPoint:position]];
        }
        
        // Turn off highlight
        [self highlightTilesWithMode:HighlightModeEffectOff];

        // Perform the action
        [self performAction:self.currentActionPtr
                         to:targets
                         by:self.currentUnitPtr];
        
        // Wait till action is finished
        
    } else if ( self.turnState == TurnStateX ) {
        // display information and stop
        [self.delegate battleBrainWantsToDisplayInfo:tilePtr.unit];
    }
}

- (void) highlightTilesWithMode:(HighlightMode)mode
{
    // Set some variables
    CGPoint centerPos = self.currentHighlightPos;
    ccColor3B color = [GeneralUtils colorFromAction:self.currentActionPtr.type];
    NSMutableArray *area;
    
    if ( mode % 2 ) {
        // The mode is to turn it off, current highlighted must be non nil
        NSAssert(self.currentHighlightedTiles, @"<FATAL> highlightTilesWithMode: self.currentHighlightedTiles nil");
    } else {
        // The mode is to turn it on, current highlighted must be nil
        NSAssert(!self.currentHighlightedTiles, @"<FATAL> highlightTilesWithMode: self.currentHighlightedTiles not nil");
        self.currentHighlightedTiles = [NSMutableArray array];
    }
    
    // Switch between modes
    if ( mode == HighlightModeRange || mode == HighlightModeEffect ) {
        ActionRangeType type = (mode == HighlightModeRange) ?
            self.currentActionPtr.rangeType : self.currentActionPtr.effectType;
        int range = (mode == HighlightModeRange) ?
            self.currentActionPtr.range : self.currentActionPtr.effect;
        NSMutableArray *unshiftedArea = (mode == HighlightModeRange) ?
            self.currentActionPtr.areaOfRange : self.currentActionPtr.areaOfEffect;
        
        switch (type) {
            case RangeNormal:
                area = [self getNormalRange:range at:centerPos flag:NO];
                break;
            case RangeNormalInc:
                area = [self getNormalRange:range at:centerPos flag:YES];
                break;
            case RangeNormalForce:
                area = [self getNormalForcedRange:range at:centerPos flag:NO];
                break;
            case RangeNormalIncForce:
                area = [self getNormalForcedRange:range at:centerPos flag:YES];
                break;
            case RangeOne:
                area = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:centerPos]];
                break;
            case RangePathFind:
                area = [self getPathFindRange:range at:centerPos];
                break;
            case RangeLOS:
                area = [self getLOSRange:range at:centerPos];
                break;
            case RangeAllied:
                area = [self getAllOwnedTiles];
                break;
            case RangeEnemy:
                area = [self getAllEnemyTiles];
                break;
            case RangeUnique:
                area = [self getUniqueArea:unshiftedArea at:centerPos
                                      flag:(mode == HighlightModeEffect)];
                break;
            default:
                NSLog(@"Unknown range??");
                break;
        }
        
    } else if ( mode == HighlightModeRangeOff ) {
        // Copy the current highlights and nil the global pointer
        area = [self.currentHighlightedTiles copy];
        self.currentHighlightedTiles = nil;
        
    } else if ( mode == HighlightModeEffectOff) {
        // Copy the current highlights and nil the global pointer
        area = [self.currentHighlightedTiles copy];
        self.currentHighlightedTiles = nil;
    }
    
    // Do the highlight
    for ( NSValue *v in area ) {
        CGPoint boardPos = [v CGPointValue];
        Tile *tilePtr = [self getTileWithPos:boardPos];
        
        // Do action based on mode
        if ( mode == HighlightModeRange ) {
            // Highlight and add to current
            CCAction *tint = [CCTintTo actionWithDuration:0.2 color:color];
            [tilePtr.sprite runAction:tint];
            [self.currentHighlightedTiles addObject:[NSValue valueWithCGPoint:tilePtr.boardPos]];
       
        } else if ( mode == HighlightModeRangeOff ) {
            // Turn off highlights and turn off BFS flag
            [tilePtr.sprite setColor:ccWHITE];
            tilePtr.touched = NO;
            [self getTileWithPos:self.currentUnitPtr.boardPos].touched = NO;
            
        } else if ( mode == HighlightModeEffect ) {
            // Highlight and add to current
            [GeneralUtils tint:tilePtr.sprite with:color by:50];
            [self.currentHighlightedTiles addObject:[NSValue valueWithCGPoint:tilePtr.boardPos]];
            
        } else if ( mode == HighlightModeEffectOff ) {
            // Turn off highlights
            [tilePtr.sprite setColor:ccWHITE];
            [tilePtr.sprite stopAllActions];
            
        }
    }
}

- (void) performAction:(UnitSkill *)action to:(NSMutableArray *)targets by:(Unit *)unit
{
    // Specific handler for move action for path finding
    if ( action.type == ActionMove ) {
        CGPoint target = [[targets firstObject] CGPointValue];
        [self createPathTo:[self getIsoPosFromScreen:target] For:unit];
        [unit action:action.type targets:nil];
    } else {
        [unit action:action.type targets:targets];
    }
    [self.delegate battleBrainDidPerform:action];
}









/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - A*
- (void) createPathTo:(CGPoint)target For:(Unit *)unit
{
    // Allocate memory
    unit.spOpenSteps = [NSMutableArray array];
    unit.spClosedSteps = [NSMutableArray array];
    unit.shortestPath = [NSMutableArray array];
    
    // Insert the starting location
    [self insertInOpenSteps:[[ShortestPathStep alloc] initWithBoardPos:unit.boardPos] with:unit];
    
    do
    {
        // Get the lowest F cost step
        ShortestPathStep *currentStep = [unit.spOpenSteps firstObject];
        
        // Add the current step to the closed set
        [unit.spClosedSteps addObject:currentStep];
        
        // Remove it from the open list
        [unit.spOpenSteps removeObjectAtIndex:0];
        
        // If the currentStep is the desired tile coordinate, we are done!
        if ( CGPointEqualToPoint(currentStep.boardPos, target) ) {
            [self constructPathFromStep:currentStep for:unit];
            unit.spOpenSteps = nil;
            unit.spClosedSteps = nil;
            break;
        }
        
        // Get the adjacent tiles coord of the current step
        NSMutableArray *adjSteps = [self getEmptyAdjacentPointsAt:currentStep.boardPos flag:NO];
        
        // Loop through sides
        for (NSValue *v in adjSteps)
        {
            ShortestPathStep *step = [[ShortestPathStep alloc] initWithBoardPos:[v CGPointValue]];
            
            // Check if the step isn't already in the closed set
            if ( [unit.spClosedSteps containsObject:step] ) {
                continue;
            }
            
            // Compute the cost from the current step to that step
            int moveCost = 1;
            
            // Check if the step is already in the open list
            NSUInteger index = [unit.spOpenSteps indexOfObject:step];
            if (index == NSNotFound) {
                // Set the current step as the parent
                step.parent = currentStep;
                
                // Calculate G and H score and add
                step.gScore = currentStep.gScore + moveCost;
                step.hScore = [self computeHScoreFrom:step.boardPos to:target];
                [self insertInOpenSteps:step with:unit];
                
            } else {
                // Release the freshly created one
                step = [unit.spOpenSteps objectAtIndex:index];
                
                // Check to see if the G score for that step is lower
                if ((currentStep.gScore + moveCost) < step.gScore) {
                    
                    // Calculate G score and re-insert
                    step.gScore = currentStep.gScore + moveCost;
                    [unit.spOpenSteps removeObjectAtIndex:index];
                    [self insertInOpenSteps:step with:unit];
                }
            }
        }
    } while (unit.spOpenSteps.count > 0 );
}

- (NSMutableArray *) getEmptyAdjacentPointsAt:(CGPoint)position flag:(BOOL)flag
{
    NSMutableArray *array = [NSMutableArray array];
    
    // Looking SOUTH WEST
    CGPoint p = CGPointMake(position.x, position.y - 1);
    Tile *tilePtr = [self getTileWithPos:p];
    if ( tilePtr != nil && !tilePtr.touched &&
        (!tilePtr.isOccupied || tilePtr.isOwned))
        [array addObject:[NSValue valueWithCGPoint:p]];
    if ( flag ) tilePtr.touched = YES;
    
    // LOOKING SOUTH EAST
    p = CGPointMake(position.x - 1, position.y);
    tilePtr = [self getTileWithPos:p];
    if ( tilePtr != nil && !tilePtr.touched &&
        (!tilePtr.isOccupied || tilePtr.isOwned) )
        [array addObject:[NSValue valueWithCGPoint:p]];
    if ( flag ) tilePtr.touched = YES;
    
    // LOOKING NORTH EAST
    p = CGPointMake(position.x, position.y + 1);
    tilePtr = [self getTileWithPos:p];
    if ( tilePtr != nil  && !tilePtr.touched
        && (!tilePtr.isOccupied || tilePtr.isOwned))
        [array addObject:[NSValue valueWithCGPoint:p]];
    if ( flag ) tilePtr.touched = YES;
    
    // LOOKING NORTH WEST
    p = CGPointMake(position.x + 1, position.y);
    tilePtr = [self getTileWithPos:p];
    if ( tilePtr != nil && !tilePtr.touched
        && (!tilePtr.isOccupied || tilePtr.isOwned))
        [array addObject:[NSValue valueWithCGPoint:p]];
    if ( flag ) tilePtr.touched = YES;
    
    return array;
}

- (void) constructPathFromStep:(ShortestPathStep *)step for:(Unit *)unit
{
    // Create path in reversal and insert into unit's memory
    while ( step != nil ) {
        if ( step.parent != nil ) {
            step.position = [self getWorldPosFromIso:step.boardPos];
            [unit.shortestPath insertObject:step atIndex:0];
        }
        step = step.parent;
    }
    
    for (ShortestPathStep *s in unit.shortestPath) {
        NSLog(@"%@", s);
    }
}

- (void) insertInOpenSteps:(ShortestPathStep *)step with:(Unit *)unit
{
    // Create variables
	int newFScore = step.fScore;
	int count = unit.spOpenSteps.count;
    int i = 0;
    
    // Loop to find FScore that is more than step
	for (; i < count; i++) {
        ShortestPathStep *unitStep = [unit.spOpenSteps objectAtIndex:i];
		if ( newFScore <= unitStep.fScore) {
			break;
		}
	}
    
    // Insert at that location
    [unit.spOpenSteps insertObject:step atIndex:i];
}

- (int) computeHScoreFrom:(CGPoint)fromCoord to:(CGPoint)toCoord
{
    // F Score calculation
	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}









/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Helper Functions
/* Print out the current state of the board by unit type and ownership */
- (void) printBoard
{
    CCLOG(@"    ********TYPE*******************OWNED***********");
    for ( int i = GAMEMAPWIDTH - 1; i >= 0 ; i-- ) {
        NSMutableString *current = [NSMutableString string];
        for ( int k = 0; k < GAMEMAPHEIGHT ; k++ ) {
            Tile *temp = [[self.gameBoard objectAtIndex:i] objectAtIndex:k];
            if (temp.unit != nil)
                [current appendFormat:@"%d ", temp.unit.object.type];
            else
                [current appendFormat:@". "];
        }
        [current appendString:@"*** "];

        for ( int k = 0; k < GAMEMAPHEIGHT; k++ ) {
            Tile *temp = [[self.gameBoard objectAtIndex:i] objectAtIndex:k];
            if ( temp.isOccupied && temp.isOwned )
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
    CCLOG(@"    ***********************************************");
}

/* Returns if the position is a valid board position */
- (BOOL) isValidPos:(CGPoint)position
{
    int i = position.x;
    int j = position.y;
    if ( i < 0 || i > LASTMAPWIDTH || j < 0 || j > LASTMAPHEIGHT )
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
        return [[self.gameBoard objectAtIndex:position.x] objectAtIndex:position.y];
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
    return CGPointMake(LASTMAPWIDTH - floor(position.x), LASTMAPHEIGHT - floor(position.y));
}

/* Returns the first occupied point from start to end  */
- (CGPoint) getLineOfSight:(CGPoint)start to:(CGPoint)end
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
    } while ( ![self isOccupiedPos:start] ) ;
    return start;
}









/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Tile set searches
/* Returns an array of all owned tiles */
- (NSMutableArray *) getAllOwnedTiles
{
    NSMutableArray *array = [NSMutableArray array];
    for ( int i = 0 ; i < GAMEMAPWIDTH ; i++ ) {
        for ( int j = 0 ; j < GAMEMAPHEIGHT ; j++ ) {
            Tile *tilePtr = [self getTileWithPos:ccp(i,j)];
            if ( tilePtr.isOwned )
                [array addObject:[NSValue valueWithCGPoint:tilePtr.boardPos]];
        }
    }
    return array;
}

/* Returns an array of all non-owned tiles */
- (NSMutableArray *) getAllEnemyTiles
{
    NSMutableArray *array = [NSMutableArray array];
    for ( int i = 0 ; i < GAMEMAPWIDTH ; i++ ) {
        for ( int j = 0 ; j < GAMEMAPHEIGHT ; j++ ) {
            Tile *tilePtr = [self getTileWithPos:ccp(i,j)];
            if ( !tilePtr.isOwned )
                [array addObject:[NSValue valueWithCGPoint:tilePtr.boardPos]];
        }
    }
    return array;
}

/* Returns a shifted arrayOfPnts by shiftValue*/
- (NSMutableArray *) getNormalRange:(int)range at:(CGPoint)position flag:(BOOL)flag
{
    int x = position.x;
    int y = position.y;
    NSMutableArray *ret = [NSMutableArray array];
    // Loop through range
    for ( int i = -range; i <= range; i++ ) {
        for ( int j = -range; j <= range; j++ ) {
            if ( abs(i) + abs(j) <= range && flag ^ !(!i && !j) ) {
                [ret addObject:[NSValue valueWithCGPoint:CGPointMake(i+x, j+y)]];
            }
        }
    }
    return ret;
}

- (NSMutableArray *) getNormalForcedRange:(int)range at:(CGPoint)position flag:(BOOL)flag
{
    int x = position.x;
    int y = position.y;
    NSMutableArray *ret = [NSMutableArray array];
    // Loop through range
    for ( int i = -range; i <= range; i++ ) {
        for ( int j = -range; j <= range; j++ ) {
            CGPoint pos = CGPointMake(i+x, j+y);
            Tile *tilePtr = [self getTileWithPos:pos];
            if ( tilePtr.unit != nil ) {
                if ( abs(i) + abs(j) <= range && flag ^ !(!i && !j) ) {
                    [ret addObject:[NSValue valueWithCGPoint:pos]];
                }
            }
        }
    }
    return ret;
}

/* */
- (NSMutableArray *) getPathFindRange:(int)range at:(CGPoint)position
{
    // Creating a queue and return set
    NSMutableArray *queue = [NSMutableArray array];
    NSMutableArray *ret = [NSMutableArray array];
    
    // Adding the root
    [queue addObject:[NSValue valueWithCGPoint:position]];
    [queue addObject:[NSValue valueWithCGPoint:CGPointFlag]];
    Tile *tilePtr = [self getTileWithPos:position];
    tilePtr.touched = YES;
    
    // Depth counter
    int depth = 1;
    
    // Looping
    while ( [queue count] > 0 ) {
        // De-queue
        CGPoint pos = [[queue firstObject] CGPointValue];
        [queue removeObjectAtIndex:0];
        
        // If we de-queued the flag, queue new flag and increase depth
        if ( CGPointEqualToPoint(pos, CGPointFlag)) {
            depth++;
            [queue addObject:[NSValue valueWithCGPoint:CGPointFlag]];
            if ( depth > range  ) break;
        }
        
        // Find adjacent tiles and loop
        NSMutableArray *adjacent = [self getEmptyAdjacentPointsAt:pos flag:YES];
        for ( NSValue *v in adjacent ) {
            [queue addObject:v];
            [ret addObject:v];
        }
    }
    return ret;
}

- (NSMutableArray *) getLOSRange:(int)range at:(CGPoint)position
{
    int x = position.x;
    int y = position.y;
    NSMutableArray *ret = [NSMutableArray array];
    // Loop through range
    for ( int i = -range; i <= range; i++ ) {
        for ( int j = -range; j <= range; j++ ) {
            if ( abs(i) + abs(j) <= range && !(!i && !j)) {
                CGPoint target = CGPointMake(i+x, j+y);
                CGPoint LOS = [self getLineOfSight:position to:target];
                // If (x,y) can reach (i+x),(j+y)
                if ( CGPointEqualToPoint(LOS, target) ) {
                    [ret addObject:[NSValue valueWithCGPoint:LOS]];
                }
            }
        }
    }
    return ret;
}

- (NSMutableArray *) getUniqueArea:(NSMutableArray *)area at:(CGPoint)position flag:(BOOL)flag
{
    NSMutableArray *array = [NSMutableArray array];
    Direction dir = [GeneralUtils getDirection:self.currentUnitPtr.boardPos to:position];
    CGAffineTransform transform;
    switch ( dir ) {
        case NW:
            transform = CGAffineTransformMake(0, 1, 1, 0, 0, 0);
            break;
        case SW:
            transform = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
            break;
        case SE:
            transform = CGAffineTransformMake(0, -1, -1, 0, 0, 0);
            break;
        default:
            transform = CGAffineTransformIdentity;
            break;
    }
    // Loop through list

    for ( int i = 0; i < area.count; i++ ) {
        NSValue *v = [area objectAtIndex:i];
        CGPoint pnt = [v CGPointValue];
        // Flag means we must rotate the area accordingly
        if ( flag ) {
            pnt = ccpAdd(CGPointApplyAffineTransform(pnt, transform),self.currentUnitPtr.boardPos);
        } else {
            pnt = ccpAdd(pnt, position);
        }
        
        [array addObject:[NSValue valueWithCGPoint:pnt]];
    }
    return array;
}







/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
#pragma mark - Unit Delegates
- (void) unit:(Unit *)unit didFinishAction:(UnitSkill *)action
{
    // Reset turn state
    NSLog(@"<Moving to state A>");
    self.turnState = TurnStateA;
    
    [self printBoard];
}

- (void) unit:(Unit *)unit didMoveTo:(CGPoint)position
{
    Tile *oldTilePtr = [self getTileWithPos:unit.boardPos];
    Tile *newTilePtr = [self getTileWithPos:position];
    [oldTilePtr passByEnd:unit];
    [newTilePtr passByStart:unit];

    [self.delegate battleBrainWantsToReorder:newTilePtr];
}

- (BOOL) unit:(Unit *)unit wishesToUse:(UnitSkill *)action
{
    if ( [self.delegate battleBrainWishesToPerform:action] ) {
        // Store all these info
        self.currentActionPtr = action;
        [self turn_driver:CGPointFlag];
        return true;
    } else {
        return false;
    }
}

- (void) unit:(Unit *)unit wantsToPlace:(CCNode *)child
{
    [self.delegate battleBrainWantsToDisplayChild:child];
}

- (void) unit:(Unit *)unit wantsUnitEffect:(CCNode *)child
{
    child.scale = 4;
    child.anchorPoint = ccp(0.5, 0.5);
    [self.delegate battleBrainWantsToDisplayChild:child];
    id callBack = [CCCallBlock actionWithBlock:^{
        [child.parent removeChild:child cleanup:YES];
    }];
    [child runAction:[GeneralUtils actionBuffEffect:callBack]];
}









#pragma mark - Selectors
@end

//#pragma mark - UNIT/ACTION SPECIFIC HANDLERS

//
//- (BOOL) doAction:(Action)action
//              for:(Tile *)tile
//           toward:(TileVector *)vector
//           oppData:(SFSObject *)data
//          targets:(NSArray *)targets
//{
//    NSLog(@">[MYLOG]    Entering BattleBrain::doAction for %d", action);
//    BOOL ret = YES;
//    
//    
//    if ( action == ActionMove ) {
//        ret = [self moveToward:vector with:tile opp:NO];
//        
//    } else if ( action == ActionTeleport ) {
//        ret = [self teleportMove:vector with:tile opp:NO];
//        
//    } else if ( action == ActionMelee ) {
//        ret = [self melee:vector castedBy:tile oppData:data targets:targets];
//        
//    } else if ( action == ActionRange ) {
//        ret = [self range:vector castedBy:tile oppData:data targets:targets];
//        
//    } else if ( action == ActionMagic ) {
//        ret = [self magic:vector castedBy:tile oppData:data targets:targets];
//        
//    } else if ( action == ActionHeal ) {
//        ret = [self heal:vector castedBy:tile oppData:data targets:targets];
//    
//    } else if ( action == ActionMeleeAOE ) {
//        ret = [self meleeAOE:vector castedBy:tile oppData:data targets:targets];
//        
//    } else if ( action == ActionRangeAOE ) {
//        ret = 0;
//        
//    } else if ( action == ActionMagicAOE ) {
//        ret = 0;
//        
//    } else if ( action == ActionHealAOE ) {
//        ret = 0;
//    
//    } else if ( action == ActionParalyze ) {
//        ret = [self paralyze:vector castedBy:tile targets:targets];
//        
//    } else {
//        NSAssert(false, @">[FATAL]  BATTLEBRAIN:DOACTION CAN NOT HANDLE ACTION %d", action);
//        
//    }
//    
//    CCLOG(@">[MYLOG]    BattleBrain::doAction returned with %d", ret);
//    [self printBoard];
//    return ret;
//}
//
//- (BOOL) doOppAction:(SFSObject *)data
//{
//
//    int xBoard = [data getInt:@"xBoard"];
//    int yBoard = [data getInt:@"yBoard"];
//    int action = [data getInt:@"action"];
//    SFSObject *obj = [data getSFSObject:@"effect"];
//    int time = [data getInt:@"timeDuration"];
//    TileVector *vector = [data getClass:@"vector"];
//    NSArray *targets = [data getKeys];
//    NSLog(@"KEYS ARE %@",targets);
//    
//    // Converting factor
//    int invertFactor = MAPLENGTH -1;
//    
//    // Invert the positions
//    CGPoint startPos = ccp(invertFactor - xBoard, invertFactor - yBoard);
//    vector.tile = [self findTile:[self getOppPos:vector.tile.boardPos] absPos:NO];
//    
//    NSLog(@">[MYLOG]    Received data: \
//          \n>           From: %@ \
//          \n            To: %@ \
//          \n            For Action: %d and Duration: %d \
//          \n            Effect: %@",
//          NSStringFromCGPoint(startPos),
//          NSStringFromCGPoint(vector.tile.boardPos),
//          action, time,
//          [obj description] );
//    
//    Tile *tile = [self findTile:startPos absPos:false];
//    
//    if ( action == MOVE ) {
//        CCLOG(@"    Opponent MOVED to %@", NSStringFromCGPoint(vector.tile.boardPos));
//        [self moveToward:vector with:tile opp:YES];
//        
//    } else if ( action == ATTK ) {
//        CCLOG(@"    Opponent ATTK");
//        [self attackToward:vector with:tile animate:action oppObj:obj targets:targets opp:YES];
//        
//    } else if ( action == GORGON_SHOOT ) {
//        NSLog(@"    Opponent GORGON_SHOOT");
//        [self shootToward:vector with:tile animate:action oppObj:obj targets:targets opp:YES];
//        
//    } else if ( action == GORGON_FREEZE ) {
//        NSLog(@"    Opponent GORGON_FREEZE");
//        [self freezeToward:vector with:tile opp:YES];
//        
//    } else if ( action == DEFN ) {
//        CCLOG(@"    Opponent DEFN");
//        //[[tile unit] action:DEFN at:CGPointZero];
//        
//    } else if ( action == TELEPORT_MOVE ) {
//        NSLog(@"    Opponent TELEPORT_MOVE");
//        [self teleportMoveToward:vector with:tile opp:YES];
//        
//    } else if ( action == MUDGOLEM_EARTHQUAKE ) {
//        NSLog(@"    Opponent MUDGOLEM_EARTHQUAKE");
//        [self earthquakeAt:vector with:tile oppObj:obj targets:targets opp:YES];
//        
//    } else if ( action == DRAGON_FIREBALL ) {
//        NSLog(@"    Opponent DRAGON_FIREBALL");
//        [self fireballToward:vector with:tile animate:action oppObj:obj targets:targets opp:YES];
//        
//    } else if ( action == DRAGON_FLAMEBREATH ) {
//        NSLog(@"    Opponent DRAGON_FLAMEBREATH");
//        [self flamebreathToward:vector with:tile oppObj:obj targets:targets opp:YES];
//        
//    } else if ( action == HEAL_ALL ) {
//        NSLog(@"    Opponent HEAL_ALL");
//        [self healAll:vector with:tile oppObj:obj targets:targets opp:YES];
//        
//    } else {
//        NSAssert(false, @">[FATAL]  BATTLEBRAIN:DOOPPACTION CAN NOT HANDLE ACTION %d", action);
//        
//    }
//    return 0;
//}
//
//- (NSArray *) findAreaForAction:(Action)action tile:(Tile *)tile
//{
//    NSLog(@">[MYLOG]   Finding Area for %d",action);
//    if ( action == ActionMove ) {
//        return [self findMoveTiles:tile.boardPos for:tile.unit.obj.movespeed];
//        
//    } else if ( action == ActionTeleport ) {
//        return [self findTeleportTiles:tile.boardPos for:tile.unit.obj.movespeed];
//        
//    } else if (action == ActionMelee) {
//        return [self bridge:[(MudGolem *)[tile unit] getAttkArea] from:tile.boardPos at:NE];
//        
//    } else if ( action == ActionRange ) {
//        return [self bridge:[(Gorgon *)[tile unit] getShootArea] from:tile.boardPos at:NE];
//        
//    } else if ( action == ActionMagic ) {
//        return [self bridge:[(Dragon *)[tile unit] getFireballArea] from:tile.boardPos at:NE];
//        
//    } else if ( action == ActionHeal ) {
//        return nil;
//        
//    } else if ( action == ActionMeleeAOE ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:tile.boardPos]];
//        
//    } else if ( action == ActionRangeAOE ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:tile.boardPos]];
//        
//    } else if ( action == ActionMagicAOE ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:tile.boardPos]];
//        
//    } else if ( action == ActionHealAOE ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:tile.boardPos]];
//        
//    } else if ( action == ActionParalyze ) {
//        return [self bridge:[(Gorgon *)[tile unit] getFreezeArea] from:tile.boardPos at:NE];
//        
//    } else {
//        NSAssert(false, @">[FATAL]  BATTLEBRAIN:FINDACTIONTILES CAN NOT HANDLE ACTION %d", action);
//        return nil;
//        
//    }
//}
//
//- (NSMutableArray *) findEffectForAction:(Action)action tile:(Tile *)tile direction:(Direction)direction center:(CGPoint)position
//{
//    NSLog(@">[MYLOG]    Finding Effect for %d facing %d", action, direction);
//    if ( action == ActionMove ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:position]];
//        
//    } else if ( action == ActionTeleport ) {
//        return [NSArray arrayWithObject:[NSValue valueWithCGPoint:position]];
//        
//    } else if ( action == ActionMelee ) {
//        return [self bridge:[(MudGolem *)[tile unit] getAttkEffect] from:position at:0];
//        
//    } else if ( action == ActionRange ) {
//        return [self bridge:[(Gorgon *)[tile unit] getShootEffect] from:position at:0];
//        
//    } else if ( action == ActionMagic ) {
//        return [self bridge:[(Dragon *)[tile unit] getFireballEffect] from:position at:0];
//        
//    } else if ( action == ActionHeal ) {
//        return nil;
//        
//    } else if ( action == ActionMeleeAOE ) {
//        return [self bridge:[(MudGolem *)[tile unit] getEarthquakeEffect] from:position at:0];
//
//    } else if ( action == ActionRangeAOE ) {
//        return nil;
//        
//    } else if ( action == ActionMagicAOE ) {
//        return nil;
//        
//    } else if ( action == ActionParalyze ) {
//        return [self bridge:[(Gorgon *)[tile unit] getFreezeEffect] from:position at:0];
//                
//    } else {
//        NSAssert(false,
//                 @">[FATAL]  BATTLEBRAIN:FINDEFFECTTILES CAN NOT HANDLE ACTION %d", action);
//        return nil;
//    }
//}
//
//- (NSArray *) findAllUnits:(BOOL)owned and:(BOOL)notOwned;
//{
//    NSLog(@">[MYLOG]    findAllOwnedPositions");
//    NSMutableArray *array = [NSMutableArray array];
//    // Cycle through the tiles
//    for ( int i = 0 ; i < MAPLENGTH ; i++ ) {
//        for ( int k = 0 ; k < MAPWIDTH ; k++ ) {
//            Tile * tile = [self findTile:ccp(i,k) absPos:NO];
//            if ( tile.unit != nil ) {
//                if ( [tile isOwned] ) {
//                    NSLog(@">       Found %@",tile);
//                    [array addObject:[NSValue valueWithCGPoint:tile.boardPos]];
//                }
//            }
//        }
//    }
//    return array;
//}
//
//#pragma mark - PRIMARY SKILLS - DMG
//- (BOOL) heal:(TileVector *)vector
//     castedBy:(Tile *)tile
//      oppData:(SFSObject *)obj
//      targets:(NSArray *)targets
//{
//    // find skill information for every constant used in this function
//    
//    NSMutableArray *unitTargetList = [NSMutableArray array];
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [self bresenham:tile.boardPos to:[v CGPointValue]];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        // Calculations, then add to array
//        UnitDamage *dmgPtr; DamageObj *heal;
//        if ( [obj isEqual:nil] ) {
//            heal = [tile.unit.attribute damageCalculationForSkillType:SkillDamageTypeNormalHeal
//                                                      skillDamageType:0
//                                                           multiplier:1.0f
//                                                               target:target.unit.attribute];
//            [obj putClass:NSStringFromCGPoint([self getOppPos:target.boardPos]) value:heal];
//        } else {
//            heal = (DamageObj *)[obj getClass:NSStringFromCGPoint(p)];
//        }
//        dmgPtr = [UnitDamage unitDamageTarget:target.unit damage:heal];
//        [unitTargetList addObject:dmgPtr];
//    }
//    [tile.unit primaryAction:ActionHeal targets:unitTargetList];
//    return YES;
//}
//
//- (BOOL) magic:(TileVector *)vector
//      castedBy:(Tile *)tile
//       oppData:(SFSObject *)obj
//       targets:(NSArray *)targets
//{
//    NSMutableArray *unitTargetList = [NSMutableArray array];
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [self bresenham:tile.boardPos to:[v CGPointValue]];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        // Calculations, then add to array
//        UnitDamage *dmgPtr; DamageObj *damage;
//        if ( [obj isEqual:nil] ) {
//            damage = [tile.unit.attribute damageCalculationForSkillType:SkillDamageTypeNormalMagic
//                                                        skillDamageType:0
//                                                             multiplier:1.0f
//                                                                 target:target.unit.attribute];
//            [obj putClass:NSStringFromCGPoint([self getOppPos:target.boardPos]) value:damage];
//        } else {
//            damage = (DamageObj *)[obj getClass:NSStringFromCGPoint(target.boardPos)];
//        }
//        dmgPtr = [UnitDamage unitDamageTarget:target.unit damage:damage];
//        [unitTargetList addObject:dmgPtr];
//    }
//    [[tile unit] primaryAction:ActionMagic targets:unitTargetList];
//    return YES;
//}
//
//- (BOOL) range:(TileVector *)vector
//      castedBy:(Tile *)tile
//       oppData:(SFSObject *)obj
//       targets:(NSArray *)targets
//{
//    NSMutableArray *unitTargetList = [NSMutableArray array];
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [self bresenham:tile.boardPos to:[v CGPointValue]];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        UnitDamage *dmgPtr; DamageObj *damage;
//        if ( [obj isEqual:nil] ) {
//            damage = [tile.unit.attribute damageCalculationForSkillType:SkillDamageTypeNormalRange
//                                                        skillDamageType:0
//                                                             multiplier:1.0f
//                                                                 target:target.unit.attribute];
//            [obj putClass:NSStringFromCGPoint([self getOppPos:target.boardPos]) value:damage];
//        } else {
//            damage = (DamageObj *)[obj getClass:NSStringFromCGPoint(target.boardPos)];
//        }
//        dmgPtr = [UnitDamage unitDamageTarget:target.unit damage:damage];
//        [unitTargetList addObject:dmgPtr];
//    }
//    [[tile unit] primaryAction:ActionRange targets:unitTargetList];
//    return YES;
//}
//
//- (BOOL) melee:(TileVector *)vector
//      castedBy:(Tile *)tile
//       oppData:(SFSObject *)obj
//       targets:(NSArray *)targets
//{
//    NSMutableArray *unitTargetList = [NSMutableArray array];
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [self bresenham:tile.boardPos to:[v CGPointValue]];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        UnitDamage *dmgPtr; DamageObj *damage;
//        if ( [obj isEqual:nil] ) {
//            damage = [tile.unit.attribute damageCalculationForSkillType:SkillDamageTypeNormalMelee
//                                                        skillDamageType:0
//                                                             multiplier:1.0f
//                                                                 target:target.unit.attribute];
//            [obj putClass:NSStringFromCGPoint([self getOppPos:target.boardPos]) value:damage];
//        } else {
//            damage = (DamageObj *)[obj getClass:NSStringFromCGPoint(target.boardPos)];
//        }
//        dmgPtr = [UnitDamage unitDamageTarget:target.unit damage:damage];
//        [unitTargetList addObject:dmgPtr];
//    }
//    [tile.unit primaryAction:ActionMelee targets:unitTargetList];
//    return YES;
//}
//
//- (BOOL) meleeAOE:(TileVector *)vector
//         castedBy:(Tile *)tile
//          oppData:(SFSObject *)obj
//          targets:(NSArray *)targets
//{
//    NSMutableArray *unitTargetList = [NSMutableArray array];
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [v CGPointValue];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        // Calculations, then add to array
//        UnitDamage *dmgPtr; DamageObj *damage;
//        if ( [obj isEqual:nil] ) {
//            damage = [tile.unit.attribute damageCalculationForSkillType:SkillDamageTypePureMelee
//                                                        skillDamageType:0
//                                                             multiplier:1
//                                                                 target:target.unit.attribute];
//            [obj putClass:NSStringFromCGPoint([self getOppPos:target.boardPos]) value:damage];
//        } else {
//            damage = (DamageObj *)[obj getClass:NSStringFromCGPoint(p)];
//        }
//        dmgPtr = [UnitDamage unitDamageTarget:target.unit damage:damage];
//        [unitTargetList addObject:dmgPtr];
//        
//    }
//    [[tile unit] primaryAction:ActionMeleeAOE targets:unitTargetList];
//    return YES;
//}
//
//
//#pragma mark - PRIMARY SKILL - BUFF PLACERS
//- (BOOL) paralyze:(TileVector *)vector
//         castedBy:(Tile *)tile
//          targets:(NSArray *)targets
//{
//    for ( NSValue *v in targets ) {
//        // Find CGPoint value from array
//        CGPoint p = [v CGPointValue];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        Buff *buff = [ParalyzeBuff paralyzeBuffFromCaster:tile.unit atTarget:target];
//        [buff start];
//    }
//    
//    // Run action + Freeze enemy
//    [[tile unit] primaryAction:ActionParalyze targets:nil];
//    return YES;
//}
//
//- (BOOL) flamebreathToward:(TileVector *)vector with:(Tile *)tile targets:(NSArray *)targets
//{
//    for ( NSValue *v in targets ){
//        // Find CGPoint value from array
//        CGPoint p = [v CGPointValue];
//        
//        // Find Tile from CGPoint
//        Tile *target = [self findTile:p absPos:NO];
//        if ( target == nil || target.unit == nil ) continue;
//        
//        Buff *buff = [BlazeBuff blazeBuffAtTarget:tile for:4 damage:10];
//        [buff start];
//    }
//    [[tile unit] primaryAction:ActionMagicAOE targets:[NSArray arrayWithObject:vector.tile]];
//    
//    return YES;
//}
//
//#pragma mark - SECONDARY SKILLS
//- (BOOL) teleportMove:(TileVector *)vector with:(Tile *)tile opp:(BOOL)opp
//{
//    NSLog(@">[MYLOG] Teleporting to %@", NSStringFromCGPoint(vector.tile.boardPos));
//    // Find the board tiles
//    Tile *end = vector.tile;
//    
//    // check if we're already there
//    if ( CGPointEqualToPoint ([end boardPos], [tile boardPos]) )
//    {
//        CCLOG(@"    You're already there!");
//        return NO;
//    }
//    
//    // check if destination is occupied
//    if ( [end isOccupied] )
//    {
//        CCLOG(@"    Destination is occupied!");
//        return NO;
//    }
//    
//    [[tile unit] secondaryAction:ActionTeleport at:[self findAbsPos:end.boardPos]];
//
//    [end setUnit:[tile unit]];
//    [tile setUnit:nil];
//    return YES;
//}
//
//
//
//
//#pragma mark - TILE FINDERS
//- (Tile *) doSelect:(CGPoint)position
//{
//    Tile * tile = [self findTile:position absPos:true];
//    if ( [tile unit] == nil )
//    {
//        CCLOG(@">[Error]    The position did not yield a proper selection");
//        return nil;
//    }
//    return tile;
//}
//
//- (NSArray *) findTeleportTiles:(CGPoint)position for:(int)area
//{
//    NSMutableArray *array = [NSMutableArray array];
//    for (int i = -area; i <= area; i++ ) {
//        for ( int j = -area; j <= area; j++ ) {
//            CGPoint pos = ccpAdd(position, ccp(i,j));
//            if ( [self isValidTile:pos]
//                && ![self isOccupiedTile:pos]
//                && !(i == 0 && j == 0)
//                && (abs(i) + abs(j) <= area) )
//                [array addObject:[NSValue valueWithCGPoint:pos]];
//        }
//    }
//    return array;
//}
//
//- (NSArray *) findMoveTiles:(CGPoint)position for:(int)range
//{
//    // THIS NEEDS OPTIMIZATION
//    // Holding array
//    NSMutableArray *array = [NSMutableArray array];
//    
//    CGPoint p = ccp(position.x - 1, position.y);
//    if ( [self isValidTile:p] && area != 0 )
//        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
//            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];
//    
//    p = ccp(position.x, position.y - 1);
//    if ( [self isValidTile:p] && area != 0 )
//        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
//            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];
//    
//    p = ccp(position.x + 1, position.y);
//    if ( [self isValidTile:p] && area != 0 )
//        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
//            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];
//    
//    p = ccp(position.x, position.y + 1);
//    if ( [self isValidTile:p] && area != 0 )
//        if ( [self isOwnedTile:p] || ![self isOccupiedTile:p] )
//            [array addObjectsFromArray: [self findMoveTiles:p for:area - 1]];
//    
//    // Add ourself only if we are empty
//    if ( [self isValidTile:position] && ![self isOccupiedTile:position])
//        if ( ![array containsObject:[NSValue valueWithCGPoint:position]] )
//            [array addObject:[NSValue valueWithCGPoint:position]];
//    
//    return [NSArray arrayWithArray:array];
//}
//

//
//
//#pragma mark - GENERAL HELPERS

//
//- (int) findDirection:(CGPoint)p1 to:(CGPoint)p2
//{
//    CGPoint difference = ccpSub(p2, p1);
//    if (difference.x > 0 ) return NW;
//    else if (difference.x < 0 ) return SE;
//    else if (difference.y > 0 ) return NE;
//    else if (difference.y < 0 ) return SW;
//    else return NE;
//}
//
//- (void) killtile:(CGPoint)position
//{
//    Tile *tile = [self findTile:position absPos:true];
//    NSLog(@">[MYLOG]    Entering BattleBrain:killtile for %@",tile);
//    
//    [tile.unit setDelegate:nil];
//    [tile setUnit:nil];
//}
//
//- (void) resetTurnForSide:(BOOL)side
//{
//    // Cycle through the tiles
//    for ( int i = 0 ; i < MAPLENGTH ; i++ ) {
//        for ( int k = 0 ; k < MAPWIDTH ; k++ ) {
//            Tile * tile = [self findTile:ccp(i,k) absPos:NO];
//            NSLog(@">[RESET]    Tile:%@", tile);
//            if ( tile.unit != nil ) {
//                [tile reset];
//                if ( ![tile isOwned] ^ side ) {
//                    [tile.unit reset];
//                }
//            }
//        }
//    }
//}
//
//- (CGPoint) bresenham:(CGPoint)start to:(CGPoint)end
//{
//    // purpose is to print out the path from start to the next occupied tile or the end.
//    int dx = abs(end.x - start.x);
//    int dy = abs(end.y - start.y);
//    int sx = ( start.x < end.x ) ? 1 : -1;
//    int sy = ( start.y < end.y ) ? 1 : -1;
//    int err = dx - dy;
//    do {
//        if ( start.x == end.x && start.y == end.y )
//            return start;
//        int err2 = err * 2;
//        if ( err2 > -dy ) {
//            err = err - dy;
//            start.x = start.x + sx;
//        }
//        if ( start.x == end.x && start.y == end.y )
//            return start;
//        if ( err2 < dx ) {
//            err = err + dx;
//            start.y = start.y + sy;
//        }
//    } while ( [self isValidTile:start] && ![self isOccupiedTile:start] ) ;
//    return start;
//}
//
//- (NSMutableArray *) bresenhamList:(CGPoint)start to:(CGPoint)end inclusive:(BOOL)inc
//{
//    // purpose is to print out the path from start to the next occupied tile or the end.
//    int dx = abs(end.x - start.x);
//    int dy = abs(end.y - start.y);
//    int sx = ( start.x < end.x ) ? 1 : -1;
//    int sy = ( start.y < end.y ) ? 1 : -1;
//    int err = dx - dy;
//    NSMutableArray *ret = [NSMutableArray mutableArrayUsingWeakReferences];
//
//    if ( inc ) [ret addObject:[self findTile:start absPos:NO]]; // start
//    do {
//        if ( start.x == end.x && start.y == end.y )
//            break;
//        int err2 = err * 2;
//        if ( err2 > -dy ) {
//            err = err - dy;
//            start.x = start.x + sx;
//        }
//        if ( start.x == end.x && start.y == end.y ) {
//            if ( inc ) { [ret addObject:[self findTile:start absPos:NO]];
//            }// end
//            break;
//        }
//        if ( err2 < dx ) {
//            err = err + dx;
//            start.y = start.y + sy;
//        }
//        [ret addObject:[self findTile:start absPos:NO]]; // everything else
//    } while ( [self isValidTile:start] && ![self isOccupiedTile:start] ) ;
//    
//    return ret;
//}
//
//- (CGPoint) fixProjectile:(CGPoint)destination toLineStart:(CGPoint)start end:(CGPoint)end
//{
//    // Line A - P
//    CGPoint startToDestination = ccpSub(destination, start);
//    // Line A - B
//    CGPoint startToEnd = ccpSub(end, start);
//    // Magnitude of A - B
//    float startToEndSq = pow(startToEnd.x, 2) + pow(startToEnd.y, 2);
//    // Dot product of A - B . A - P
//    float dotProduct = startToDestination.x * startToEnd.x + startToDestination.y * startToEnd.y;
//    // Normalized distance
//    float t = dotProduct/startToEndSq;
//    // SHIT SON EZ GAME
//    CGPoint ret = ccp(start.x + startToEnd.x * t, start.y + startToEnd.y * t);
//    NSLog(@">[MYLOG]        Projectile fix to %f,%f", ret.x, ret.y);
//    return ret;
//}
//
//- (NSArray *) bridge:(CGPoint *)list from:(CGPoint)position at:(int)direction
//{
//    NSMutableArray *array = [NSMutableArray array];
//    // Starting pointer
//    int start = 0;
//    for ( int i = 0; i < 4; i++ )
//        if ( direction == list[start].x ) continue;
//        else start += list[start].y +1;
//    int array_size = list[start].y;
//    if ( array_size == 0 )
//        return nil;
//    for (int i = start + 1; i <= start+array_size; i ++) {
//        CGPoint point = ccpAdd(list[i],position);
//        if ( [self isValidTile:point] ) {
//            [array addObject:[NSValue valueWithCGPoint:point]];
//        }
//    }
//    return array;
//}
//
//- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord opp:(BOOL)opp
//{
//	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
//    
//	// SW
//	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
//	if ([self isValidPos:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//            [tmp addObject:[NSValue valueWithCGPoint:p]];
//        }
//    
//	// NW
//	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
//	if ([self isValidPos:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//            [tmp addObject:[NSValue valueWithCGPoint:p]];
//        }
//    
//	// NE
//	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
//	if ([self isValidPos:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//            [tmp addObject:[NSValue valueWithCGPoint:p]];
//        }
//    
//	// SE
//	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
//	if ([self isValidPos:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//            [tmp addObject:[NSValue valueWithCGPoint:p]];
//        }
//    
//	return [NSArray arrayWithArray:tmp];
//}
//
//
//- (BOOL) isOccupiedTile:(CGPoint)position
//{
//    return [[[[self board] objectAtIndex:position.x] objectAtIndex:position.y] isOccupied];
//}
//
//- (BOOL) isOwnedTile:(CGPoint)position
//{
//    Tile *tile = [[[self board] objectAtIndex:position.x] objectAtIndex:position.y];
//    if ( tile.unit != nil && [tile.unit canIDo:ActionMove] ) return NO;
//    else return [tile isOwned];
//}
//
//- (CGPoint) getOppPos:(CGPoint)position
//{
//    return ccp(MAPLENGTH - 1 - position.x, MAPWIDTH - 1 - position.y);
//}
//
//#pragma mark - Tile Delegate
//- (void) tileDelegateTransformTileMe:(Tile *)tile fromGid:(int)start toGid:(int)end delay:(int)delay
//{
//    [self.delegate battleBrainDelegateTransformTileAt:tile.boardPos fromGid:start toGid:end delay:delay];
//}
//@end
