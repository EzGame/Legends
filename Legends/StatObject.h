//
//  StatObject.h
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//

#import "Constants.h"

@interface StatObject : NSObject
@property (nonatomic) int strength;
@property (nonatomic) int agility;
@property (nonatomic) int intellect;
@property (nonatomic) int spirit;
@property (nonatomic) int health;

- (int) getStat:(Attribute)stat;
@end
