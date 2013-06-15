//
//  UnitDisplay.m
//  Legends
//
//  Created by David Zhang on 2013-02-14.
//
//

#import "UnitDisplay.h"
/***************************************************************/
@interface UnitDisplay ()
- (void) reposition;
@end

@implementation UnitDisplay
@synthesize nameLabel = _nameLabel;
@synthesize dmgLabel = _dmgLabel;
@synthesize moveLabel = _moveLabel;
@synthesize delayLabel = _delayLabel;
@synthesize blockLabel = _blockLabel;
@synthesize position = _position;

@synthesize hpBar = _hpBar;

+ (id) displayWithPosition:(CGPoint)position
{
    return [[self alloc] initWithPosition:position];
}
- (id) initWithPosition:(CGPoint)position
{
    self = [super init];
    if ( self )
    {
        size = 1;
        _position = position;
        // The name label
        _nameLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt" ];
        
        // The hp bar
        ccColor3B inital = {0,255,0};
        _hpBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"hp_bar.png"]];
        _hpBar.color = inital;
        _hpBar.type = kCCProgressTimerTypeBar;
        _hpBar.percentage = 0;  // initially nothing
        _hpBar.barChangeRate = ccp(1,0); // set to no vertical changes
        _hpBar.midpoint = ccp(0.0, 0.0f); // set the bar to move left to right
        _hpBar.visible = NO;
        
        // the dmg and move stats
        _dmgLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
        _moveLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
        // delay and block stats
        _delayLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
        _blockLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
        
        // Left align
        [_nameLabel setAnchorPoint:ccp(0,0.5f)];
        [_hpBar setAnchorPoint:ccp(0,0.5f)];
        [_dmgLabel setAnchorPoint:ccp(0,0.5f)];
        [_moveLabel setAnchorPoint:ccp(0,0.5f)];
        [_delayLabel setAnchorPoint:ccp(0,0.5f)];
        [_blockLabel setAnchorPoint:ccp(0,0.5f)];
        
        [self reposition];
        [self addChild:_dmgLabel];
        [self addChild:_moveLabel];
        [self addChild:_delayLabel];
        [self addChild:_blockLabel];
        [self addChild:_nameLabel];
        [self addChild:_hpBar z:-1];
    }
    return self;
}

- (void) reposition
{
    self.nameLabel.position = self.position;
    self.hpBar.position = ccpAdd(self.position, ccp(-10*size,-20*size));
    self.dmgLabel.position = ccpAdd(self.position, ccp(-10*size,-40*size));
    self.moveLabel.position = ccpAdd(self.position, ccp(30*size,-40*size));
    self.delayLabel.position = ccpAdd(self.position, ccp(-10*size,-60*size));
    self.blockLabel.position = ccpAdd(self.position, ccp(30*size,-60*size));
}

- (void) scale:(float)scale
{
    size = scale;
    self.nameLabel.scale = scale;
    self.dmgLabel.scale = scale;
    self.moveLabel.scale = scale;
    self.delayLabel.scale = scale;
    self.blockLabel.scale = scale;
    
    self.hpBar.scale = scale;

    [self reposition];
}

- (void) setDisplayFor:(Tile *) tile
{
    NSLog(@">[MYLOG] Setting display for tile %@",tile);
    if (tile.unit != nil)
    {
        [self.nameLabel setString:[[tile unit] description]];
        [self.dmgLabel setString:[NSString stringWithFormat:@" A:%d", [tile unit]->attack]];
        [self.moveLabel setString:[NSString stringWithFormat:@" S:%d", [tile unit]->moveArea]];
        [self.delayLabel setString:[NSString stringWithFormat:@" D:%d", 0]];
        [self.blockLabel setString:[NSString stringWithFormat:@" B:%d%%", (int)([tile unit]->block * 100)]];
        
        self.hpBar.visible = true;
        [self setHPBar:tile];
    }
    else
    {
        [self.nameLabel setString:@""];
        [self.dmgLabel setString:@""];
        [self.moveLabel setString:@""];
        [self.delayLabel setString:@""];
        [self.blockLabel setString:@""];
        
        self.hpBar.visible = false;
    }
}

