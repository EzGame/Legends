//
//  Ranger.h
//  Legends
//
//  Created by David Zhang on 2013-12-23.
//
//
#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"

@interface Ranger : Unit

+ (id) ranger:(UnitObject *)object
      isOwned:(BOOL)owned;
@end
