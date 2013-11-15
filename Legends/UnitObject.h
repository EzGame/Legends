//
//  UnitObject.h
//  Legends
//
//  Created by David Zhang on 2013-10-18.
//
//


#import <Foundation/Foundation.h>
#import "Defines.h"
#import "GeneralUtils.h"
#import "StatObject.h"

//enum Type {
//    UnitTypeNone,
//    UnitTypePriest,
//    LAST_UNIT = UnitTypePriest,
//}typedef UnitType;

enum Rarity {
    Vagrant,
    Common,
    Uncommon,
    Rare,
    Epic,
    LAST_RARITY = Epic,
}typedef Rarity;

enum Heart { // no hp implementation (20 -> 12)
    Void,       // nothing
    
    Iron,       // +str -agi        [done]
    Muscle,     // +str -int        [done]
    Vindictive, // +str -spr        [done]
    Brave,      // +str -hp         [done]
    
    Nimble,     // +agi -str        [done]
    Jester,     // +agi -int        [done]
    Silent,     // +agi -spr //Dark? assassin
    Savage,     // +agi -hp
    
    Cunning,    // +int -str
    Sage,       // +int -agility
    Logical,    // +int -spr        [done]
    Gifted,     // +int -hp
    
    Devout,     // +spr -str
    Saintly,    // +spr -agi
    Faithful,   // +spr -int        [done]
    Holy,       // +spr -hp         [done]
    
    Royal,      // +hp  -str        [done]
    Titan,      // +hp  -agi        [done]
    Thick,      // +hp  -int        [done]
    Unholy,     // +hp  -spr        [done]
}typedef Heart;

@interface UnitObject : NSObject
{
    @private
    int levelup_str;
    int levelup_agi;
    int levelup_int;
    int levelup_spr;
    int levelup_hp;
    @public
    Rarity rarity;
    //int max_level;
}
//@property (nonatomic, strong)  SkillObject* skills;

@property (nonatomic, strong)   StatObject* stats;

@property (nonatomic)              UnitType type;
@property (nonatomic)                 Heart heart;
@property (nonatomic)                   int experience;
@property (nonatomic)                   int level;
@property (nonatomic)                   int moveSpeed;
@property (nonatomic)               CGPoint position;


- (id) initWithString:(NSString *)string;
@end
