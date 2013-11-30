//
//  Defines.h
//  Legnds
//
//  Created by David Zhang on 2013-01-26.
//
//  This file will include all the defines used across the app

#import "cocos2d.h"


#define LEGEND_VERSION 0x0000101


#pragma mark - ENUMERATIONS
// THE FOLLOWING ARE UNIT TYPE DEFINITIONS


// THE FOLLOWING ARE DIRECTION DEFINITIONS


// TILESET GIDS
enum GID {
    EMPTY = 0,
    PLAIN_GRASS_TO_MOLTEN_START = 1,
    PLAIN_GRASS_TO_MOLTEN_END = 6,
}typedef GID;

// THE FOLLOWING ARE THE ZORDERS OF THE LAYERS
// Z orders order the order they appear
// Please keep this list sorted


// ITEM - GEMS
enum GEMS {
    TOPAZ       = 1, // lightning
    SAPPHIRE    = 2, // water
    RUBY        = 3, // fire
    EMERALD     = 4, // nature
    OPAL        = 5, // earth
}typedef GEMS;


/*   typedef enums   */
typedef enum {
    SkillDamageTypeNormalMelee,
    SkillDamageTypeNormalRange,
    SkillDamageTypeNormalMagic,
    SkillDamageTypeNormalHeal,
    SkillDamageTypePureMelee,
    SkillDamageTypePureRange,
    SkillDamageTypePureMagic,
}SkillDamageType;

typedef enum {
    SkillTypePrimary,
    SkillTypeSecondary,
    SkillTypeTertiary,
}SkillType;

typedef enum {
    /*  Basic Events  */
    EventUnknown,
    EventSelect,
    EventReset,
    /*  Action Events  */
    EventMove,
    EventTeleport,
    EventPhysicalAttack,
    EventSpellCast
}Event;

typedef enum {
    BuffTypeOne,
}BuffType;

enum ZORDER {
    HUDLAYER        = 200,
    GAMELAYER       = 1,
    MENUS           = 100,
    DISPLAYS        = 95,
    EFFECTS         = 25,
    SPRITES_TOP     = 20,
    SPRITES_BOT     = 10,
    GROUND          = 1,
    MAP             = 0,
}typedef ZORDER;

#pragma mark - DEFINES
#define kTagBattleLayer 10
#define kTagSetupLayer 11
#define kTagForgeLayer 12

// Various map information
#define MAPLENGTH   11
#define MAPWIDTH    11
#define MAPSCALE    1
#define TILELENGTH  128*0.5
#define TILEWIDTH   96*0.5
#define HALFLENGTH  64.0*0.5
#define HALFWIDTH   48.0*0.5
#define OFFSETX     308
#define OFFSETY     -24

// Various setup information
#define SETUPMAPLENGTH   11
#define SETUPMAPWIDTH    5
#define SETUPSIDEMAPWIDTH 3
#define SETUPMAPSCALE    0.9
#define SETUPTILELENGTH  128*0.5*SETUPMAPSCALE
#define SETUPTILEWIDTH   96*0.5*SETUPMAPSCALE
#define SETUPHALFLENGTH  64.0*0.5*SETUPMAPSCALE
#define SETUPHALFWIDTH   48.0*0.5*SETUPMAPSCALE
#define SETUPOFFSETX     270
#define SETUPOFFSETY    -24.4

// Inventory information
#define SLOTLENGTH 52
#define SLOTWIDTH 51
#define FIRSTSLOTXOFFSET 11
#define FIRSTSLOTYOFFSET 12
#define SPACEBETWEENSLOTS 1

// Other information
#define MAXPATH     10
#define MAXUNITS    10
#define HPBARLENGTH 200
#define HPBARWIDTH  29
#define IDLETAG     69

// Default Player information
#define DEFAULTELO 1000
#define DEFAULTTELO 1000
#define PROLVL 1400
#define MASTERLVL 1700
#define GRANDMASTERLVL 1900
#define DEFAULTK 32
#define PROK 24
#define MASTERK 16
#define GRANDMASTERK 10

// MM Constants
#define MAXELORANGE 200
#define MAXWAITTIME 300 // seconds
#define RANGEINCRATE 2



#pragma mark - CONSTANTS
NSString extern *NORMALFONTBIG;
NSString extern *NORMALFONTMID;
NSString extern *NORMALFONTSMALL;
NSString extern *COMBATFONTBIG;
NSString extern *COMBATFONTMID;
NSString extern *COMBATFONTSMALL;
NSString extern *NOTICEFONT;

