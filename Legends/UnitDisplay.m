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
@synthesize tilePtr = _tilePtr;

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
        [self setFontColor:ccAQUAMARINE];
    } else if ( [background isEqual:_ui_uncommon] ) {
        [self setFontColor:ccBLACK];
    } else if ( [background isEqual:_ui_rare] ) {
        [self setFontColor:ccDARKBLUE];
    } else if ( [background isEqual:_ui_epic] ) {
        [self setFontColor:ccLIGHTGREEN];
    } else if ( [background isEqual:_ui_legendary] ) {
        [self setFontColor:ccDARKGOLDENROD];
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
        pos = position;
        self.position = ccpAdd(position, ccp(0,100));

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
        _hpBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"ui_hp_bar.png"]];
        _hpBar.type = kCCProgressTimerTypeBar;
        _hpBar.color = inital;
        _hpBar.midpoint = ccp(0.0, 0.5f); // set the bar to move left to right
        _hpBar.barChangeRate = ccp(1,0); // set to no vertical changes
        _hpBar.percentage = 100;  // initially nothing
        
        _currentHP = [CCLabelBMFont labelWithString:@"-" fntFile:NORMALFONTSMALL];
        _currentHP.scale = 0.9;
        _currentHP.anchorPoint = ccp(1.0f,0.5f);
        
        _maxHP = [CCLabelBMFont labelWithString:@"-" fntFile:NORMALFONTSMALL];
        _maxHP.scale = 0.9;
        _maxHP.anchorPoint = ccp(0.0f,0.5f);
        
        // the dmg and move stats
        _nameLabel = [CCLabelBMFont labelWithString:@"NAME Lv.0" fntFile:NORMALFONTMID];
        _nameLabel.scale = 1;
        _nameLabel.anchorPoint = ccp(0.0f,0.5f);
        _dmgLabel = [CCLabelBMFont labelWithString:@"0" fntFile:NORMALFONTBIG];
        _dmgLabel.scale = 0.8;
        _dmgLabel.anchorPoint = ccp(0.0f,0.5f);
        _phy_defense = [CCLabelBMFont labelWithString:@"0" fntFile:NORMALFONTBIG];
        _phy_defense.scale = 0.8;
        _phy_defense.anchorPoint = ccp(0.0f,0.5f);
        _mag_defense = [CCLabelBMFont labelWithString:@"0" fntFile:NORMALFONTBIG];
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

        self.visible = YES;
    }
    return self;
}

- (void) reposition
{
    self.background.position = ccpAdd(self.position, CGPointZero);
    self.nameLabel.position = ccpAdd(self.position, ccp(-60,32));
    self.dmgLabel.position = ccpAdd(self.position, ccp(-57,2));
    self.phy_defense.position = ccpAdd(self.position, ccp(-26,2));
    self.mag_defense.position = ccpAdd(self.position, ccp(5,2));
    self.hpBar.position = ccpAdd(self.position, ccp(0,1));
    self.currentHP.position = ccpAdd(self.position, ccp(16,26));
    self.maxHP.position = ccpAdd(self.position, ccp(24,24));
}

- (void) setDisplayFor:(Tile *) tile
{
    if ( tile.unit != nil  )
    {
        if ( [tile.unit isEqual:self.tilePtr.unit] )
            return;
        
        NSLog(@">[MYLOG] Setting display for tile %@",tile);
        self.tilePtr = tile;
        /*if      ( tile.unit->rarity == VAGRANT )  self.background = _ui_vagrant;
        else if ( tile.unit->rarity == COMMON )   self.background = _ui_common;
        else if ( tile.unit->rarity == UNCOMMON ) self.background = _ui_uncommon;
        else if ( tile.unit->rarity == RARE )     self.background = _ui_rare;
        else if ( tile.unit->rarity == EPIC )     self.background = _ui_epic;
        
        [self.nameLabel setString:[[tile unit] description]];
        [self.dmgLabel setString:[NSString stringWithFormat:@"%d", tile.unit.attribute->damage]];
        [self.phy_defense setString:[NSString stringWithFormat:@"%d", (int)(tile.unit.attribute->phys_resist *100)]];
        [self.mag_defense setString:[NSString stringWithFormat:@"%d", (int)(tile.unit.attribute->magic_resist*100)]];
        [self.currentHP setString:[NSString stringWithFormat:@"%d", tile.unit->health]];
        [self.maxHP setString:[NSString stringWithFormat:@"%d", tile.unit.attribute->max_health]];*/
        
        [self setHPBar:tile];
        
        self.position = ccpAdd(self.position, ccp(0,100));
        [self runAction:[CCMoveTo actionWithDuration:0.5 position:pos]];
    }
    else
    {
        NSLog(@">[MYLOG] Not setting display for tile %@",tile);
        self.tilePtr = nil;
        self.position = ccpAdd(self.position, ccp(0,100));
    }
}

- (void) setHPBar:(Tile *)tile
{
    /*float percentage = (tile.unit->health*1.0/tile.unit.attribute->max_health)*100;
    int red, green;
    if (1){//[tile isOwned]) {
        red = (percentage <= 25)?255:(percentage >= 75)? 0:255 - 255.0f*(percentage+25)/50;
        green = (percentage <= 25)? 0:(percentage >= 75)? 255:255.0f*(percentage+25)/50;
        
    }
    
    ccColor3B newColor = {red, green, 0};
    [self.hpBar setPercentage:percentage];
    self.hpBar.color = newColor;*/
}

