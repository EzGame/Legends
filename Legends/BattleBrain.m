////
////  BattleBrain.m
////  Legend
////
////  Created by David Zhang on 2013-04-22.
////
////

#import "BattleBrain.h"

@implementation BattleBrain
#pragma mark - Setters n Getters
- (void) setCurrentLayerPosition:(CGPoint)currentLayerPosition
{
    _currentLayerPosition = currentLayerPosition;
    self.toWld = CGAffineTransformMake(-GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                        GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                        GAMETILEOFFSETX + currentLayerPosition.x,
                                        GAMETILEOFFSETY + currentLayerPosition.y);
    self.toIso = CGAffineTransformInvert(self.toWld);
}

#pragma mark - Init n Shit
- (id) initWithMap:(CCTMXLayer *) map;
{
    self = [super init];
    if ( self ) {
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
        
        // Populating board
        for ( int i = 0 ; i < GAMEMAPWIDTH ; i++ ) {
            for ( int k = 0 ; k < GAMEMAPHEIGHT ; k++ ) {
                CGPoint pos = CGPointMake(i, k);
                NSLog(@"pos %@", NSStringFromCGPoint(pos));
                Tile *tile = [[Tile alloc] init];
                if ( [self isValidPos:pos] ) {
                    tile.boardPos = pos;
                    tile.sprite = [map tileAt:pos];
                }
                [[_gameBoard objectAtIndex:i] addObject:tile];
            }
        }
        
        _toWld = CGAffineTransformMake( -GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                         GAMETILEWIDTH/2, GAMETILEHEIGHT/2,
                                         GAMETILEOFFSETX, GAMETILEOFFSETY);
        _toIso = CGAffineTransformInvert(_toWld);
        
        [self initSetup];
    }
    return self;
}

- (void) initSetup
{
    // Populating pieces
    NSLog(@"start");

    for ( int i = 0; i < [[[UserSingleton get] mySetup] size]; i++ )
    {
        // The stored string is in the form of @type[@x,@y]
        //UnitObj *obj = [UnitObj unitObjWithString:@"3/10000/1/1/1/1/1/1/1/1/{5,3}/0"];
        UnitObject *obj = [[[UserSingleton get] mySetup] getElementAt:i];

        Unit *unit = [self createUnitWith:obj isOwned:YES];
        Tile *tile = [self getTileWithPos:obj.position];
        tile.unit = unit;

        // Upload visually
        [self.delegate battleBrainDidLoadUnitAt:tile];
    }

    // Populating opponent pieces
    for ( int i = 0; i < [[[UserSingleton get] oppSetup] size]; i++ )
    {
        // The stored string is in the form of @type[@x,@y]
        //UnitObj *obj = [UnitObj unitObjWithString:@"3/10000/1/1/1/1/1/1/1/1/{5,3}/0"];
        UnitObject *obj = [[[UserSingleton get] oppSetup] getElementAt:i];

        Unit *unit = [self createUnitWith:obj isOwned:NO];
        Tile *tile = [self getTileWithPos:obj.position];
        tile.unit = unit;

        // Upload visually
        [self.delegate battleBrainDidLoadUnitAt:tile];
    }
}
//- (id) makeUnit:(int)type withObj:(UnitObj *)obj owned:(BOOL)side;
//{

//}

- (void) lightUp:(CGPoint)position
{
    CGPoint pos = [self getIsoPosFromWorld:position];
    NSLog(@"%@",NSStringFromCGPoint(pos));
    Tile *tilePtr = [[self.gameBoard objectAtIndex:pos.x] objectAtIndex:pos.y];
    [tilePtr.sprite setColor:ccRED];
}

#pragma mark - Helper Functions
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

- (Unit *) createUnitWith:(UnitObject *)obj isOwned:(BOOL)isOwned
{
    if ( obj.type == UnitTypePriest ) {
        return [[Priest alloc] initUnit:obj isOwned:isOwned];
        
    } else {
        NSAssert(false, @">[FATAL]    NONSUPPORTED TYPE IN BATTLEBRAIN:FINDTYPE %d", obj.type);
        return nil;
    }
}

