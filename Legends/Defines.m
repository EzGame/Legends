#import "Defines.h"

NSString *NORMALFONTBIG = @"font_normal_big.fnt";
NSString *NORMALFONTMID = @"font_normal_mid.fnt";
NSString *NORMALFONTSMALL = @"font_normal_small.fnt";
NSString *COMBATFONTBIG = @"font_normal_big.fnt";
NSString *COMBATFONTMID = @"font_normal_mid.fnt";
NSString *COMBATFONTSMALL = @"font_normal_small.fnt";
NSString *NOTICEFONT = @"";

/*  UNIT BASE INFO */
const int test_stats[STATS_LASTINDEX] =
{LVLUP_STR, LVLUP_AGI, LVLUP_INT, LVLUP_WIS, LVLUP_HP, UNITRARITY};

const int minotaur_stats[STATS_LASTINDEX]    = {1, 0, 0, 0, 1, 3, COMMON};
const int lionpriest_stats[STATS_LASTINDEX]  = {0, 0, 0, 1, 1, 3, COMMON};
const int mudgolem_stats[STATS_LASTINDEX]    = {1, 0, 1, 0, 1, 4, UNCOMMON};
const int gorgon_stats[STATS_LASTINDEX]      = {0, 2, 1, 0, 1, 3, RARE};
const int dragon_stats[STATS_LASTINDEX]      = {1, 0, 1, 1, 1, 4, RARE};

const int minotaur_upgrades[]    = {TOPAZ, SAPPHIRE, RUBY, EMERALD, OPAL};
const int gorgon_upgrades[]      = {       SAPPHIRE, RUBY, EMERALD, OPAL};
const int mudgolem_upgrades[]    = {TOPAZ, SAPPHIRE, RUBY,          OPAL};
const int dragon_upgrades[]      = {TOPAZ,           RUBY, EMERALD, OPAL};
const int lionpriest_upgrades[]  = {TOPAZ, SAPPHIRE,       EMERALD, OPAL};

const CGPoint minotaurAttkArea[] = { {0,4},
    /*{-1,1},*/ {0,1}, /*{1,1},*/
      {-1,0}, /*{0,0},*/ {1,0},
    /*{-1,-1},*/{0,-1},/*{1,-1},*/
};
const CGPoint minotaurAttkEffect[] = {
    {0,1},
    {0,0} };

const CGPoint gorgonShootArea[] = { {0,84},
    /*{-6,6},   {-5,6},   {-4,6},   {-3,6},   {-2,6},   {-1,6},*/ {0,6}, /*{1,6},   {2,6},   {3,6},   {4,6},   {5,6},   {6,6},*/
    /*{-6,5},   {-5,5},   {-4,5},   {-3,5},   {-2,5},*/ {-1,5},   {0,5},   {1,5}, /*{2,5},   {3,5},   {4,5},   {5,5},   {6,5},*/
    /*{-6,4},   {-5,4},   {-4,4},   {-3,4},*/ {-2,4},   {-1,4},   {0,4},   {1,4},   {2,4}, /*{3,4},   {4,4},   {5,4},   {6,4},*/
    /*{-6,3},   {-5,3},   {-4,3},*/ {-3,3},   {-2,3},   {-1,3},   {0,3},   {1,3},   {2,3},   {3,3}, /*{4,3},   {5,3},   {6,3},*/
    /*{-6,2},   {-5,2},*/ {-4,2},   {-3,2},   {-2,2},   {-1,2},   {0,2},   {1,2},   {2,2},   {3,2},   {4,2}, /*{5,2},   {6,2},*/
    /*{-6,1},*/ {-5,1},   {-4,1},   {-3,1},   {-2,1},   {-1,1},   {0,1},   {1,1},   {2,1},   {3,1},   {4,1},   {5,1}, /*{6,1},*/
      {-6,0},   {-5,0},   {-4,0},   {-3,0},   {-2,0},   {-1,0}, /*{0,0},*/ {1,0},   {2,0},   {3,0},   {4,0},   {5,0},   {6,0},
    /*{-6,-1},*/{-5,-1},  {-4,-1},  {-3,-1},  {-2,-1},  {-1,-1},  {0,-1},  {1,-1},  {2,-1},  {3,-1},  {4,-1},  {5,-1},/*{6,-1},*/
    /*{-6,-2},  {-5,-2},*/{-4,-2},  {-3,-2},  {-2,-2},  {-1,-2},  {0,-2},  {1,-2},  {2,-2},  {3,-2},  {4,-2},/*{5,-2},  {6,-2},*/
    /*{-6,-3},  {-5,-3},  {-4,-3},*/{-3,-3},  {-2,-3},  {-1,-3},  {0,-3},  {1,-3},  {2,-3},  {3,-3},/*{4,-3},  {5,-3},  {6,-3},*/
    /*{-6,-4},  {-5,-4},  {-4,-4},  {-3,-4},*/{-2,-4},  {-1,-4},  {0,-4},  {1,-4},  {2,-4},/*{3,-4},  {4,-4},  {5,-4},  {6,-4},*/
    /*{-6,-5},  {-5,-5},  {-4,-5},  {-3,-5},  {-2,-5},*/{-1,-5},  {0,-5},  {1,-5},/*{2,-5},  {3,-5},  {4,-5},  {5,-5},  {6,-5},*/
    /*{-6,-6},  {-5,-6},  {-4,-6},  {-3,-6},  {-2,-6},  {-1,-6},*/{0,-6},/*{1,-6},  {2,-6},  {3,-6},  {4,-6},  {5,-6},  {6,-6},*/
};
const CGPoint gorgonShootEffect[] = {
    {0,1},
    {0,0} };

