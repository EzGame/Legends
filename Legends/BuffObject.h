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

/* 
 * Buff object run sequence:
 * Caster creates buff object with a <target>
 * Caster calls [start]
 * [start] calls [self.target add:self];
 * <target> addes buff to buff list
 * <target> calls [buff added];
 * [buff added] calls [self.target addedAnimation];
 */

@class BuffObject;
@protocol BuffObjectDelegate <NSObject>
- (void) buffNeedsToBeAdded:(BuffObject *)buff;
- (void) buffNeedsToBeRemoved:(BuffObject *)buff;
- (void) buffAnimationAdded:(BuffObject *)buff;
- (void) buffAnimationInvoked:(BuffObject *)buff;
- (void) buffAnimationRemoved:(BuffObject *)buff;
@end

@interface BuffObject : NSObject
@property (nonatomic, assign)       id target;
@property (nonatomic, strong) CCSprite *icon;
@property (nonatomic)              int duration;

- (void) onBuffAdded:(AttributesObject *)obj;
- (void) onBuffRemoved:(AttributesObject *)obj;
- (void) onBuffInvoke:(BuffEvent)event obj:(CombatObject *)obj;
- (void) onReset;

- (void) start;
@end

@interface GuardBuff : BuffObject
+ (id) guardBuffTarget:(id)target;
@end

@interface RageBuff : BuffObject
+ (id) rageBuffTarget:(id)target;
@end

@interface ShieldBuff : BuffObject
@property (nonatomic) int amount;
+ (id) shieldBuffTarget:(id)target amount:(int)amount;
@end