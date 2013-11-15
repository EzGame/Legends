//
//  Buff.h
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface NSMutableArray (WeakReferences)

+ (id)mutableArrayUsingWeakReferences;
+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end


#pragma mark - Buff
@class Buff; @class Unit; @class Tile;
@protocol BuffCasterDelegate <NSObject>
    @required
    - (void) buffCasterStarted:(Buff *)buff;
    - (void) buffCasterFinished:(Buff *)buff;
@end
@protocol BuffTargetDelegate <NSObject>
    @required
    - (void) buffTargetStarted:(Buff *)buff;
    - (void) buffTargetFinished:(Buff *)buff;
@end

@interface Buff : NSObject
@property (nonatomic, weak) id<BuffTargetDelegate>  target;
@property (nonatomic)       int                     duration;

- (BOOL) buffEffectOnEvent:(Event)event forUnit:(Unit *)unit;
- (BOOL) buffEffectOnEvent:(Event)event forTile:(Tile *)tile;
- (void) start;
- (void) stop;
@end


#pragma mark - Freeze
@interface FreezeBuff : Buff
+ (id) freezeBuffAtTarget:(id)target for:(int)duration;
@end


#pragma mark - Blaze
@interface BlazeBuff : Buff
@property (nonatomic) int damage;
+ (id) blazeBuffAtTarget:(id)target for:(int)duration damage:(int)damage;
@end


#pragma mark - Paralyze buff
@interface ParalyzeBuff : Buff
@property (nonatomic, weak) id<BuffCasterDelegate>  caster;
+ (id) paralyzeBuffFromCaster:(id)caster atTarget:(id)target;
@end


#pragma mark - Shield Buff
@interface ShieldBuff : Buff
@property (nonatomic, weak) id<BuffCasterDelegate>  caster;
+ (id) shieldBuffFromCaster:(id)caster atTarget:(id)target;
@end