const CGPoint gorgonFreezeArea[] = { {0,40},
    /*{-4,4},   {-3,4},   {-2,4},   {-1,4},*/ {0,4}, /*{1,4},   {2,4},   {3,4},   {4,4},*/
    /*{-4,3},   {-3,3},   {-2,3},*/ {-1,3},   {0,3},   {1,3}, /*{2,3},   {3,3},   {4,3},*/
    /*{-4,2},   {-3,2},*/ {-2,2},   {-1,2},   {0,2},   {1,2},   {2,2}, /*{3,2},   {4,2},*/
    /*{-4,1},*/ {-3,1},   {-2,1},   {-1,1},   {0,1},   {1,1},   {2,1},   {3,1}, /*{4,1},*/
      {-4,0},   {-3,0},   {-2,0},   {-1,0}, /*{0,0},*/ {1,0},   {2,0},   {3,0},   {4,0},
    /*{-4,-1},*/{-3,-1},  {-2,-1},  {-1,-1},  {0,-1},  {1,-1},  {2,-1},  {3,-1},/*{4,-1},*/
    /*{-4,-2},  {-3,-2},*/{-2,-2},  {-1,-2},  {0,-2},  {1,-2},  {2,-2},/*{3,-2},  {4,-2},*/
    /*{-4,-3},  {-3,-3},  {-2,-3},*/{-1,-3},  {0,-3},  {1,-3},/*{2,-3},  {3,-3},  {4,-3},*/
    /*{-4,-4},  {-3,-4},  {-2,-4},  {-1,-4},*/{0,-4},/*{1,-4},  {2,-4},  {3,-4},  {4,-4},*/
};
const CGPoint gorgonFreezeEffect[] = {
    {0,1},
    {0,0}
};

/////////////////////////////////////////////////////////////////////////
// Mud Golem                                                           //
/////////////////////////////////////////////////////////////////////////
const CGPoint mudgolemAttkArea[] = { {0,4},
    /*{-1,1},*/ {0,1}, /*{1,1},*/
    {-1,0}, /*{0,0},*/ {1,0},
    /*{-1,-1},*/{0,-1},/*{1,-1},*/
};

const CGPoint mudgolemAttkEffect[] = {
    {0,1},
    {0,0}
};

const CGPoint mudgolemEarthquakeArea[] = {
    {0,1},
    {0,0}
};
const CGPoint mudgolemEarthquakeEffect[] = { {0,24},
    /*{-3,3},   {-2,3},   {-1,3},*/ {0,3}, /*{1,3},   {2,3},   {3,3},*/
    /*{-3,2},   {-2,2},*/ {-1,2},   {0,2},   {1,2}, /*{2,2},   {3,2},*/
    /*{-3,1},*/ {-2,1},   {-1,1},   {0,1},   {1,1},   {2,1}, /*{3,1},*/
      {-3,0},   {-2,0},   {-1,0}, /*{0,0},*/ {1,0},   {2,0},   {3,0},
    /*{-3,-1},*/{-2,-1},  {-1,-1},  {0,-1},  {1,-1},  {2,-1},/*{3,-1},*/
    /*{-3,-2},  {-2,-2},*/{-1,-2},  {0,-2},  {1,-2},/*{2,-2},  {3,-2},*/
    /*{-3,-3},  {-2,-3},  {-1,-3},*/{0,-3},/*{1,-3},  {2,-3},  {3,-3},*/
};

