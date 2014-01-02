//
//  CombatObject.h
//  Legends
//
//  Created by David Zhang on 2014-01-02.
//
//

#import "Constants.h"

@interface CombatObject : NSObject
@property (nonatomic) CombatType type;
@property (nonatomic)        int amount;

// unused yet
@property (nonatomic) int crushingAmount;
@property (nonatomic) int critAmount;
@property (nonatomic) BOOL isMissed;
@property (nonatomic) BOOL isResisted;

+ (id) combatObject;
@end
