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
#import "UnitAction.h"
#import "UnitButton.h"

@interface Warrior : Unit

+ (id) warrior:(UnitObject *)object
       isOwned:(BOOL)owned;

@end