/////////////////////////////////////////////////////////////////////////
// Dragon                                                              //
/////////////////////////////////////////////////////////////////////////
const CGPoint dragonFireballArea[] = { {0,16},
    /*{-4,4},   {-3,4},   {-2,4},   {-1,4},*/ {0,4}, /*{1,4},   {2,4},   {3,4},   {4,4},*/
    /*{-4,3},   {-3,3},   {-2,3},   {-1,3},*/ {0,3}, /*{1,3},   {2,3},   {3,3},   {4,3},*/
    /*{-4,2},   {-3,2},   {-2,2},   {-1,2},*/ {0,2}, /*{1,2},   {2,2},   {3,2},   {4,2},*/
    /*{-4,1},   {-3,1},   {-2,1},   {-1,1},*/ {0,1}, /*{1,1},   {2,1},   {3,1},   {4,1},*/
      {-4,0},   {-3,0},   {-2,0},   {-1,0}, /*{0,0},*/ {1,0},   {2,0},   {3,0},   {4,0},
    /*{-4,-1},  {-3,-1},  {-2,-1},  {-1,-1},*/{0,-1},/*{1,-1},  {2,-1},  {3,-1},  {4,-1},*/
    /*{-4,-2},  {-3,-2},  {-2,-2},  {-1,-2},*/{0,-2},/*{1,-2},  {2,-2},  {3,-2},  {4,-2},*/
    /*{-4,-3},  {-3,-3},  {-2,-3},  {-1,-3},*/{0,-3},/*{1,-3},  {2,-3},  {3,-3},  {4,-3},*/
    /*{-4,-4},  {-3,-4},  {-2,-4},  {-1,-4},*/{0,-4},/*{1,-4},  {2,-4},  {3,-4},  {4,-4},*/
};

const CGPoint dragonFireballEffect[] = { {0,2}, {0,0} };

const CGPoint dragonFlamebreathArea[] = { {0,4},
    /*{-1,1},*/ {0,1},/* {1,1},*/
      {-1,0}, /*{0,0},*/ {1,0},
    /*{-1,-1},*/{0,-1},/*{1,-1},*/
};
const CGPoint dragonFlamebreathEffect[] = {
    /**/{NE,4}/**/,
    {1,1}, {0,1}, {-1,1},
    {0,0},
    /**/{SE,4}/**/,
    {-1,1},
    {0,0}, {-1,0},
    {-1,-1},
    /**/{SW,4}/**/,
            {0,0},
    {1,-1}, {0,-1}, {-1,-1},
    /**/{NW,4}/**/,
    {1,1},
    {1,0},  {0,0},
    {1,-1},
};

const CGPoint lionmageHealArea[] = {
    {0,1},
    {0,0}
};

const CGPoint lionmageHealEffect[] = {
    {0,0}
};

const int unitsByTag[] = {
// Rarity
/* Epic */          0,0,0,0,0,
/* Rare */          DRAGON,0,0,0,0,
/* Uncommon */      MUDGOLEM,GORGON,0,0,0,
/* Common */        MINOTAUR,LIONMAGE,0,0,0,
// Units
/* Minotaur */      MINOTAUR,0,0,0,0,
/* Gorgon */        GORGON,0,0,0,0,
/* Mud Golem */     MUDGOLEM,0,0,0,0,
/* Dragon */        DRAGON,0,0,0,0,
/* Lion Priest */   LIONMAGE,0,0,0,0,
// Main attribute + other
/* Strength */      MINOTAUR,MUDGOLEM,0,0,0,
/* Agility */       GORGON,0,0,0,0,
/* Intelligence */  LIONMAGE,DRAGON,0,0,0,
/* Melee */         MINOTAUR,MUDGOLEM,0,0,0,
/* Ranged */        GORGON,0,0,0,0,
/* Magic */         DRAGON,0,0,0,0,
/* Healer */        LIONMAGE,0,0,0,0,
/* Disabler */      GORGON,0,0,0,0,
/* Area of effect */MUDGOLEM,DRAGON,0,0,0,
};

