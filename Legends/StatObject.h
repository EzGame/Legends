//
//  StatObject.h
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "Constants.h"

@interface StatObject : NSObject
@property (nonatomic) Attribute strength;
@property (nonatomic) Attribute agility;
@property (nonatomic) Attribute intellect;
@property (nonatomic) Attribute *highestAttribute;
@end
