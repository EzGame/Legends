//
//  DamageObject.h
//  Legends
//
//  Created by David Zhang on 2013-12-02.
//
//

#import <Foundation/Foundation.h>

@interface DamageObject : NSObject
@property (nonatomic) int damage;
@property (nonatomic) int puredamage;

@property (nonatomic) int crushing;
@property (nonatomic) BOOL isCritical;
@property (nonatomic) BOOL isMissed;
@property (nonatomic) BOOL isResisted;

+ (id) damageWithDmg:(int)damage;
@end