@end
/***************************************************************/


@implementation OpponentDisplay

+ (id) displayWithPos:(CGPoint)position withUser:(SFSUser *)user
{
    return [[OpponentDisplay alloc] initWithPos:position withUser:user];
}

- (id) initWithPos:(CGPoint)position withUser:(SFSUser *)user
{
    self = [super init];
    if ( self ) {

    }
    return self;
}

@end



/***************************************************************/
@implementation SetupUnitDisplay
@synthesize position = _position;
@synthesize background = _background;
@synthesize nameLabel = _nameLabel;
@synthesize description = _description;

- (void) setPosition:(CGPoint)position
{
    _position = position;
    [self reposition];
}

+ (id) displayWithPosition:(CGPoint)position
{
    return [[SetupUnitDisplay alloc] initWithPosition:position];
}

- (id) initWithPosition:(CGPoint)position
{
    self = [super init];
    if ( self ) {
        //self.position = ccpAdd(position, ccp(0,100));
        
        // Background;
        _background = [CCSprite spriteWithFile:@"test-bg.png"];
        _background.anchorPoint = ccp(0.0f,0.0f);
        // the dmg and move stats
        _nameLabel = [CCLabelBMFont labelWithString:@"NAME Lv.0" fntFile:NORMALFONTMID];
        _nameLabel.scale = 1;
        _nameLabel.anchorPoint = ccp(0.0f,0.5f);
        _description = [CCLabelBMFont labelWithString:@"-" fntFile:@"test_epic.fnt"];
        _description.scale = 1;
        _description.anchorPoint = ccp(0.0f,0.5f);
        
        [self reposition];
        [self addChild:_background z:0];
        [self addChild:_nameLabel z:1];
        [self addChild:_description z:1];
        
        self.visible = NO;
    }
    return self;
}

- (void) reposition
{
    self.background.position = ccpAdd(self.position, CGPointZero);
    self.nameLabel.position = ccpAdd(self.position, ccp(0,40));
    self.description.position = ccpAdd(self.position, ccp(0,18));
}

//- (void) setDisplayFor:(SetupTile *) tile
//{
    /*
    if ( tile.unit != nil  )
    {
        if ( [tile.unit isEqual:self.tilePtr.unit] )
            return;
        
        NSLog(@">[MYLOG] Setting display for tile %@",tile);
        self.tilePtr = tile;
        
        [self.nameLabel setString:[[tile unit] description]];
        if ( tile.unit.attribute->rarity == COMMON )        [self.description setFntFile:@"test_com.fnt"];
        else if ( tile.unit.attribute->rarity == UNCOMMON ) [self.description setFntFile:@"test_unc.fnt"];
        else if ( tile.unit.attribute->rarity == RARE )     [self.description setFntFile:@"test_rare.fnt"];
        else if ( tile.unit.attribute->rarity == EPIC )     [self.description setFntFile:@"test_epic.fnt"];
        [self.description setString:
         [NSString stringWithFormat:
          @"\\STR:%03d \\AGI:%03d \\INT:%03d\n\\DMG:%04d \\PHY:%03d%% \\MAG:%03d%%\n",
          [tile.unit.attribute getStr],
          [tile.unit.attribute getAgi],
          [tile.unit.attribute getInt],
          tile.unit.attribute->damage,
          (int)(tile.unit.attribute->phys_resist*100),
          (int)(tile.unit.attribute->magic_resist*100)]];
    }
    else
    {
        NSLog(@">[MYLOG] Not setting display for tile %@",tile);
        self.tilePtr = nil;
        self.visible = NO;
    }*/
//}

- (void) setPosition:(CGPoint)position x:(BOOL)x y:(BOOL)y
{
//    if ( self.tilePtr != nil ) {
//        CGPoint offset = CGPointMake((x)?0:-225,(y)?50:-60);
//        [self setPosition:ccpAdd(position,offset)];
//        self.visible = YES;
//        self.description.visible = NO;
//        self.nameLabel.visible = NO;
//        id start = [CCSpawn actionOne:[CCActionTween actionWithDuration:0.3 key:@"scaleX" from:0 to:1] two:[CCFadeIn actionWithDuration:0.15]];
//        id display = [CCCallBlock actionWithBlock:^{
//            self.description.visible = YES;
//            self.nameLabel.visible = YES;
//            [self.description runAction:[CCFadeIn actionWithDuration:0.2]];
//            [self.nameLabel runAction:[CCFadeIn actionWithDuration:0.2]];}];
//        [self.background runAction:[CCSequence actionOne:start two:display]];
//    }
}

- (void) formatString:(NSString *)input
{
#define MAXSTRWIDTH 100
    int i, length = [input length];
    NSMutableString *string = [input mutableCopy];
    for ( i = 1; i <= length/MAXSTRWIDTH; i++) {
        NSRange index = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]
                                                options:NSBackwardsSearch
                                                  range:NSMakeRange((i-1)*MAXSTRWIDTH, i*MAXSTRWIDTH)];
        [string insertString:@"\n" atIndex:index.location];
    }
    NSLog(@">[MYLOG]    Formatted string to:\n%@",string);
    [self.description setString:string];
}
@end