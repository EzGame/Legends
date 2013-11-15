//
//  UnitButton.h
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//
#import "cocos2d.h"
#import "Defines.h"
#import "GeneralUtils.h"
#import "CCMenuItem.h"


@interface UnitButton : CCMenuItemSprite <CCRGBAProtocol>

@property (nonatomic, strong)   CCLabelBMFont *displayCD;
@property (nonatomic, strong)   CCLabelBMFont *displayMC;
@property (nonatomic)                     int buttonCD;
@property (nonatomic)                     int buttonMC;
@property (nonatomic)                    BOOL isUsed;

+ (id) UnitButtonWithName:(NSString *)name
                       CD:(int)CD
                       MC:(int)MC
                   target:(id)target
                 selector:(SEL)selector;
@end