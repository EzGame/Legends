//
//  UnitObject.h
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//


#import <Foundation/Foundation.h>
#import "Defines.h"
#import "GeneralUtils.h"
#import "StatObject.h"
#import "Constants.h"

#ifndef unitstats_h
#define unitstats_h
extern const int UNITSTATS[][3];
extern const int UNITSKILLS[][4];
#endif

@interface UnitObject : NSObject
/* General Unit Properties */
@property (nonatomic)                      UnitType type;
@property (nonatomic)                        Rarity rarity;
@property (nonatomic)                           int rank;
/* Game properties */
@property (nonatomic)                          BOOL isPositioned;
@property (nonatomic)                       CGPoint position;
/* Skill Properties */
@property (nonatomic, strong)        NSMutableArray *actionMove;
@property (nonatomic, strong)        NSMutableArray *actionSkillOne;
@property (nonatomic, strong)        NSMutableArray *actionSkillTwo;
@property (nonatomic, strong)        NSMutableArray *actionSkillThree;
/* Stat Properties */
@property (nonatomic, strong)            StatObject *stats;
/* Others */
@property (nonatomic, strong)   NSMutableDictionary *dict;
//@property (nonatomic)                 Heart heart;



+ (UnitObject *) createWithDict:(NSMutableDictionary *)dict;
//- (id) initWithString:(NSString *)string;
@end
