////
////  particle_sprite.m
////  Legends
////
////  Created by David Zhang on 2013-12-12.
////
////
//
//#import "particle_sprite.h"
//
//@implementation SkillAnimation
//
//+ (SkillAnimation *) SkillAnimation:(NSString *)name TTL:(float)sec
//{
//    return [[SkillAnimation alloc] initWithSkillAnimation:name TTL:sec];
//}
//
//- (id) initWithSkillAnimation:(NSString *)name TTL:(float)sec
//{
//    self = [super init];
//    if ( self )
//    {
//        NSString *sprite = [NSString stringWithFormat:@"%@.png",name];
//        NSString *particle = [NSString stringWithFormat:@"%@.plist",name];
//        _sprite = [CCSprite spriteWithFile:sprite];
//
//        _particleOnTop = [[GameObjSingleton get] getParticleSystemForFile:particle];
//        _particleOnTop.duration = sec;
//        
//    }
//    return self;
//}
//
//- (void) start
//{
//    // We add everything here and animate
//    [self addChild:self.sprite z:0];
//    if ( self.particleOnTop.parent )
//        [self.particleOnTop.parent removeChild:self.particleOnTop cleanup:NO];
//    
//    [self addChild:self.particleOnTop z:1];
//}
//
//- (void) shootTo:(CGPoint)position duration:(float)seconds
//{
//    // Start your engines
//    [self start];
//    
//    [self runAction:
//     [CCSequence actions:
//      [CCMoveTo actionWithDuration:seconds position:position],
//      [CCCallBlock actionWithBlock:^{
//         [self.parent removeChild:self cleanup:YES];
//     }], nil]];
//}
//@end
