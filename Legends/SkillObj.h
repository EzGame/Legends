//
//  SkillObj.h
//  Legends
//
//  Created by David Zhang on 2013-09-25.
//
//

#import "Defines.h"

@interface CombatObj : NSObject
@property (nonatomic) CGPoint target;
@property (nonatomic) int damage;
@property (nonatomic) int damageType;

/*
 @property (nonatomic) int damage;
 @property (nonatomic) int skillType;
 @property (nonatomic) int skillDamageType;
 @property (nonatomic) BOOL isCrit;
 @property (nonatomic) BOOL isStun;
 @property (nonatomic, copy) int (^calculateDamageBlock)(int damage);
 
 + (id) damageObjWith:(int)damage;
 */
@end

@class SkillObj;
@protocol SkillObjDelegate <NSObject>
- (NSMutableArray *) skillObjDelegate:(SkillObj *)skill target:(CGPoint)target;

@end
@interface SkillObj : NSObject

@property (nonatomic, assign) id delegate;
@property (nonatomic) Action skillType;
@property (nonatomic, strong) NSMutableArray *skillRange;
@property (nonatomic, strong) NSMutableArray *skillEffect;
@property (nonatomic) int skillRank;
@property (nonatomic) int skillCost;

- (void) getSkillEffectForTarget:(CGPoint)target;
@end


@interface MoveSkillObj : SkillObj
@property (nonatomic) int moveSkillRange;

- (id) initWithRange:(int)range;
@end
// custom move object