// allowable rune upgrades
int extern const gorgon_upgrades[];
int extern const mudgolem_upgrades[];
int extern const dragon_upgrades[];
int extern const lionpriest_upgrades[];

#pragma mark - GORGON AREAS
CGPoint extern const gorgonShootArea[];
CGPoint extern const gorgonShootEffect[];
CGPoint extern const gorgonFreezeArea[];
CGPoint extern const gorgonFreezeEffect[];

#pragma mark - MUD GOLEM AREAS
CGPoint extern const mudgolemAttkArea[];
CGPoint extern const mudgolemAttkEffect[];
CGPoint extern const mudgolemEarthquakeArea[];
CGPoint extern const mudgolemEarthquakeEffect[];

#pragma mark - DRAGON AREAS
CGPoint extern const dragonFireballArea[];
CGPoint extern const dragonFireballEffect[];
CGPoint extern const dragonFlamebreathArea[];
CGPoint extern const dragonFlamebreathEffect[];

#pragma mark - LION MAGE AREAS
CGPoint extern const lionmageHealArea[];
CGPoint extern const lionmageHealEffect[];


#pragma mark - Auto complete data structure
int extern const unitsByTag[];

#pragma mark - COLOURS
// THE FOLLOWING ARE COLOR DEFINITIONS
//! AliceBlue color (240,248,255)
extern const ccColor3B ccALICEBLUE;
//! AntiqueWhite color (250,235,215)
extern const ccColor3B ccANTIQUEWHITE;
//! Aqua color (0,255,255)
extern const ccColor3B ccAQUA;
//! Aquamarine color (127,255,212)
extern const ccColor3B ccAQUAMARINE;
//! Azure color (240,255,255)
extern const ccColor3B ccAZURE;
//! Beige color (245,245,220)
extern const ccColor3B ccBEIGE;
//! Bisque color (255,228,196)
extern const ccColor3B ccBISQUE;
//! BlanchedAlmond color (255,235,205)
extern const ccColor3B ccBLANCHEDALMOND;
//! BlueViolet color (138,43,226)
extern const ccColor3B ccBLUEVIOLET;
//! Brown color (165,42,42)
extern const ccColor3B ccBROWN;
//! BurlyWood color (222,184,135)
extern const ccColor3B ccBURLYWOOD;
//! CadetBlue color (95,158,160)
extern const ccColor3B ccCADETBLUE;
//! Chartreuse color (127,255,0)
extern const ccColor3B ccCHARTREUSE;
//! Chocolate color (210,105,30)
extern const ccColor3B ccCHOCOLATE;
//! Coral color (255,127,80)
extern const ccColor3B ccCORAL;
//! CornflowerBlue color (100,149,237)
extern const ccColor3B ccCORNFLOWERBLUE;
//! Cornsilk color (255,248,220)
extern const ccColor3B ccCORNSILK;
//! Crimson color (220,20,60)
extern const ccColor3B ccCRIMSON;
//! Cyan color (0,255,255)
extern const ccColor3B ccCYAN;
//! DarkBlue color (0,0,139)
extern const ccColor3B ccDARKBLUE;
//! DarkCyan color (0,139,139)
extern const ccColor3B ccDARKCYAN;
//! DarkGoldenRod color (184,134,11)
extern const ccColor3B ccDARKGOLDENROD;
//! DarkGray color (169,169,169)
extern const ccColor3B ccDARKGRAY;
//! DarkGreen color (0,100,0)
extern const ccColor3B ccDARKGREEN;
//! DarkKhaki color (189,183,107)
extern const ccColor3B ccDARKKHAKI;
//! DarkMagenta color (139,0,139)
extern const ccColor3B ccDARKMAGENTA;
//! DarkOliveGreen color (85,107,47)
extern const ccColor3B ccDARKOLIVEGREEN;
//! Darkorange color (255,140,0)
extern const ccColor3B ccDARKORANGE;
//! DarkOrchid color (153,50,204)
extern const ccColor3B ccDARKORCHID;
//! DarkRed color (139,0,0)
extern const ccColor3B ccDARKRED;
//! DarkSalmon color (233,150,122)
extern const ccColor3B ccDARKSALMON;
//! DarkSeaGreen color (143,188,143)
extern const ccColor3B ccDARKSEAGREEN;
//! DarkSlateBlue color (72,61,139)
extern const ccColor3B ccDARKSLATEBLUE;
//! DarkSlateGray color (47,79,79)
extern const ccColor3B ccDARKSLATEGRAY;
//! DarkTurquoise color (0,206,209)
extern const ccColor3B ccDARKTURQUOISE;
//! DarkViolet color (148,0,211)
extern const ccColor3B ccDARKVIOLET;
//! DeepPink color (255,20,147)
extern const ccColor3B ccDEEPPINK;
//! DeepSkyBlue color (0,191,255)
extern const ccColor3B ccDEEPSKYBLUE;
//! DimGray color (105,105,105)
extern const ccColor3B ccDIMGRAY;
//! DodgerBlue color (30,144,255)
extern const ccColor3B ccDODGERBLUE;
//! FireBrick color (178,34,34)
extern const ccColor3B ccFIREBRICK;
//! FloralWhite color (255,250,240)
extern const ccColor3B ccFLORALWHITE;
//! ForestGreen color (34,139,34)
extern const ccColor3B ccFORESTGREEN;
//! Fuchsia color (255,0,255)
extern const ccColor3B ccFUCHSIA;
//! Gainsboro color (220,220,220)
extern const ccColor3B ccGAINSBORO;
//! GhostWhite color (248,248,255)
extern const ccColor3B ccGHOSTWHITE;
//! Gold color (255,215,0)
extern const ccColor3B ccGOLD;
//! GoldenRod color (218,165,32)
extern const ccColor3B ccGOLDENROD;
//! GreenYellow color (173,255,47)
extern const ccColor3B ccGREENYELLOW;
//! HoneyDew color (240,255,240)
extern const ccColor3B ccHONEYDEW;
//! HotPink color (255,105,180)
extern const ccColor3B ccHOTPINK;
//! IndianRed color (205,92,92)
extern const ccColor3B ccINDIANRED;
//! Indigo color (75,0,130)
extern const ccColor3B ccINDIGO;
//! Ivory color (255,255,240)
extern const ccColor3B ccIVORY;
//! Khaki color (240,230,140)
extern const ccColor3B ccKHAKI;
//! Lavender color (230,230,250)
extern const ccColor3B ccLAVENDER;
//! LavenderBlush color (255,240,245)
extern const ccColor3B ccLAVENDERBLUSH;
//! LawnGreen color (124,252,0)
extern const ccColor3B ccLAWNGREEN;
//! LemonChiffon color (255,250,205)
extern const ccColor3B ccLEMONCHIFFON;
//! LightBlue color (173,216,230)
extern const ccColor3B ccLIGHTBLUE;
//! LightCoral color (240,128,128)
extern const ccColor3B ccLIGHTCORAL;
//! LightCyan color (224,255,255)
extern const ccColor3B ccLIGHTCYAN;
//! LightGoldenRodYellow color (250,250,210)
extern const ccColor3B ccLIGHTGOLDENRODYELLOW;
//! LightGrey color (211,211,211)
extern const ccColor3B ccLIGHTGREY;
//! LightGreen color (144,238,144)
extern const ccColor3B ccLIGHTGREEN;
//! LightPink color (255,182,193)
extern const ccColor3B ccLIGHTPINK;
//! LightSalmon color (255,160,122)
extern const ccColor3B ccLIGHTSALMON;
//! LightSeaGreen color (32,178,170)
extern const ccColor3B ccLIGHTSEAGREEN;
//! LightSkyBlue color (135,206,250)
extern const ccColor3B ccLIGHTSKYBLUE;
//! LightSlateGray color (119,136,153)
extern const ccColor3B ccLIGHTSLATEGRAY;
//! LightSteelBlue color (176,196,222)
extern const ccColor3B ccLIGHTSTEELBLUE;
//! LightYellow color (255,255,224)
extern const ccColor3B ccLIGHTYELLOW;
//! Lime color (0,255,0)
extern const ccColor3B ccLIME;
//! LimeGreen color (50,205,50)
extern const ccColor3B ccLIMEGREEN;
//! Linen color (250,240,230)
extern const ccColor3B ccLINEN;
//! Maroon color (128,0,0)
extern const ccColor3B ccMAROON;
//! MediumAquaMarine color (102,205,170)
extern const ccColor3B ccMEDIUMAQUAMARINE;
//! MediumBlue color (0,0,205)
extern const ccColor3B ccMEDIUMBLUE;
//! MediumOrchid color (186,85,211)
extern const ccColor3B ccMEDIUMORCHID;
//! MediumPurple color (147,112,216)
extern const ccColor3B ccMEDIUMPURPLE;
//! MediumSeaGreen color (60,179,113)
extern const ccColor3B ccMEDIUMSEAGREEN;
//! MediumSlateBlue color (123,104,238)
extern const ccColor3B ccMEDIUMSLATEBLUE;
//! MediumSpringGreen color (0,250,154)
extern const ccColor3B ccMEDIUMSPRINGGREEN;
//! MediumTurquoise color (72,209,204)
extern const ccColor3B ccMEDIUMTURQUOISE;
//! MediumVioletRed color (199,21,133)
extern const ccColor3B ccMEDIUMVIOLETRED;
//! MidnightBlue color (25,25,112)
extern const ccColor3B ccMIDNIGHTBLUE;
//! MintCream color (245,255,250)
extern const ccColor3B ccMINTCREAM;
//! MistyRose color (255,228,225)
extern const ccColor3B ccMISTYROSE;
//! Moccasin color (255,228,181)
extern const ccColor3B ccMOCCASIN;
//! NavajoWhite color (255,222,173)
extern const ccColor3B ccNAVAJOWHITE;
//! Navy color (0,0,128)
extern const ccColor3B ccNAVY;
//! OldLace color (253,245,230)
extern const ccColor3B ccOLDLACE;
//! Olive color (128,128,0)
extern const ccColor3B ccOLIVE;
//! OliveDrab color (107,142,35)
extern const ccColor3B ccOLIVEDRAB;
//! OrangeRed color (255,69,0)
extern const ccColor3B ccORANGERED;
//! Orchid color (218,112,214)
extern const ccColor3B ccORCHID;
//! PaleGoldenRod color (238,232,170)
extern const ccColor3B ccPALEGOLDENROD;
//! PaleGreen color (152,251,152)
extern const ccColor3B ccPALEGREEN;
//! PaleTurquoise color (175,238,238)
extern const ccColor3B ccPALETURQUOISE;
//! PaleVioletRed color (216,112,147)
extern const ccColor3B ccPALEVIOLETRED;
//! PapayaWhip color (255,239,213)
extern const ccColor3B ccPAPAYAWHIP;
//! PeachPuff color (255,218,185)
extern const ccColor3B ccPEACHPUFF;
//! Peru color (205,133,63)
extern const ccColor3B ccPERU;
//! Pink color (255,192,203)
extern const ccColor3B ccPINK;
//! Plum color (221,160,221)
extern const ccColor3B ccPLUM;
//! PowderBlue color (176,224,230)
extern const ccColor3B ccPOWDERBLUE;
//! Purple color (128,0,128)
extern const ccColor3B ccPURPLE;
//! RosyBrown color (188,143,143)
extern const ccColor3B ccROSYBROWN;
//! RoyalBlue color (65,105,225)
extern const ccColor3B ccROYALBLUE;
//! SaddleBrown color (139,69,19)
extern const ccColor3B ccSADDLEBROWN;
//! Salmon color (250,128,114)
extern const ccColor3B ccSALMON;
//! SandyBrown color (244,164,96)
extern const ccColor3B ccSANDYBROWN;
//! SeaGreen color (46,139,87)
extern const ccColor3B ccSEAGREEN;
//! SeaShell color (255,245,238)
extern const ccColor3B ccSEASHELL;
//! Sienna color (160,82,45)
extern const ccColor3B ccSIENNA;
//! Silver color (192,192,192)
extern const ccColor3B ccSILVER;
//! SkyBlue color (135,206,235)
extern const ccColor3B ccSKYBLUE;
//! SlateBlue color (106,90,205)
extern const ccColor3B ccSLATEBLUE;
//! SlateGray color (112,128,144)
extern const ccColor3B ccSLATEGRAY;
//! Snow color (255,250,250)
extern const ccColor3B ccSNOW;
//! SpringGreen color (0,255,127)
extern const ccColor3B ccSPRINGGREEN;
//! SteelBlue color (70,130,180)
extern const ccColor3B ccSTEELBLUE;
//! Tan color (210,180,140)
extern const ccColor3B ccTAN;
//! Teal color (0,128,128)
extern const ccColor3B ccTEAL;
//! Thistle color (216,191,216)
extern const ccColor3B ccTHISTLE;
//! Tomato color (255,99,71)
extern const ccColor3B ccTOMATO;
//! Turquoise color (64,224,208)
extern const ccColor3B ccTURQUOISE;
//! Violet color (238,130,238)
extern const ccColor3B ccVIOLET;
//! Wheat color (245,222,179)
extern const ccColor3B ccWHEAT;
//! WhiteSmoke color (245,245,245)
extern const ccColor3B ccWHITESMOKE;
//! YellowGreen color (154,205,50)
extern const ccColor3B ccYELLOWGREEN;