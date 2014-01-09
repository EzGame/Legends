//
//  Knight.h
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//
#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"

@interface Knight : Unit

+ (id) knight:(UnitObject *)object
      isOwned:(BOOL)owned;

@end
