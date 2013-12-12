//
//  particle_sprite.h
//  Legends
//
//  Created by David Zhang on 2013-12-12.
//
//

#import "cocos2d.h"
#import "GameObjSingleton.h"

@interface SkillAnimation : CCNode
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic, strong) CCParticleSystemQuad *particleOnTop;

+ (SkillAnimation *) SkillAnimation:(NSString *)name
                                TTL:(float)sec;

- (void) shootTo:(CGPoint)position duration:(float)seconds;
- (void) standStill:(CGPoint)position duration:(float)seconds;
@end
