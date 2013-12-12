//
//  ActionObject.h
//  Legends
//
//  Created by David Zhang on 2013-11-20.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

typedef enum {
    RangeNormal,
    RangePathFind,
    RangeAllied,
    RangeEnemy,
} ActionRangeType;

@interface ActionObject : NSObject
@property (nonatomic)                   Action type;
@property (nonatomic)          ActionRangeType rangeType;
@property (nonatomic, strong)   NSMutableArray *areaOfRange;
@property (nonatomic, strong)   NSMutableArray *areaOfEffect;
@property (nonatomic)                      int range;

@end
