//
//  Buff.h
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (WeakReferences)

+ (id)mutableArrayUsingWeakReferences;
+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end

@class Buff;
@protocol BuffCasterDelegate <NSObject>
@required
- (void) buffCasterStarted:(Buff *)buff;
- (void) buffCasterFinished:(Buff *)buff;
@optional
@end
@protocol BuffTargetDelegate <NSObject>
@required
- (void) damage:(int)damage
           type:(int)type
       fromBuff:(Buff *)buff
     fromCaster:(id)caster;

- (void) buffTargetStarted:(Buff *)buff;
- (void) buffTargetFinished:(Buff *)buff;
@end

@interface Buff : NSObject
@property (nonatomic, weak) id<BuffCasterDelegate> caster;
@property (nonatomic, weak) id<BuffTargetDelegate> target;
@property (nonatomic) BOOL hasBuffBeenRemoved;
@property (nonatomic) int duration;

- (void) reset;
- (void) somethingChanged:(id)target;
- (void) removeMyBuff:(id)target;
@end

#pragma mark - Stone Gaze
@interface StoneGazeDebuff : Buff
@property (nonatomic, strong) NSMutableArray *path;

+ (id) stoneGazeDebuffFromCaster:(id)caster atTarget:(id)target withPath:(NSMutableArray *)path for:(int)duration;
@end

#pragma mark - Freeze
@interface FreezeDebuff : Buff

+ (id) freezeDebuffFromCaster:(id)caster atTarget:(id)target for:(int)duration;
@end

#pragma mark - Blaze
@interface BlazeDebuff : Buff
{
    @public
    int dmg;
}
@property (nonatomic, strong) NSMutableArray *targets;
+ (id) blazeDebuffFromCaster:(id)caster atTargets:(NSMutableArray *)targets for:(int)duration damage:(int)damage;
@end