- (Tile *) getTileWithPos:(CGPoint)pos
{
    if ( ![self isValidPos:pos] ) {
        return nil;
    } else {
        return [[self.gameBoard objectAtIndex:pos.x] objectAtIndex:pos.y];
    }
}

- (CGPoint) getWorldPosFromIso:(CGPoint)position
{
    CGPoint pos = CGPointMake(LASTMAPWIDTH - position.x, LASTMAPHEIGHT - position.y);
    NSLog(@"%@",NSStringFromCGPoint(pos));
    return CGPointApplyAffineTransform(pos, self.toWld);
}

- (CGPoint) getIsoPosFromWorld:(CGPoint)position
{
    CGPoint pos = CGPointApplyAffineTransform(position, self.toIso);
    NSLog(@"%@",NSStringFromCGPoint(pos));
    return CGPointMake(LASTMAPWIDTH-floor(pos.x), LASTMAPHEIGHT-floor(pos.y));
}

- (BOOL) isValidPos:(CGPoint)position
{
    int i = position.x;
    int k = position.y;
    if ( i < 0 || i > LASTMAPWIDTH || k < 0 || k > LASTMAPHEIGHT )
        return false;
    // DO NOT FUCK WITH THIS BOOL
    return !((!( abs(i-LASTMAPWIDTH) && abs(k-LASTMAPHEIGHT) ) &&
              i-LASTMAPWIDTH > -2 && k-LASTMAPHEIGHT > -2) ||
             (!( abs(i-LASTMAPWIDTH) && k ) &&
              i-LASTMAPWIDTH > -2 && k < 2) ||
             (!( i && abs(k-LASTMAPHEIGHT) ) &&
              k-LASTMAPHEIGHT > -2 && i < 2) ||
             (!(i && k) &&
              i < 2 && k < 2));
}
@end

