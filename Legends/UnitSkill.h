//
//  UnitSkill.h
//  Legends
//
//  Created by David Zhang on 2014-01-08.
//
//

#import "cocos2d.h"
#import "Defines.h"
#import "GeneralUtils.h"
#import "CCMenuItem.h"

@interface UnitSkill : CCMenuItemSprite <CCRGBAProtocol>
@property (nonatomic)                  Action type;

@property (nonatomic, strong)  NSMutableArray *areaOfRange;
@property (nonatomic, strong)  NSMutableArray *areaOfEffect;
@property (nonatomic)         ActionRangeType rangeType;
@property (nonatomic)         ActionRangeType effectType;
@property (nonatomic)                     int range;
@property (nonatomic)                     int effect;

@property (nonatomic, strong)   CCLabelBMFont *displayCD;
@property (nonatomic, strong)   CCLabelBMFont *displayMC;
@property (nonatomic, strong)   CCLabelBMFont *displayCP;
@property (nonatomic)                     int cdCost;
@property (nonatomic)                     int manaCost;
@property (nonatomic)                     int cpCost;
@property (nonatomic)                    BOOL isUsed;

+ (id) unitSkill:(NSString *)name target:(id)target selector:(SEL)sel
              CD:(int)CD MC:(int)MC CP:(int)CP;
@end