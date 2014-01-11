//
//  Berserker.h
//  Legends
//
//  Created by David Zhang on 2014-01-11.
//
//
#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"

@interface Berserker : Unit

+ (id) berserker:(UnitObject *)object
         isOwned:(BOOL)owned;

@end
