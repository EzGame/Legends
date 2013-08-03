//
//  BattleBrain.h
//  Legend
//
//  Created by David Zhang on 2013-04-22.
//
//
//
//  BattleBrain.h
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//

// Auto includes
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "cocos2d.h"
#import "Defines.h"
#import "UserSingleton.h"
#import "Tile.h"
#import "Unit.h"
#import "Minotaur.h"
#import "Gorgon.h"
#import "MudGolem.h"
#import "Dragon.h"
#import "LionMage.h"
#import "Buff.h"

@interface TileVector : NSObject
@property (nonatomic, strong) Tile *tile;
@property (nonatomic) int direction;

+ (id) vectorWithTile:(Tile *)tile direction:(int)direction;
@end

@class BattleBrain;

@protocol BattleBrainDelegate <NSObject>
@required
- (void)    loadTile:(Tile *)tile;

- (void)    failToLoad;

- (void)    transformTileAt:(CGPoint)position
                    fromGid:(int)start
                      toGid:(int)end
                      delay:(float)delay;

- (void)    animateTileAt:(CGPoint)position
                     with:(CCAction *) action;

- (void)    shakeScreenAfter:(float)delay;
@end

@interface BattleBrain : NSObject<TileDelegate>
{
    // Positional offset of layer due to scrolling
    CGPoint currentLayerPos;
}
@property (nonatomic, strong) NSArray *board;
@property (assign) id <BattleBrainDelegate> delegate;
@property (nonatomic) CGAffineTransform toIso;
@property (nonatomic) CGAffineTransform fromIso;

// All logic should be in here
- (id)          initWithMap:(CCTMXLayer *) map;
- (void)        restoreSetup;
- (Tile *)      doSelect:(CGPoint)position;
- (BOOL)        doAction:(int)action
                     for:(Tile *)tile
                  toward:(TileVector *)vector
                  oppObj:(SFSObject *)obj
                 targets:(NSArray *)targets;

- (BOOL)         doOppAction:(SFSObject *)data;

- (NSArray *)   findActionTiles:(Tile *)tile
                         action:(int)action;

- (NSArray *)   findEffectTiles:(Tile *)tile
                         action:(int)action
                      direction:(int)direction
                         center:(CGPoint)position;

- (NSArray *)   findAllOwnedPositions;

- (Tile *)      findTile:(CGPoint)position
                  absPos:(bool)absPos;

- (BOOL)        isValidTile:(CGPoint)position;

- (BOOL)        isOccupiedTile:(CGPoint)position;

- (BOOL)        isOwnedTile:(CGPoint)position;

- (void)        setCurrentLayerPos:(CGPoint)position;

- (CGPoint)     findBrdPos:(CGPoint)position;

- (CGPoint)     findAbsPos:(CGPoint)position;

- (void)        printBoard;

- (void)        resetTurnForSide:(BOOL)side;

- (void)        killtile:(CGPoint)position;

- (void)        actionDidFinish;

@end
