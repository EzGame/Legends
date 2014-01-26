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
const int UNITSTATS[12][3] =
{
    {0, 2, 4},      // Priest
    {1, 0, 1},      // Priest Move
    {3, 10, 2},     // Priest Heal
    {1, 4, 1},      // Ranger
    {1, 0, 1},      // Ranger Move
    {1, 5, 1},      // Ranger shoot
    {5, 1, 0},      // Warrior
    {0, 0, 1},      // Warrior Move
    {1, 3, 1},      // Warrior Slash
    {0, 0, 6},      // Witch
    {1, 0, 1},      // Witch Move
    {2, 10, 2},     // Witch Wave
};
#endif

@interface GameObjSingleton : NSObject

+ (GameObjSingleton *) get;
- (CCParticleSystemQuad *) getParticleSystemForFile:(NSString*) plistFile;

@end


@interface CCParticleSystem (ParticleWithDictionary)
+ (id) particleWithDictionary:(NSDictionary *)dict;
@end