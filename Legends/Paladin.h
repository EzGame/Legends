//
//  Paladin.h
//  Legends
//
//  Created by David Zhang on 2014-01-11.
//
//

#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"

@interface Paladin : Unit

+ (id) paladin:(UnitObject *)object
      isOwned:(BOOL)owned;

@end
