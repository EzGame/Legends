//
//  Constants.h
//  Legends
//
//  Created by David Zhang on 2013-11-13.
//
//

#ifndef Legends_Constants_h
#define Legends_Constants_h

#define DEVMODE 1
#define VERSION 0.5



#define GAMETILEWIDTH 64
#define GAMETILEHEIGHT 32
#define GAMETILEOFFSETX 353
#define GAMETILEOFFSETY 14
#define SETUPTILEOFFSETX 293
#define SETUPTILEOFFSETY 38

#define GAMEMAPWIDTH 11
#define GAMEMAPHEIGHT 11
#define SETUPMAPWIDTH 11
#define SETUPMAPHEIGHT 5
#define LASTMAPWIDTH GAMEMAPWIDTH-1
#define LASTMAPHEIGHT GAMEMAPHEIGHT-1

#define CGPointFlag CGPointMake(-1337,0)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

typedef enum {
    NE,
    NW,
    SW,
    SE,
}Direction;

typedef enum Rarity {
    Vagrant,
    Common,
    Uncommon,
    Rare,
    Epic,
}Rarity;

typedef enum {
    Strength,
    Agility,
    Intellect,
    Spirit,
    Health
}Attribute;

typedef enum {
    UnitTypeNone,
    
    // common
    UnitTypePriest,
    UnitTypeWarrior,
    UnitTypeWitch,
    UnitTypeRanger,
    UnitTypeLastCommon = UnitTypeRanger,
    
    // uncommon
    UnitTypeKnight,
    UnitTypeBerserker,
    UnitTypePaladin,
    UnitTypeLastUnc = UnitTypePaladin,

    UnitTypeLast = UnitTypePaladin,
}UnitType;

/* Keep this in alternating on/off */
typedef enum {
    HighlightModeRange,
    HighlightModeRangeOff,
    HighlightModeEffect,
    HighlightModeEffectOff,
}HighlightMode;

typedef enum {
    TurnStateA,
    TurnStateB,
    TurnStateC,
    TurnStateD,
    TurnStateX,
}TurnState;

typedef enum {
    ActionUnknown,
    ActionIdle,
    ActionDie,
    ActionSkillOne,
    ActionSkillTwo,
    ActionSkillThree,
    ActionMove,
    ActionTeleport,
    ActionStop,
    /*  Other  */
    ActionEndTurn,
}Action;

typedef enum {
    RangeNormal,
    RangeNormalInc,
    RangeNormalForce,
    RangeNormalIncForce,
    RangeOne,
    RangePathFind,
    RangeLOS,
    RangeAllied,
    RangeEnemy,
    RangeUnique,
} ActionRangeType;

typedef enum {
    BuffEventAttack,
    BuffEventDefense,
} BuffEvent;

typedef enum {
    CombatTypeStr,
    CombatTypeAgi,
    CombatTypeInt,
    CombatTypePure,
    CombatTypeHeal,
} CombatType;

typedef enum Heart {
    VoidHeart,       // nothing
    
    IronHeart,       // +str -agi        [done]
    MuscleHeart,     // +str -int        [done]
    VindictiveHeart, // +str -spr        [done]
    BraveHeart,      // +str -hp         [done]
    
    NimbleHeart,     // +agi -str        [done] stats
    JesterHeart,     // +agi -int        [done]
    SilentHeart,     // +agi -spr
    SavageHeart,     // +agi -hp         [done]
    
    CunningHeart,    // +int -str
    SageHeart,       // +int -agility
    LogicalHeart,    // +int -spr        [done]
    GiftedHeart,     // +int -hp
    
    DevoutHeart,     // +spr -str
    SaintlyHeart,    // +spr -agi
    FaithfulHeart,   // +spr -int        [done]
    HolyHeart,       // +spr -hp         [done]
    
    RoyalHeart,      // +hp  -str        [done]
    TitanHeart,      // +hp  -agi        [done]
    ThickHeart,      // +hp  -int        [done]
    UnholyHeart,     // +hp  -spr        [done]
}Heart;

#endif
