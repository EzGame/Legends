//
//  BuffObject.h
//  Legends
//
//  Created by David Zhang on 2013-12-30.
//
//

#import "cocos2d.h"
#import "Constants.h"
#import "AttributesObject.h"
#import "CombatObject.h"

@class BuffObject;
@protocol BuffObjectDelegate <NSObject>
- (void) buffToBeRemoved:(BuffObject *)buff;
@end

@interface BuffObject : NSObject
@property (nonatomic)               id target;
@property (nonatomic, strong) CCSprite *icon;
@property (nonatomic)              int duration;

- (void) onBuffAdded:(AttributesObject *)obj;
- (void) onBuffRemoved:(AttributesObject *)obj;
- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj;
- (void) onReset;
@end

@interface GuardBuff : BuffObject
+ (id) guardBuff;

@end