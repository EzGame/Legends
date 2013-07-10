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
#import "Buff.h"

@class BattleBrain;

@protocol BattleBrainDelegate <NSObject>
@required
- (void)    loadTile:(Tile *)tile;

- (void)    failToLoad;

- (void)    unitDidMoveTo:(Tile *)tile;

- (void)    displayCombatMessage:(NSString*)message
                      atPosition:(CGPoint)point
                       withColor:(ccColor3B)color
                       withDelay:(float)delay;
@end

@interface BattleBrain : NSObject
{
    // Matrix conversion from cartesian to isometric
    CGAffineTransform   toIso;
    // Matric conversion from isometric to cartesian
    CGAffineTransform   fromIso;
    // Positional offset of layer due to scrolling
    CGPoint currentLayerPos;
}
@property (nonatomic, strong) NSArray *board;
@property (assign) id <BattleBrainDelegate> delegate;

// All logic should be in here
- (id)          initWithMap:(CCTMXLayer *) map;
- (void)        restoreSetup;
- (Tile *)      doSelect:(CGPoint)position;
- (BOOL)        doAction:(int)action
                     for:(Tile *)tile
                      to:(CGPoint)finish
                 targets:(SFSObject *)targets;

- (BOOL)         doOppAction:(SFSObject *)data;

- (NSArray *)   findActionTiles:(Tile *)tile
                         action:(int)action;

- (NSArray *)   findEffectTiles:(Tile *)tile
                         action:(int)action
                      direction:(int)direction
                         center:(CGPoint)position;

- (Tile *)      findTile:(CGPoint)position
                  absPos:(bool)absPos;

- (BOOL)        isValidTile:(CGPoint)position;

- (BOOL)        isOccupiedTile:(CGPoint)position;

- (BOOL)        isOwnedTile:(CGPoint)position;

- (void)        setCurrentLayerPos:(CGPoint)position;

- (CGPoint)     findBrdPos:(CGPoint)position;

- (CGPoint)     findAbsPos:(CGPoint)position;

- (void)        printBoard;

- (void)        killtile:(CGPoint)position;

- (void) actionDidFinish;

@end
