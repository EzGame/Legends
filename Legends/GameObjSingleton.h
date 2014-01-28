//
//  GameObjSingleton.h
//  Legends
//
//  Created by David Zhang on 2013-11-11.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#ifndef unitstats_h
#define unitstats_h
extern const int UNITSTATS[12][3];
#endif

@interface GameObjSingleton : NSObject

+ (GameObjSingleton *) get;
- (CCParticleSystemQuad *) getParticleSystemForFile:(NSString*) plistFile;

@end


@interface CCParticleSystem (ParticleWithDictionary)
+ (id) particleWithDictionary:(NSDictionary *)dict;
@end