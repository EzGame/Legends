//
//  GameObjSingleton.h
//  Legends
//
//  Created by David Zhang on 2013-11-11.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameObjSingleton : NSObject

+ (GameObjSingleton *) get;
- (CCParticleSystemQuad *) getParticleSystemForFile:(NSString*) plistFile;

@end


@interface CCParticleSystem (ParticleWithDictionary)
+ (id) particleWithDictionary:(NSDictionary *)dict;
@end