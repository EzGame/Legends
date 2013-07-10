//
//  TestLayer.h
//  Legends
//
//  Created by David Zhang on 2013-06-17.
//
//

#import "cocos2d.h"
#import "Defines.h"
#import "MudGolem.h"
#import "Dragon.h"
#import "Unit.h"
#import "UnitDisplay.h"

@interface TestLayer : CCLayer <UnitDelegate>

@property (nonatomic, strong) Unit *unit;
@property (nonatomic, strong) UnitDisplay *display;
+ (CCScene *) scene;

@end
