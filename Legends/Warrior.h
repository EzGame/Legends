//
//  Warrior.h
//  Legends
//
//  Created by David Zhang on 2013-12-23.
//
//
#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"
#import "UnitSkill.h"

@interface Warrior : Unit

+ (id) warrior:(UnitObject *)object
       isOwned:(BOOL)owned;

@end
