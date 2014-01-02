//
//  ActionObject.h
//  Legends
//
//  Created by David Zhang on 2013-11-20.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"



@interface ActionObject : NSObject
@property (nonatomic)                   Action type;
@property (nonatomic)          ActionRangeType rangeType;
@property (nonatomic)                      int range;
@property (nonatomic)          ActionRangeType effectType;
@property (nonatomic)                      int effect;

// For RangeUnique
@property (nonatomic, strong)   NSMutableArray *areaOfRange;
@property (nonatomic, strong)   NSMutableArray *areaOfEffect;
@end
