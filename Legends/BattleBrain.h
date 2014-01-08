////
////  BattleBrain.h
////  Legend
////
////  Created by David Zhang on 2013-04-22.
////
////
////
////  BattleBrain.h
////  Legends
////
////  Created by David Zhang on 2013-01-29.
////
////
//
#import "cocos2d.h"
#import "Tile.h"
#import "Priest.h"
#import "Warrior.h"
#import "Witch.h"
#import "Ranger.h"
#import "Knight.h"

@class BattleBrain;
@protocol BattleBrainDelegate <NSObject>
@required
- (void)            battleBrainDidLoadUnitAt:(Tile *)tile;
- (MatchObject *)   battleBrainNeedsMatchObj;
- (void)            battleBrainWantsToDisplayInfo:(Unit *)unit;
- (void)            battleBrainWantsToReorder:(Tile *)tile;
- (void)            battleBrainWantsToDisplayChild:(CCNode *)child;

- (BOOL)            battleBrainWishesToPerform:(ActionObject *)obj;
@end

@interface BattleBrain : NSObject <UnitDelegate>

@property (nonatomic, assign)                id delegate;
@property (nonatomic, strong)           NSArray *gameBoard;
@property (nonatomic, weak)          CCTMXLayer *tmxLayer;
@property (nonatomic)                   CGPoint currentLayerPosition;

// Screen -> toIso -> Isometric position
// Iso -> toWld -> World (gamelayer) position
// Iso -> toScn -> Screen position

@property (nonatomic)         CGAffineTransform toIso;
@property (nonatomic)         CGAffineTransform toWld;
@property (nonatomic)         CGAffineTransform toScn;

- (id)      initWithMap:(CCTMXLayer *)tmxLayer delegate:(id)delegate;
- (void)    turn_driver:(CGPoint)position;

@end

//// Auto includes
//#import <SFS2XAPIIOS/SmartFox2XClient.h>
//#import "cocos2d.h"
//#import "Defines.h"
//#import "UserSingleton.h"
//#import "Tile.h"
//#import "Unit.h"
//#import "Gorgon.h"
//#import "MudGolem.h"
//#import "Dragon.h"
//#import "LionMage.h"
//#import "Buff.h"
//
//@interface TileVector : NSObject
//@property (nonatomic, strong) Tile *tile;
//@property (nonatomic) int direction;
//
//+ (id) vectorWithTile:(Tile *)tile direction:(int)direction;
//@end
//
//@class BattleBrain;
//
//@protocol BattleBrainDelegate <NSObject>
//@required
//- (void)    battleBrainDelegateLoadTile:(Tile *)tile;
//- (void)    battleBrainDelegateTransformTileAt:(CGPoint)position
//                                       fromGid:(int)start
//                                         toGid:(int)end
//                                         delay:(int)delay;
//@end
//
//@interface BattleBrain : NSObject <TileDelegate>
//{
//    // Positional offset of layer due to scrolling
//    CGPoint currentLayerPos;
//}
//@property (nonatomic, strong) NSArray *board;
//@property (assign) id <BattleBrainDelegate> delegate;
//@property (nonatomic) CGAffineTransform toIso;
//@property (nonatomic) CGAffineTransform fromIso;
//
//- (id)          initWithMap:(CCTMXLayer *) map;
//- (void)        restoreSetup;
//- (BOOL)        doAction:(Action)action
//                     for:(Tile *)tile
//                  toward:(TileVector *)vector
//                 oppData:(SFSObject *)data
//                 targets:(NSArray *)targets;
//
//- (BOOL)         doOppAction:(SFSObject *)data;
//
//- (NSMutableArray *) findMoveTiles:(CGPoint)position for:(int)range;
//
//- (NSArray *) findAreaForAction:(Action)action
//                           tile:(Tile *)tile;
//
//
//- (NSArray *)   findEffectTiles:(Tile *)tile
//                         action:(Action)action
//                      direction:(Direction)direction
//                         center:(CGPoint)position;
//
//- (NSArray *)   findAllOwnedPositions;
//
//- (Tile *)      findTile:(CGPoint)position
//                  absPos:(bool)absPos;
//- (Tile *)      doSelect:(CGPoint)position;
//
//
//- (BOOL)        isValidTile:(CGPoint)position;
//
//- (BOOL)        isOccupiedTile:(CGPoint)position;
//
//- (BOOL)        isOwnedTile:(CGPoint)position;
//
//- (void)        setCurrentLayerPos:(CGPoint)position;
//
//- (CGPoint)     findBrdPos:(CGPoint)position;
//
//- (CGPoint)     findAbsPos:(CGPoint)position;
//
//- (void)        printBoard;
//
//- (void)        resetTurnForSide:(BOOL)side;
//
//- (void)        killtile:(CGPoint)position;
//@end
