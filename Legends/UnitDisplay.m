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
@property (nonatomic, strong) CCSprite *ui_vagrant;
@property (nonatomic, strong) CCSprite *ui_common;
@property (nonatomic, strong) CCSprite *ui_uncommon;
@property (nonatomic, strong) CCSprite *ui_rare;
@property (nonatomic, strong) CCSprite *ui_epic;
@property (nonatomic, strong) CCSprite *ui_legendary;
- (void) reposition;
@end

@implementation UnitDisplay
@synthesize position = _position;
@synthesize background = _background;
@synthesize nameLabel = _nameLabel;
@synthesize dmgLabel = _dmgLabel;
@synthesize phy_defense = _phy_defense;
@synthesize mag_defense = _mag_defense;

@synthesize hpBar = _hpBar;
@synthesize currentHP = _currentHP;
@synthesize maxHP = _maxHP;

- (void) setBackground:(CCSprite *)background
{
    [_background setTexture:[background texture]];
    if ( [background isEqual:_ui_vagrant] ) {
        [self setFontColor:ccWHITE];
    } else if ( [background isEqual:_ui_common] ) {
        [self setFontColor:ccWHITE];
    } else if ( [background isEqual:_ui_uncommon] ) {
        [self setFontColor:ccBLACK];
    } else if ( [background isEqual:_ui_rare] ) {
        [self setFontColor:ccBLACK];
    } else if ( [background isEqual:_ui_epic] ) {
        [self setFontColor:ccWHITE];
    } else if ( [background isEqual:_ui_legendary] ) {
        [self setFontColor:ccWHITE];
    }
}

- (void) setPosition:(CGPoint)position
{
    _position = position;
    [self reposition];
}

- (void) setFontColor:(ccColor3B)color
{
    self.nameLabel.color = color;
    self.dmgLabel.color = color;
    self.phy_defense.color = color;
    self.mag_defense.color = color;
    self.currentHP.color = color;
    self.maxHP.color = color;
}

+ (id) displayWithPosition:(CGPoint)position
{
    return [[self alloc] initWithPosition:position];
}
- (id) initWithPosition:(CGPoint)position
{
    self = [super init];
    if ( self )
    {
        self.position = position;

        // Background;
        _background = [CCSprite spriteWithFile:@"ui_vagrant.png"];
        _ui_vagrant = [CCSprite spriteWithFile:@"ui_vagrant.png"];
        _ui_common = [CCSprite spriteWithFile:@"ui_common.png"];
        _ui_uncommon = [CCSprite spriteWithFile:@"ui_uncommon.png"];
        _ui_rare = [CCSprite spriteWithFile:@"ui_rare.png"];
        _ui_epic = [CCSprite spriteWithFile:@"ui_epic.png"];
        _ui_legendary = [CCSprite spriteWithFile:@"ui_legendary.png"];
        
        // The hp bar
        ccColor3B inital = {0,255,0};
        _hpBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"hp_bar.png"]];
        _hpBar.color = inital;
        _hpBar.type = kCCProgressTimerTypeBar;
        _hpBar.percentage = 100;  // initially nothing
        _hpBar.barChangeRate = ccp(1,0); // set to no vertical changes
        _hpBar.midpoint = ccp(0.0, 0.0f); // set the bar to move left to right
        
        _currentHP = [CCLabelBMFont labelWithString:@"-" fntFile:@"emulator.fnt"];
        _currentHP.scale = 0.9;
        _currentHP.anchorPoint = ccp(1.0f,0.5f);
        
        _maxHP = [CCLabelBMFont labelWithString:@"-" fntFile:@"emulator.fnt"];
        _maxHP.scale = 0.9;
        _maxHP.anchorPoint = ccp(0.0f,0.5f);
        
        // the dmg and move stats
        _nameLabel = [CCLabelBMFont labelWithString:@"NAME Lv.0" fntFile:@"emulator.fnt"];
        _nameLabel.scale = 1;
        _nameLabel.anchorPoint = ccp(0.0f,0.5f);
        _dmgLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"emulator.fnt"];
        _dmgLabel.scale = 0.8;
        _dmgLabel.anchorPoint = ccp(0.0f,0.5f);
        _phy_defense = [CCLabelBMFont labelWithString:@"0" fntFile:@"emulator.fnt"];
        _phy_defense.scale = 0.8;
        _phy_defense.anchorPoint = ccp(0.0f,0.5f);
        _mag_defense = [CCLabelBMFont labelWithString:@"0" fntFile:@"emulator.fnt"];
        _mag_defense.scale = 0.8;
        _mag_defense.anchorPoint = ccp(0.0f,0.5f);
        
        
        [self reposition];
        [self addChild:_background z:0];
        [self addChild:_nameLabel z:1];
        [self addChild:_dmgLabel z:1];
        [self addChild:_phy_defense z:1];
        [self addChild:_mag_defense z:1];
        [self addChild:_hpBar z:-1];
        [self addChild:_currentHP z:1];
        [self addChild:_maxHP z:1];

        self.visible = NO;
    }
    return self;
}

