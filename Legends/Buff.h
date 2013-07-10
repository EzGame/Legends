//
//  Buff.h
//  Legends
//
//  Created by David Zhang on 2013-06-13.
//
//

#import <Foundation/Foundation.h>

@implementation NSMutableArray (WeakReferences)
+ (id)mutableArrayUsingWeakReferences {
    return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // We create a weak reference array
    return (id)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
}
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
- (void) buffTargetStarted:(Buff *)buff;
- (void) buffTargetFinished:(Buff *)buff;
@end

@interface Buff : NSObject
@property (nonatomic, weak) id<BuffCasterDelegate> caster;
@property (nonatomic, weak) id<BuffTargetDelegate> target;
@property (nonatomic) BOOL hasBuffBeenRemoved;
@property (nonatomic) int duration;

- (void) turnEnd;
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
@property (nonatomic, strong) NSMutableArray *targets;
+ (id) blazeDebuffFromCaster:(id)caster atTargets:(NSMutableArray *)targets for:(int) duration;
@end