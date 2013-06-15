//
//  SetupBrain.h
//  Legends
//
//  Created by David Zhang on 2013-02-08.
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"
#import "UserSingleton.h"
// Others
#import "Tile.h"
#import "Minotaur.h"

@class SetupBrain;

@protocol SetupBrainDelegate <NSObject>
@required
- (void)loadTile:(Tile *)tile;
@end

@interface SetupBrain : NSObject
{
    // Matrix conversion from cartesian to isometric
    CGAffineTransform   toIso;
    // Matric conversion from isometric to cartesian
    CGAffineTransform   fromIso;
    // Positional offset of layer due to scrolling
    CGPoint currentLayerPos;
}

@property (nonatomic, strong) NSArray *board;
@property (assign) id <SetupBrainDelegate> delegate;

- (void) restoreSetup;
- (Tile *) findTile:(CGPoint)position absPos:(bool)absPos;
- (void) swapPieces:(Tile *)tile with:(Tile*)original;
- (void) saveState:(Tile *)tile save:(bool)save;
- (bool) saveSetup;
- (void) setCurrentLayerPos:(CGPoint)position;


- (int) isValidTile:(CGPoint)position;
- (CGPoint) findBrdPos:(CGPoint)position;
- (CGPoint) findAbsPos:(CGPoint)position;
- (void) printBoard;
@end