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

@property (nonatomic, strong)   CCLabelBMFont *displayCD;
@property (nonatomic, strong)   CCLabelBMFont *displayMC;
@property (nonatomic, strong)   CCLabelBMFont *displayCP;
@property (nonatomic)                     int buttonCD;
@property (nonatomic)                     int buttonMC;
@property (nonatomic)                     int buttonCP;

@property (nonatomic)                      int manaCost;
@property (nonatomic)                      int cmdCost;
@property (nonatomic)                   Action type;
@property (nonatomic)          ActionRangeType rangeType;
@property (nonatomic)                      int range;
@property (nonatomic)          ActionRangeType effectType;
@property (nonatomic)                      int effect;

// For RangeUnique
@property (nonatomic, strong)   NSMutableArray *areaOfRange;
@property (nonatomic, strong)   NSMutableArray *areaOfEffect;
@end

@interface UnitSkillOne : UnitSkill
@property (nonatomic)                   BOOL isUsed;
@end