//
//#import "BattleBrain.h"
//
//@implementation TileVector
//@synthesize tile = _tile, direction = _direction;
//+ (id) vectorWithTile:(Tile *)tile direction:(int)direction
//{
//    return [[TileVector alloc] initWithTile:tile direction:direction];
//}
//
//- (id) initWithTile:(Tile *)tile direction:(int)direction
//{
//    if ( self = [super init] ) {
//        _tile = tile;
//        _direction = direction;
//    }
//    return self;
//}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"TileVector %@->%d",self.tile,self.direction];
//}
//@end
//
//
//@interface BattleBrain ()
//- (void)        constructPathAndStartAnimationFromStep:(ShortestPathStep *)step
//                                                   for:(Tile *)tile;
//- (void)        insertInOpenSteps:(ShortestPathStep *)step
//                             with:(Tile *)tile;
//- (int)         computeHScoreFromCoord:(CGPoint)fromCoord
//                               toCoord:(CGPoint)toCoord;
//- (NSArray *)   walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
//                                                   opp:(BOOL)opp;
//@end
//
//@implementation BattleBrain
//@synthesize board = _board;
//@synthesize delegate = _delegate;
//@synthesize toIso = _toIso, fromIso = _fromIso;
//
//#pragma mark - Init n Shit
//- (id) initWithMap:(CCTMXLayer *) map
//{
//    self = [super init];
//    if (self)
//    {
//        // Matrices for conversion from cartesian to isometric and vice versa.
//        _toIso = CGAffineTransformMake(-HALFLENGTH, HALFWIDTH, HALFLENGTH, HALFWIDTH, OFFSETX, OFFSETY);
//        _fromIso = CGAffineTransformInvert(_toIso);
//        
//        _board = [[NSArray alloc] initWithObjects:
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array],
//                  [NSMutableArray array], nil];
//        
//        // Populating board
//        for ( int i = 0 ; i < MAPLENGTH ; i++ ) {
//            for ( int k = 0 ; k < MAPWIDTH ; k++ ) {
//                if ( ![self isValidTile:ccp(i,k)] ) {
//                    CCSprite *temp = [map tileAt:ccp(MAPLENGTH-1-i, MAPWIDTH-1-k)];
//                    Tile *tile = [Tile invalidTileWithPosition:ccp(i,k) sprite:temp];
//                    [[self.board objectAtIndex:i] addObject:tile];
//                    tile.delegate = self;
//                    
//                } else {
//                    CCSprite *temp = [map tileAt:ccp(MAPLENGTH-1-i, MAPWIDTH-1-k)];
//                    Tile *tile = [Tile tileWithPosition:ccp(i,k) sprite:temp];
//                    [[self.board objectAtIndex:i] addObject:tile];
//                    tile.delegate = self;
//                }
//            }
//        }
//    }
//    return self;
//}
//
//
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
//- (BOOL) moveToward:(TileVector *)vector with:(Tile *)tile opp:(BOOL)opp
//{
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
//    CCLOG(@"    From: %@", NSStringFromCGPoint([tile boardPos]));
//    CCLOG(@"    To: %@", NSStringFromCGPoint([end boardPos]));
//    
//    [[tile unit] setSpOpenSteps: [[NSMutableArray alloc] init]];
//    [[tile unit] setSpClosedSteps: [[NSMutableArray alloc] init]];
//    
//    // Start by adding the from position to the open list
//    [self insertInOpenSteps:[[ShortestPathStep alloc] initWithPosition:[tile boardPos] boardPos:[tile boardPos]] with:tile];
//    
//    do
//    {
//        // Get the lowest F cost step
//        // Because the list is ordered, the first step is always the one with the lowest F cost
//        ShortestPathStep *currentStep = [[[tile unit] spOpenSteps] objectAtIndex:0];
//        
//        // Add the current step to the closed set
//        [[[tile unit] spClosedSteps] addObject:currentStep];
//        
//        // Remove it from the open list
//        // Note that if we wanted to first removing from the open list, care should be taken to the memory
//        [[[tile unit] spOpenSteps] removeObjectAtIndex:0];
//        
//        // If the currentStep is the desired tile coordinate, we are done!
//        if (CGPointEqualToPoint(currentStep.position, [end boardPos])) {
//            [self constructPathAndStartAnimationFromStep:currentStep for:tile];
//            [[tile unit] setSpOpenSteps: nil]; // Set to nil to release unused memory
//            [[tile unit] setSpClosedSteps: nil]; // Set to nil to release unused memory
//            break;
//            
//        } else {
//            int count = 0;
//            ShortestPathStep *curStepPtr = currentStep;
//            do {
//                count ++;
//                curStepPtr = curStepPtr.parent;
//            } while (curStepPtr != nil);
//            
//            if ( count > tile.unit.obj.movespeed ) {
//                CCLOG(@"    Tile is too far away");
//                break;
//            }
//        }
//        
//        // Get the adjacent tiles coord of the current step
//        NSArray *adjSteps = [self walkableAdjacentTilesCoordForTileCoord:currentStep.position
//                                                                     opp:opp];
//        
//        for (NSValue *v in adjSteps)
//        {
//            ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue] boardPos:[v CGPointValue]];
//            
//            // Check if the step isn't already in the closed set
//            if ([[[tile unit] spClosedSteps] containsObject:step]) {
//                 // Must releasing it to not leaking memory ;-)
//                continue; // Ignore it
//            }
//            
//            // Compute the cost from the current step to that step
//            int moveCost = 1;
//            
//            // Check if the step is already in the open list
//            NSUInteger index = [[[tile unit] spOpenSteps] indexOfObject:step];
//            
//            if (index == NSNotFound) { // Not on the open list, so add it
//                
//                // Set the current step as the parent
//                step.parent = currentStep;
//                
//                // The G score is equal to the parent G score + the cost to move from the parent to it
//                step.gScore = currentStep.gScore + moveCost;
//                
//                // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
//                step.hScore = [self computeHScoreFromCoord:step.position toCoord:[end boardPos]];
//                
//                // Adding it with the function which is preserving the list ordered by F score
//                [self insertInOpenSteps:step with:tile];
//                
//                // Done, now release the step
//                
//            } else { // Already in the open list
//                
//                 // Release the freshly created one
//                step = [[[tile unit] spOpenSteps] objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
//                
//                // Check to see if the G score for that step is lower if we use the current step to get there
//                if ((currentStep.gScore + moveCost) < step.gScore) {
//                    
//                    // The G score is equal to the parent G score + the cost to move from the parent to it
//                    step.gScore = currentStep.gScore + moveCost;
//                    
//                    // Because the G Score has changed, the F score may have changed too
//                    // So to keep the open list ordered we have to remove the step, and re-insert it with
//                    // the insert function which is preserving the list ordered by F score
//                    
//                    // We have to retain it before removing it from the list
//                    
//                    // Now we can removing it from the list without be afraid that it can be released
//                    [[[tile unit] spOpenSteps] removeObjectAtIndex:index];
//                    
//                    // Re-insert it with the function which is preserving the list ordered by F score
//                    [self insertInOpenSteps:step with:tile];
//                    
//                    // Now we can release it because the oredered list retain it
//                }
//            }
//        }
//    } while ([[[tile unit] spOpenSteps] count] > 0 );
//    
//    if ( [[tile unit] shortestPath] == nil ) {
//        CCLOG(@"    Could not find path");
//        return NO;
//    } else {
//        [end setUnit:[tile unit]];
//        [tile setUnit:nil];
//        return YES;
//    }
//}
//
//#pragma mark - A* HELPERS
//- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step for:(Tile *)tile
//{
//	[[tile unit] setShortestPath: [NSMutableArray array]];
//    
//	do
//    {
//		if ( step.parent != nil )
//        { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
//            [step setPosition:[self findAbsPos:step.position]];
//			[[[tile unit] shortestPath] insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
//		}
//		step = step.parent; // Go backward
//	} while (step != nil); // Until there is no more parents
//    
//    for ( ShortestPathStep *s in [[tile unit] shortestPath] )
//    {
//        CCLOG(@"    %@", s);
//    }
//    
//    [[tile unit] secondaryAction:ActionMove at:CGPointZero];
//}
//
//- (void)insertInOpenSteps:(ShortestPathStep *)step with:(Tile *)tile
//{
//	int stepFScore = [step fScore]; // Compute the step's F score
//	int count = [[[tile unit] spOpenSteps] count];
//    int i = 0;
//	for (; i < count; i++)
//    {
//		if ( stepFScore <= [[[[tile unit] spOpenSteps] objectAtIndex:i] fScore])
//        { // If the step's F score is lower or equals to the step at index i
//			// Then we found the index at which we have to insert the new step
//            // Basically we want the list sorted by F score
//			break;
//		}
//	}
//	// Insert the new step at the determined index to preserve the F score ordering
//	[[[tile unit] spOpenSteps] insertObject:step atIndex:i];
//}
//
//- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
//{
//	// Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
//	// final desired step from the current step, ignoring any obstacles that may be in the way
//	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
//}
//
//- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord opp:(BOOL)opp
//{
//	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
//    
//	// SW
//	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
//	if ([self isValidTile:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//		[tmp addObject:[NSValue valueWithCGPoint:p]];
//	}
//    
//	// NW
//	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
//	if ([self isValidTile:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//		[tmp addObject:[NSValue valueWithCGPoint:p]];
//	}
//    
//	// NE
//	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
//	if ([self isValidTile:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//		[tmp addObject:[NSValue valueWithCGPoint:p]];
//	}
//    
//	// SE
//	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
//	if ([self isValidTile:p] &&
//        (![self isOccupiedTile:p] ||
//         ( [self isOwnedTile:p] ^ opp ) ) ) {
//		[tmp addObject:[NSValue valueWithCGPoint:p]];
//	}
//    
//	return [NSArray arrayWithArray:tmp];
//}
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
