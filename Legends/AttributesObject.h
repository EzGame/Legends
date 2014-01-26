/////////////////////////////////////////////
//  Attributes.h
//  Legends
//
//  Created by David Zhang on 2013-08-08.
//
/////////////////////////////////////////////

#pragma mark - Imports
/* Global and Singletons */
#import "Constants.h"
#import "UserSingleton.h"
/* Data Objects */
#import "StatObject.h"
#import "CombatObject.h"

@interface AttributesObject : NSObject
@property (nonatomic, weak, readonly) StatObject* stats;

// Primary stat
@property (nonatomic)                         int strength;
@property (nonatomic)                         int agility;
@property (nonatomic)                         int intellect;

// Secondary stats
//STR -> INT
@property (nonatomic)                       float meleeCrit;            //[a] 1*INT + 2*STR
@property (nonatomic)                       float meleeResist;           //[d] 2*INT + 1*STR
//STR -> AGI
@property (nonatomic)                       float meleeDefense;         //[d] 1*AGI + 2*STR
@property (nonatomic)                       float meleePierce;          //[a] 2*AGI + 1*STR

//AGI -> STR
@property (nonatomic)                       float rangeCrit;            //[a] 1*STR + 2*AGI
@property (nonatomic)                       float rangeResist;           //[d] 2*STR + 1*AGI
//AGI -> INT
@property (nonatomic)                       float rangeDefense;         //[d] 1*INT + 2*AGI
@property (nonatomic)                       float rangePierce;          //[a] 2*INT + 1*AGI

//INT -> AGI
@property (nonatomic)                       float spellCrit;            //[a] 1*AGI + 2*INT
@property (nonatomic)                       float spellResist;           //[d] 2*AGI + 1*INT
//INT -> STR
@property (nonatomic)                       float spellDefense;         //[d] 1*STR + 2*INT
@property (nonatomic)                       float spellPierce;          //[a] 2*STR + 1*INT

// Tertiary Stats
@property (nonatomic)                         int health;
@property (nonatomic)                         int experience;
@property (nonatomic)                         int mana;


+ (id) attributesWithObject:(StatObject *)stats
                    augment:(StatObject *)augmentation;

- (void) attackerCalculation:(CombatObject *)obj;
- (void) defenderCalculation:(CombatObject *)obj;

@end