//
//  GameObjSingleton.m
//  Legends
//
//  Created by David Zhang on 2013-11-11.
//
//

#import "GameObjSingleton.h"
@interface GameObjSingleton()
@property (nonatomic, strong) NSMutableDictionary *particles;
@end

@implementation GameObjSingleton
static GameObjSingleton* _gameObjSingleton = nil;

#pragma mark - Init n shit
+ (GameObjSingleton *) get
{
    @synchronized([GameObjSingleton class])
    {
        if (!_gameObjSingleton)
            _gameObjSingleton = [[self alloc] init];
        return _gameObjSingleton;
    }
    NSLog(@">[ERROR]    Returning nil singleton!!!");
    return nil;
}

+ (id)alloc
{
	@synchronized([GameObjSingleton class])
	{
		NSAssert(_gameObjSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_gameObjSingleton = [super alloc];
		return _gameObjSingleton;
	}
    
	return nil;
}

- (id) init
{
    self = [super init];
    if ( self ) {
        [self initParticles];
    }
    return self;
}

- (void) initParticles
{
    _particles = [NSMutableDictionary dictionary];
    [self getParticleSystemForFile:@"heal_gain_effect.plist"];
    [self getParticleSystemForFile:@"priest_cast_effect.plist"];
    [self getParticleSystemForFile:@"bleed_effect.plist"];
    [self getParticleSystemForFile:@"fireball.plist"];
    
    [self getParticleSystemForFile:@"witch_wave_effect.plist"];
}

- (CCParticleSystemQuad *) getParticleSystemForFile:(NSString*) plistFile
{
    NSMutableDictionary *effect = [self.particles objectForKey:plistFile];
    if ( effect ) {
        NSMutableArray * arr = [effect objectForKey:@"instantiations"];

        for(CCParticleSystemQuad * psq in arr) {
            if( !psq.active ) {
                [psq resetSystem];
                if ( psq.parent ) {
                    [psq.parent removeChild:psq cleanup:NO];
                }
                return psq;
            }
        }

        NSMutableDictionary * plist = [effect objectForKey:@"plist"];

        CCParticleSystemQuad * emitter = [CCParticleSystemQuad particleWithDictionary:plist];
        [arr addObject:emitter];
        
        return emitter;
    }
    
    NSMutableDictionary *newEffect = [[NSMutableDictionary alloc] init];
    
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plistFile];
    NSDictionary *newPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    [newEffect setObject:newPlist forKey:@"plist"];
    
    NSMutableArray * emitterArray = [[NSMutableArray alloc] init];
    CCParticleSystemQuad * emitter = [CCParticleSystemQuad particleWithDictionary:newPlist];
    [emitterArray addObject:emitter];

    [newEffect setObject:emitterArray forKey:@"instantiations"];
    [self.particles setObject:newEffect forKey:plistFile];

    return emitter;
}
@end

#pragma mark - particleWithDictionary
@implementation CCParticleSystem (ParticleWithDictionary)
+ (id) particleWithDictionary:(NSDictionary *)dict
{
    return [[CCParticleSystemQuad alloc] initWithDictionary:dict];
}
@end
