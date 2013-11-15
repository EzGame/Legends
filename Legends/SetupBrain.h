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

@class SetupBrain;

@protocol SetupBrainDelegate <NSObject>
@required
- (void)setupbrainDelegateUpdateNumbers:(int)totalValue :(int)totalFood;
//- (void)setupbrainDelegateLoadTile:(SetupTile *)tile;
//- (void)setupbrainDelegateReorderTile:(SetupTile *)tile;
//- (BOOL)setupbrainDelegateRemoveTile:(SetupTile *)tile;
@end

@interface SetupBrain : NSObject
{
    // Positional offset of layer due to scrolling
    CGPoint currentLayerPos;
    // Limiting 
    int totalValue;
    int totalFood;
    int maximumFood;
}

@property (assign) id <SetupBrainDelegate> delegate;
// Array of SetupTile Objects
@property (nonatomic, strong) NSArray *board;
// Array of SetupTile Objects
@property (nonatomic, strong) NSArray *sideBoard;
// Array of UnitObj
@property (nonatomic, weak) NSMutableArray *unitList;

@property (nonatomic) CGAffineTransform toIso;
@property (nonatomic) CGAffineTransform fromIso;

//- (void) restoreSetup;
//- (SetupTile *) findTile:(CGPoint)position absPos:(bool)absPos;
//- (void) viewUnitsForTag:(NSString *)tag;
//- (BOOL) move:(SetupTile *)tile to:(SetupTile *)target;
//- (bool) saveSetup;
//- (void) setCurrentLayerPos:(CGPoint)position;

- (int) isValidTile:(CGPoint)position;
- (CGPoint) findBrdPos:(CGPoint)position;
- (CGPoint) findAbsPos:(CGPoint)position;
- (void) printBoard;
@end