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

@interface UnitObject : NSObject {
}
/* General Unit Properties */
@property (nonatomic)              UnitType type;
@property (nonatomic)                Rarity rarity;
@property (nonatomic)                   int moveSpeed;
@property (nonatomic)               CGPoint position;

/* Stat Properties */
@property (nonatomic, strong)   StatObject* stats;
@property (nonatomic, strong)   StatObject* augmentedStats;
@property (nonatomic)                 Heart heart;
@property (nonatomic)             Attribute highestAttribute;
@property (nonatomic)                   int augmentationCount;

- (id) initWithString:(NSString *)string;
@end
