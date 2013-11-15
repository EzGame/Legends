//
//  Constants.h
//  Legends
//
//  Created by David Zhang on 2013-11-13.
//
//

#ifndef Legends_Constants_h
#define Legends_Constants_h

#define GAMETILEWIDTH 64
#define GAMETILEHEIGHT 32
#define GAMETILEOFFSETX 353
#define GAMETILEOFFSETY 14

#define GAMEMAPWIDTH 11
#define GAMEMAPHEIGHT 11
#define LASTMAPWIDTH GAMEMAPWIDTH-1
#define LASTMAPHEIGHT GAMEMAPHEIGHT-1

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

typedef enum {
    NE,
    SE,
    SW,
    NW,
}Direction;

typedef enum {
    UnitTypeNone,
    UnitTypePriest,
}UnitType;

typedef enum {
    HighlightModeRange,
    HighlightModeEffect,
    HighlightModeOff,
}HighlightMode;

#endif
