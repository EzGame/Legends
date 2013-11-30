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
@property (nonatomic, strong)   NSMutableArray *areaOfRange;
@property (nonatomic, strong)   NSMutableArray *areaOfEffect;
@property (nonatomic)                   Action type;
@property (nonatomic)                      int range;

@end