- (void) reposition
{
    self.background.position = ccpAdd(self.position, CGPointZero);
    self.nameLabel.position = ccpAdd(self.position, ccp(-55,35));
    self.dmgLabel.position = ccpAdd(self.position, ccp(-57,2));
    self.phy_defense.position = ccpAdd(self.position, ccp(-26,2));
    self.mag_defense.position = ccpAdd(self.position, ccp(5,2));
    self.hpBar.position = ccpAdd(self.position, ccp(0,1));
    self.currentHP.position = ccpAdd(self.position, ccp(19,28));
    self.maxHP.position = ccpAdd(self.position, ccp(26,25));
}

- (void) setDisplayFor:(Tile *) tile
{
    NSLog(@">[MYLOG] Setting display for tile %@",tile);
    if (tile.unit != nil)
    {
        if      ( tile.unit->rarity == VAGRANT )  self.background = _ui_vagrant;
        else if ( tile.unit->rarity == COMMON )   self.background = _ui_common;
        else if ( tile.unit->rarity == UNCOMMON ) self.background = _ui_uncommon;
        else if ( tile.unit->rarity == RARE )     self.background = _ui_rare;
        else if ( tile.unit->rarity == EPIC )     self.background = _ui_epic;
        
        [self.nameLabel setString:[[tile unit] description]];
        [self.dmgLabel setString:[NSString stringWithFormat:@"%d", tile.unit.attribute->damage]];
        [self.phy_defense setString:[NSString stringWithFormat:@"%d", (int)(tile.unit.attribute->phys_resist *100)]];
        [self.mag_defense setString:[NSString stringWithFormat:@"%d", (int)(tile.unit.attribute->magic_resist*100)]];
        [self.currentHP setString:[NSString stringWithFormat:@"%d", tile.unit->health]];
        [self.maxHP setString:[NSString stringWithFormat:@"%d", tile.unit.attribute->max_health]];
        
        [self setHPBar:tile];
        self.visible = YES;
        
        CGPoint pos = self.position;
        self.position = ccpAdd(self.position, ccp(0,100));
        [self reposition];
        [self runAction:[CCMoveTo actionWithDuration:0.5 position:pos]];
    }
    else
    {
        self.visible = NO;
    }
}

- (void) setHPBar:(Tile *)tile
{
    int percentage = (tile.unit->health*1.0/tile.unit.attribute->max_health)*100;
    int red, green;
    if (1){//[tile isOwned]) {
        red = (percentage <= 25)?255:(percentage >= 75)? 0:255 - 255.0f*(percentage+25)/50;
        green = (percentage <= 25)? 0:(percentage >= 75)? 255:255.0f*(percentage+25)/50;
        
    } /*else {
        red = 255;
        green = 0;
        
    }*/
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