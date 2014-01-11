//
//  PlayerResources.m
//  Legends
//
//  Created by David Zhang on 2014-01-07.
//
//

#import "PlayerResources.h"

@implementation PlayerResources
- (void) setTotalMana:(int)totalMana
{
    float percentChange = self.totalMana*1.0 / totalMana;
    _totalMana = totalMana;
    self.currMana *= percentChange;
}

- (void) setCurrCP:(int)currCP
{
    _currCP = currCP;
    _cpBar.percentage = 10 * currCP;
}

- (void) setCurrMana:(int)currMana
{
    _currMana = currMana;
    _manaBar.percentage = currMana*1.0/self.totalMana * 100;
    [self displayInfo];
}

+ (id) playerResource
{
    return [[PlayerResources alloc] initPlayerResource];
}

- (id) initPlayerResource
{
    self = [super init];
    if ( self ) {
        _totalMana = 1000;
        _currMana = 500;
        _manaRegen = 250;
        _totalCP = 10;
        _currCP = 10;
        
        // Default bar sprite
        CCSprite *bar1 = [CCSprite spriteWithFile:@"ui_resourcebar.png"];
        CCSprite *bar2 = [CCSprite spriteWithFile:@"ui_resourcebar.png"];
        
        // Mana bar frame + bar
        _manaBarFrame = [CCSprite spriteWithFile:@"ui_manabarframe.png"];
        _manaBarFrame.position = CGPointZero;
        _manaBarFrame.anchorPoint = ccp(0.0, 0.5);
        _manaBar = [CCProgressTimer progressWithSprite:bar1];
                _manaBar.position = CGPointZero;
        _manaBar.anchorPoint = ccp(0.0,0.5);

        _manaBar.type = kCCProgressTimerTypeBar;
        _manaBar.color = ccBLUE;
        _manaBar.midpoint = ccp(0.0, 0.5f);
        _manaBar.barChangeRate = ccp(1,0);
        _manaBar.percentage = 100;
        
        [self addChild:_manaBarFrame z:1];
        [self addChild:_manaBar z:0];
        
        // Command points bar
        _cpBarFrame = [CCSprite spriteWithFile:@"ui_cmdbarframe.png"];
        _cpBarFrame.position = ccp(0, -16);
        _cpBarFrame.anchorPoint = ccp(0.0, 0.5);
        _cpBar = [CCProgressTimer progressWithSprite:bar2];
        _cpBar.type = kCCProgressTimerTypeBar;
        _cpBar.color = ccYELLOW;
        _cpBar.midpoint = ccp(0.0, 0.5f);
        _cpBar.barChangeRate = ccp(1,0);
        _cpBar.percentage = 100;
        _cpBar.anchorPoint = ccp(0.0,0.5);
        _cpBar.position = ccp(0, -16);
        
        [self addChild:_cpBarFrame z:1];
        [self addChild:_cpBar z:0];
        
        _display = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _display.position = ccp(160,0);
        _display.anchorPoint = ccp(0.5, 0.5);
        _display.color = ccWHITE;
        _display.visible = NO;
        [self addChild:_display];
        
        [self displayInfo];
    }
    return self;
}

- (BOOL) canCastMana:(int)manaCost cmd:(int)cp
{
    return ( manaCost <= self.currMana && cp <= self.currCP ) ? YES : NO;
}

- (void) castMana:(int)manaCost cmd:(int)cp
{
    if ( [self canCastMana:manaCost cmd:cp] ) {
        self.currMana -= manaCost;
        self.currCP -= cp;
    }
}

- (void) deathTo:(Unit *)unit
{
    self.totalMana-= [unit mana];
}

- (void) reset
{
    // Add one totalCP if totalCP < 10 and set curr
    self.totalCP = MIN(10, self.totalCP+1);
    self.currCP = self.totalCP;
    
    // Add manaRegen to currMana cap totalMana
    self.currMana = MIN(self.totalMana, self.currMana+self.manaRegen);
}

- (void) displayInfo
{
    NSString *manaString = [NSString stringWithFormat:@"%d/%d", self.currMana, self.totalMana];
    self.display.string = manaString;
    
    id visible = [CCCallBlock actionWithBlock:^{self.display.visible = YES;}];
    id fadeout = [CCFadeOut actionWithDuration:2.5];
    id invisible = [CCCallBlock actionWithBlock:^{self.display.visible = NO;}];
    
    [_display runAction:[CCSequence actions:visible, fadeout, invisible, nil]];
}
@end
