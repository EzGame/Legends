//
//  UnitDisplay.h
//  Legends
//
//  Created by David Zhang on 2013-02-14.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"
// Other
#import "Tile.h"
/***************************************************************/
@interface UnitDisplay : CCNode
{
    float size;
}
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) CCLabelBMFont *nameLabel;
@property (nonatomic, strong) CCLabelBMFont *dmgLabel;
@property (nonatomic, strong) CCLabelBMFont *moveLabel;
@property (nonatomic, strong) CCLabelBMFont *delayLabel;
@property (nonatomic, strong) CCLabelBMFont *blockLabel;

@property (nonatomic, strong) CCProgressTimer *hpBar;

- (void) scale:(float)scale;

- (id) initWithPosition:(CGPoint)position;
+ (id) displayWithPosition:(CGPoint)position;

- (void) setDisplayFor:(Tile *)tile;
- (void) setHPBar:(Tile *)tile;
@end
/***************************************************************/
@interface CommandsDisplay : CCNode
{
    int maxCP;
    BOOL isOwner;
}
@property (nonatomic, strong) CCLabelBMFont *cpDisplay;
@property (nonatomic) int cpAmount;
@property (nonatomic) int cpGainPerTurn;
+ (id) commandsDisplayWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner;
- (id) initWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner;

- (void) turnEnded;
- (void) usedAmount:(int)amount;
- (BOOL) isOutOfPoints;
@end
/***************************************************************
@class Timer;
@protocol TimerDelegate <NSObject>

@required
- (void)thresholdReached;

@end

@interface Timer : CCNode

@property (nonatomic, strong) id <TimerDelegate> delegate;
@property (nonatomic, strong) CCLabelBMFont *displayTime;
@property (nonatomic) int countTime;
@property (nonatomic) int thresholdTime;
@property (nonatomic) BOOL isDown;

- (id) initCountDown:(int)startTime;
- (id) initCountUp:(int)thresholdTime;

- (void) startTimer;
- (void) pauseTimer;
@end
***************************************************************/

