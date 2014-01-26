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
@property (nonatomic)       BOOL isCrit;
@property (nonatomic)       BOOL isResist;

+ (id) combatObject;
@end
