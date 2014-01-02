//
//  Witch.h
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "cocos2d.h"
#import "GameObjSingleton.h"

#import "Unit.h"
#import "UnitAction.h"
#import "UnitButton.h"

@interface Witch : Unit

+ (id) witch:(UnitObject *)object
     isOwned:(BOOL)owned;
@end