//! AliceBlue color (240,248,255)
const ccColor3B ccALICEBLUE={240,248,255};
//! AntiqueWhite color (250,235,215)
const ccColor3B ccANTIQUEWHITE={250,235,215};
//! Aqua color (0,255,255)
const ccColor3B ccAQUA={0,255,255};
//! Aquamarine color (127,255,212)
const ccColor3B ccAQUAMARINE={127,255,212};
//! Azure color (240,255,255)
const ccColor3B ccAZURE={240,255,255};
//! Beige color (245,245,220)
const ccColor3B ccBEIGE={245,245,220};
//! Bisque color (255,228,196)
const ccColor3B ccBISQUE={255,228,196};
//! BlanchedAlmond color (255,235,205)
const ccColor3B ccBLANCHEDALMOND={255,235,205};
//! BlueViolet color (138,43,226)
const ccColor3B ccBLUEVIOLET={138,43,226};
//! Brown color (165,42,42)
const ccColor3B ccBROWN={165,42,42};
//! BurlyWood color (222,184,135)
const ccColor3B ccBURLYWOOD={222,184,135};
//! CadetBlue color (95,158,160)
const ccColor3B ccCADETBLUE={95,158,160};
//! Chartreuse color (127,255,0)
const ccColor3B ccCHARTREUSE={127,255,0};
//! Chocolate color (210,105,30)
const ccColor3B ccCHOCOLATE={210,105,30};
//! Coral color (255,127,80)
const ccColor3B ccCORAL={255,127,80};
//! CornflowerBlue color (100,149,237)
const ccColor3B ccCORNFLOWERBLUE={100,149,237};
//! Cornsilk color (255,248,220)
const ccColor3B ccCORNSILK={255,248,220};
//! Crimson color (220,20,60)
const ccColor3B ccCRIMSON={220,20,60};
//! Cyan color (0,255,255)
const ccColor3B ccCYAN={0,255,255};
//! DarkBlue color (0,0,139)
const ccColor3B ccDARKBLUE={0,0,139};
//! DarkCyan color (0,139,139)
const ccColor3B ccDARKCYAN={0,139,139};
//! DarkGoldenRod color (184,134,11)
const ccColor3B ccDARKGOLDENROD={184,134,11};
//! DarkGray color (169,169,169)
const ccColor3B ccDARKGRAY={169,169,169};
//! DarkGreen color (0,100,0)
const ccColor3B ccDARKGREEN={0,100,0};
//! DarkKhaki color (189,183,107)
const ccColor3B ccDARKKHAKI={189,183,107};
//! DarkMagenta color (139,0,139)
const ccColor3B ccDARKMAGENTA={139,0,139};
//! DarkOliveGreen color (85,107,47)
const ccColor3B ccDARKOLIVEGREEN={85,107,47};
//! Darkorange color (255,140,0)
const ccColor3B ccDARKORANGE={255,140,0};
//! DarkOrchid color (153,50,204)
const ccColor3B ccDARKORCHID={153,50,204};
//! DarkRed color (139,0,0)
const ccColor3B ccDARKRED={139,0,0};
//! DarkSalmon color (233,150,122)
const ccColor3B ccDARKSALMON={233,150,122};
//! DarkSeaGreen color (143,188,143)
const ccColor3B ccDARKSEAGREEN={143,188,143};
//! DarkSlateBlue color (72,61,139)
const ccColor3B ccDARKSLATEBLUE={72,61,139};
//! DarkSlateGray color (47,79,79)
const ccColor3B ccDARKSLATEGRAY={47,79,79};
//! DarkTurquoise color (0,206,209)
const ccColor3B ccDARKTURQUOISE={0,206,209};
//! DarkViolet color (148,0,211)
const ccColor3B ccDARKVIOLET={148,0,211};
//! DeepPink color (255,20,147)
const ccColor3B ccDEEPPINK={255,20,147};
//! DeepSkyBlue color (0,191,255)
const ccColor3B ccDEEPSKYBLUE={0,191,255};
//! DimGray color (105,105,105)
const ccColor3B ccDIMGRAY={105,105,105};
//! DodgerBlue color (30,144,255)
const ccColor3B ccDODGERBLUE={30,144,255};
//! FireBrick color (178,34,34)
const ccColor3B ccFIREBRICK={178,34,34};
//! FloralWhite color (255,250,240)
const ccColor3B ccFLORALWHITE={255,250,240};
//! ForestGreen color (34,139,34)
const ccColor3B ccFORESTGREEN={34,139,34};
//! Fuchsia color (255,0,255)
const ccColor3B ccFUCHSIA={255,0,255};
//! Gainsboro color (220,220,220)
const ccColor3B ccGAINSBORO={220,220,220};
//! GhostWhite color (248,248,255)
const ccColor3B ccGHOSTWHITE={248,248,255};
//! Gold color (255,215,0)
const ccColor3B ccGOLD={255,215,0};
//! GoldenRod color (218,165,32)
const ccColor3B ccGOLDENROD={218,165,32};
//! GreenYellow color (173,255,47)
const ccColor3B ccGREENYELLOW={173,255,47};
//! HoneyDew color (240,255,240)
const ccColor3B ccHONEYDEW={240,255,240};
//! HotPink color (255,105,180)
const ccColor3B ccHOTPINK={255,105,180};
//! IndianRed color (205,92,92)
const ccColor3B ccINDIANRED={205,92,92};
//! Indigo color (75,0,130)
const ccColor3B ccINDIGO={75,0,130};
//! Ivory color (255,255,240)
const ccColor3B ccIVORY={255,255,240};
//! Khaki color (240,230,140)
const ccColor3B ccKHAKI={240,230,140};
//! Lavender color (230,230,250)
const ccColor3B ccLAVENDER={230,230,250};
//! LavenderBlush color (255,240,245)
const ccColor3B ccLAVENDERBLUSH={255,240,245};
//! LawnGreen color (124,252,0)
const ccColor3B ccLAWNGREEN={124,252,0};
//! LemonChiffon color (255,250,205)
const ccColor3B ccLEMONCHIFFON={255,250,205};
//! LightBlue color (173,216,230)
const ccColor3B ccLIGHTBLUE={173,216,230};
//! LightCoral color (240,128,128)
const ccColor3B ccLIGHTCORAL={240,128,128};
//! LightCyan color (224,255,255)
const ccColor3B ccLIGHTCYAN={224,255,255};
//! LightGoldenRodYellow color (250,250,210)
const ccColor3B ccLIGHTGOLDENRODYELLOW={250,250,210};
//! LightGrey color (211,211,211)
const ccColor3B ccLIGHTGREY={211,211,211};
//! LightGreen color (144,238,144)
const ccColor3B ccLIGHTGREEN={144,238,144};
//! LightPink color (255,182,193)
const ccColor3B ccLIGHTPINK={255,182,193};
//! LightSalmon color (255,160,122)
const ccColor3B ccLIGHTSALMON={255,160,122};
//! LightSeaGreen color (32,178,170)
const ccColor3B ccLIGHTSEAGREEN={32,178,170};
//! LightSkyBlue color (135,206,250)
const ccColor3B ccLIGHTSKYBLUE={135,206,250};
//! LightSlateGray color (119,136,153)
const ccColor3B ccLIGHTSLATEGRAY={119,136,153};
//! LightSteelBlue color (176,196,222)
const ccColor3B ccLIGHTSTEELBLUE={176,196,222};
//! LightYellow color (255,255,224)
const ccColor3B ccLIGHTYELLOW={255,255,224};
//! Lime color (0,255,0)
const ccColor3B ccLIME={0,255,0};
//! LimeGreen color (50,205,50)
const ccColor3B ccLIMEGREEN={50,205,50};
//! Linen color (250,240,230)
const ccColor3B ccLINEN={250,240,230};
//! Maroon color (128,0,0)
const ccColor3B ccMAROON={128,0,0};
//! MediumAquaMarine color (102,205,170)
const ccColor3B ccMEDIUMAQUAMARINE={102,205,170};
//! MediumBlue color (0,0,205)
const ccColor3B ccMEDIUMBLUE={0,0,205};
//! MediumOrchid color (186,85,211)
const ccColor3B ccMEDIUMORCHID={186,85,211};
//! MediumPurple color (147,112,216)
const ccColor3B ccMEDIUMPURPLE={147,112,216};
//! MediumSeaGreen color (60,179,113)
const ccColor3B ccMEDIUMSEAGREEN={60,179,113};
//! MediumSlateBlue color (123,104,238)
const ccColor3B ccMEDIUMSLATEBLUE={123,104,238};
//! MediumSpringGreen color (0,250,154)
const ccColor3B ccMEDIUMSPRINGGREEN={0,250,154};
//! MediumTurquoise color (72,209,204)
const ccColor3B ccMEDIUMTURQUOISE={72,209,204};
//! MediumVioletRed color (199,21,133)
const ccColor3B ccMEDIUMVIOLETRED={199,21,133};
//! MidnightBlue color (25,25,112)
const ccColor3B ccMIDNIGHTBLUE={25,25,112};
//! MintCream color (245,255,250)
const ccColor3B ccMINTCREAM={245,255,250};
//! MistyRose color (255,228,225)
const ccColor3B ccMISTYROSE={255,228,225};
//! Moccasin color (255,228,181)
const ccColor3B ccMOCCASIN={255,228,181};
//! NavajoWhite color (255,222,173)
const ccColor3B ccNAVAJOWHITE={255,222,173};
//! Navy color (0,0,128)
const ccColor3B ccNAVY={0,0,128};
//! OldLace color (253,245,230)
const ccColor3B ccOLDLACE={253,245,230};
//! Olive color (128,128,0)
const ccColor3B ccOLIVE={128,128,0};
//! OliveDrab color (107,142,35)
const ccColor3B ccOLIVEDRAB={107,142,35};
//! OrangeRed color (255,69,0)
const ccColor3B ccORANGERED={255,69,0};
//! Orchid color (218,112,214)
const ccColor3B ccORCHID={218,112,214};
//! PaleGoldenRod color (238,232,170)
const ccColor3B ccPALEGOLDENROD={238,232,170};
//! PaleGreen color (152,251,152)
const ccColor3B ccPALEGREEN={152,251,152};
//! PaleTurquoise color (175,238,238)
const ccColor3B ccPALETURQUOISE={175,238,238};
//! PaleVioletRed color (216,112,147)
const ccColor3B ccPALEVIOLETRED={216,112,147};
//! PapayaWhip color (255,239,213)
const ccColor3B ccPAPAYAWHIP={255,239,213};
//! PeachPuff color (255,218,185)
const ccColor3B ccPEACHPUFF={255,218,185};
//! Peru color (205,133,63)
const ccColor3B ccPERU={205,133,63};
//! Pink color (255,192,203)
const ccColor3B ccPINK={255,192,203};
//! Plum color (221,160,221)
const ccColor3B ccPLUM={221,160,221};
//! PowderBlue color (176,224,230)
const ccColor3B ccPOWDERBLUE={176,224,230};
//! Purple color (128,0,128)
const ccColor3B ccPURPLE={128,0,128};
//! RosyBrown color (188,143,143)
const ccColor3B ccROSYBROWN={188,143,143};
//! RoyalBlue color (65,105,225)
const ccColor3B ccROYALBLUE={65,105,225};
//! SaddleBrown color (139,69,19)
const ccColor3B ccSADDLEBROWN={139,69,19};
//! Salmon color (250,128,114)
const ccColor3B ccSALMON={250,128,114};
//! SandyBrown color (244,164,96)
const ccColor3B ccSANDYBROWN={244,164,96};
//! SeaGreen color (46,139,87)
const ccColor3B ccSEAGREEN={46,139,87};
//! SeaShell color (255,245,238)
const ccColor3B ccSEASHELL={255,245,238};
//! Sienna color (160,82,45)
const ccColor3B ccSIENNA={160,82,45};
//! Silver color (192,192,192)
const ccColor3B ccSILVER={192,192,192};
//! SkyBlue color (135,206,235)
const ccColor3B ccSKYBLUE={135,206,235};
//! SlateBlue color (106,90,205)
const ccColor3B ccSLATEBLUE={106,90,205};
//! SlateGray color (112,128,144)
const ccColor3B ccSLATEGRAY={112,128,144};
//! Snow color (255,250,250)
const ccColor3B ccSNOW={255,250,250};
//! SpringGreen color (0,255,127)
const ccColor3B ccSPRINGGREEN={0,255,127};
//! SteelBlue color (70,130,180)
const ccColor3B ccSTEELBLUE={70,130,180};
//! Tan color (210,180,140)
const ccColor3B ccTAN={210,180,140};
//! Teal color (0,128,128)
const ccColor3B ccTEAL={0,128,128};
//! Thistle color (216,191,216)
const ccColor3B ccTHISTLE={216,191,216};
//! Tomato color (255,99,71)
const ccColor3B ccTOMATO={255,99,71};
//! Turquoise color (64,224,208)
const ccColor3B ccTURQUOISE={64,224,208};
//! Violet color (238,130,238)
const ccColor3B ccVIOLET={238,130,238};
//! Wheat color (245,222,179)
const ccColor3B ccWHEAT={245,222,179};
//! WhiteSmoke color (245,245,245)
const ccColor3B ccWHITESMOKE={245,245,245};
//! YellowGreen color (154,205,50)
const ccColor3B ccYELLOWGREEN={154,205,50};