- (void) setHPBar:(Tile *)tile
{
    int percentage = (tile.unit->hp*1.0/tile.unit->maxHP)*100;
    int red, green;
    if ([tile isOwned]) {
        red = (percentage <= 25)?255:(percentage >= 75)? 0:255 - 255.0f*(percentage+25)/50;
        green = (percentage <= 25)? 0:(percentage >= 75)? 255:255.0f*(percentage+25)/50;
        
    } else {
        red = 255;
        green = 0;
        
    }
    ccColor3B newColor = {red, green, 0};

    [self.hpBar setPercentage:percentage];
    self.hpBar.color = newColor;
}

@end
/***************************************************************/
@implementation CommandsDisplay
@synthesize cpDisplay = _cpDisplay;
@synthesize cpGainPerTurn = _cpGainPerTurn, cpAmount = _cpAmount;

+ (id) commandsDisplayWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner
{
    return [[self alloc] initWithPosition:position amount:amount gain:gain for:owner];
}

- (id) initWithPosition:(CGPoint)position amount:(int)amount gain:(int)gain for:(BOOL)owner
{
    self = [super init];
    if ( self ) {
        isOwner = owner;
        maxCP = 10;
        _cpAmount = amount;
        _cpGainPerTurn = gain;
        
        _cpDisplay = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",amount]
                                            fntFile:@"emulator.fnt"];
        _cpDisplay.position = position;
        [self addChild:_cpDisplay];
    }
    return self;
}

- (void) setCpAmount:(int)cpAmount
{
    _cpAmount = cpAmount;
    [_cpDisplay setString:[NSString stringWithFormat:@"%d",_cpAmount]];
}

- (void) usedAmount:(int)amount
{
    NSLog(@">[MYLOG]        CommandsDisplay::usedAmount %d", amount);
    [self setCpAmount:(self.cpAmount - amount)];
}

- (void) turnEnded
{
    int newamount = self.cpAmount + self.cpGainPerTurn;
    if (self.cpAmount > maxCP) newamount = maxCP;
    [self setCpAmount:newamount];
}

- (BOOL) isOutOfPoints
{
    return (self.cpAmount == 0)? YES: NO;
}

@end
/***************************************************************
@implementation Timer
@synthesize displayTime = _displayTime;
@synthesize countTime = _countTime, thresholdTime = _thresholdTime;
@synthesize isDown = _isDown;
@synthesize delegate = _delegate;

- (id) initCountDown:(int)startTime {
    if (!(self = [super init])) return nil;
    if( self )
    {
        _countTime = startTime;
        _thresholdTime = 0;
        int min = _countTime / 60;
        int sec = _countTime % 60;
        _displayTime = [CCLabelBMFont
                            labelWithString:[NSString stringWithFormat:@"%02d:%02d", min, sec]
                                    fntFile:@"emulator.fnt"];
        _displayTime.visible = false;
        
        _isDown = true;
    }
    return self;
}

- (id) initCountUp:(int)thresholdTime
{
    if (!(self = [super init])) return nil;
    if ( self )
    {
        _countTime = 0;
        _thresholdTime = thresholdTime;

        _displayTime = [CCLabelBMFont
                            labelWithString:@"00:00"
                                    fntFile:@"emulator.fnt"];
        
        _displayTime.visible = false;
        _isDown = false;
    }
    return self;
}

-(void)countDown:(ccTime)delta
{    
    self.countTime--;
    int min = self.countTime / 60;
    int sec = self.countTime % 60;
    [self.displayTime setString:[NSString stringWithFormat:@"%02d:%02d", min, sec]];
    if (self.countTime <= self.thresholdTime) {
        [self.delegate thresholdReached];
    }
}

- (void)countUp:(ccTime)delta
{
    self.countTime++;
    int min = self.countTime / 60;
    int sec = self.countTime % 60;
    [self.displayTime setString:[NSString stringWithFormat:@"%02d:%02d", min, sec]];
    if (self.countTime >= self.thresholdTime) {
        [self.delegate thresholdReached];
    }
}

- (void) startTimer
{
    self.displayTime.visible = true;
    if (self.isDown)
        [self schedule:@selector(countDown:) interval:1];
    else
        [self schedule:@selector(countUp:) interval:1];
}

- (void) pauseTimer
{
    if ( self.isDown )
        [self unschedule:@selector(countDown:)];
    else
        [self unschedule:@selector(countUp:)];
}

- (void) dealloc
{
    if ( self.isDown )
        [self unschedule:@selector(countDown:)];
    else
        [self unschedule:@selector(countUp:)];
}
@end
***************************************************************/
