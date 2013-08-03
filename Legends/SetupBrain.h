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
#import "Objects.h"
// Others
#import "Tile.h"
#import "Minotaur.h"

@class SetupBrain;

@protocol SetupBrainDelegate <NSObject>
@required
- (void)loadTile:(SetupTile *)tile;
- (BOOL)removeTile:(SetupTile *)tile;
- (void)reorderTile:(SetupTile *)tile;
@end

@interface SetupBrain : NSObject
{
    // Positional offset of layer due to scrolling
    CGPoint currentLayerPos;
}

// Array of SetupTile Objects
@property (nonatomic, strong) NSArray *board;
// Array of SetupTile Objects
@property (nonatomic, strong) NSArray *sideBoard;
// Array of UnitObj
@property (nonatomic, weak) NSMutableArray *unitList;
@property (assign) id <SetupBrainDelegate> delegate;

@property (nonatomic) CGAffineTransform toIso;
@property (nonatomic) CGAffineTransform fromIso;

- (void) restoreSetup;
- (SetupTile *) findTile:(CGPoint)position absPos:(bool)absPos;
- (void) viewUnitsForTag:(NSString *)tag;
- (BOOL) move:(SetupTile *)tile to:(SetupTile *)target;
- (bool) saveSetup;
- (void) setCurrentLayerPos:(CGPoint)position;

- (int) isValidTile:(CGPoint)position;
- (CGPoint) findBrdPos:(CGPoint)position;
- (CGPoint) findAbsPos:(CGPoint)position;
- (void) printBoard;
@end