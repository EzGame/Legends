//
//  UnitSkill.m
//  Legends
//
//  Created by David Zhang on 2014-01-08.
//
//

#import "UnitSkill.h"

@implementation UnitSkill
+ (id) unitSkill:(NSString *)name target:(id)target selector:(SEL)sel
              CD:(int)CD MC:(int)MC CP:(int)CP
{
    return [[UnitSkill alloc] initUnitSkill:name target:target selector:sel CD:CD MC:MC CP:CP];
}

- (id) initUnitSkill:(NSString *)name target:(id)target selector:(SEL)sel
                  CD:(int)CD MC:(int)MC CP:(int)CP
{
    CCSprite *button = [CCSprite spriteWithFile:[NSString stringWithFormat:@"button_%@.png",name]];
    self = [super initWithNormalSprite:button
                        selectedSprite:nil
                        disabledSprite:Nil
                                target:target
                              selector:sel];
    if ( self ) {
        _isUsed = NO;
        _cpCost = CP;
        _cdCost = CD;
        _manaCost = MC;
        
        _displayCD = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _displayCD.anchorPoint = ccp(0.5, 0.5);
        _displayCD.position = ccp(10.0, 10.0);
        _displayCP = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _displayCP.anchorPoint = ccp(0.5, 0.5);
        _displayCP.position = ccp(10.0, 10.0);
        _displayMC = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _displayMC.anchorPoint = ccp(0.5, 0.5);
        _displayMC.position = ccp(10.0, 10.0);
        
        [self addChild:_displayCD z:1];
        [self addChild:_displayCP z:1];
        [self addChild:_displayMC z:1];
    }
    return self;
}

-(void) selected
{
    [super selected];
    if( isEnabled_ ) {
        [self setScale:0.8];
        [normalImage_ setVisible:YES];
        [selectedImage_ setVisible:NO];
        [disabledImage_ setVisible:NO];
    }
}

-(void) unselected
{
    [self setScale:1.0];
    [super unselected];
    [normalImage_ setVisible:YES];
    [selectedImage_ setVisible:NO];
    [disabledImage_ setVisible:NO];
}
@end
