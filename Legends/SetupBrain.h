//
//  SetupBrain.h
//  Legends
//
//  Created by David Zhang on 2013-02-08.
//

// Auto includes
#import "cocos2d.h"
#import "Tile.h"
#import "Constants.h"
#import "UserSingleton.h"

#import "Priest.h"
#import "Warrior.h"
#import "Witch.h"
#import "Ranger.h"
#import "Knight.h"
#import "Berserker.h"
#import "Paladin.h"


@class SetupBrain;

@protocol SetupBrainDelegate <NSObject>
@required
- (void) setupBrainNeedsUnitMenuAt:(CGPoint)position;
- (void) setupBrainDidLoadUnitAt:(Tile *)tile;
- (void) setupBrainDidRemoveUnit:(Unit *)unit;
- (void) setupBrainDidMoveUnitTo:(Tile *)tile;

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

@property (nonatomic, assign)           id delegate;
@property (nonatomic, strong)      NSArray *setupBoard;
@property (nonatomic, weak)     CCTMXLayer *tmxLayer;
@property (nonatomic)              CGPoint currentLayerPosition;

@property (nonatomic, strong)      NSArray *sideBoard;

// Screen -> toIso -> Isometric position
// Iso -> toWld -> World (setuplayer) position
// Iso -> toScn -> Screen position

@property (nonatomic) CGAffineTransform toIso;
@property (nonatomic) CGAffineTransform toWld;
@property (nonatomic) CGAffineTransform toScn;

- (id) initWithMap:(CCTMXLayer *)tmxLayer delegate:(id)delegate;

- (void) addUnit:(UnitObject *)obj;
- (Unit *) touchStarted:(CGPoint)position;
- (void) touchEnded:(CGPoint)position unit:(Unit *)unit;
@end