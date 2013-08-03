//
//  Objects.m
//  Legends
//
//  Created by David Zhang on 2013-07-18.
//
//

#import "Objects.h"

@implementation StatObj
@synthesize strength = _strength, agility = _agility, intelligence = _intelligence;
+ (id) statsWithStr:(int)str Agi:(int)agi Int:(int)inte Hp:(int)hp
{
    return [[StatObj alloc] initWithStr:str Agi:agi Int:inte Hp:hp];
}

- (id) initWithStr:(int)str Agi:(int)agi Int:(int)inte Hp:(int)hp;
{
    self = [super init];
    if ( self ) {
        _strength = str;
        _agility = agi;
        _intelligence = inte;
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%d/%d",
            self.strength, self.agility, self.intelligence, self.health];
}
@end

@implementation UnitObj
@synthesize type = _type, experience = _experience, position = _position;
@synthesize upgrades = _upgrades, stats = _stats;

+ (id) unitObjWithString:(NSString *)string
{
    return [[UnitObj alloc] initWithString:string];
}

- (id) initWithString:(NSString *)string
{
    self = [super init];
    if ( self ) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        _type = [[tokens objectAtIndex:0] integerValue];
        _experience = [[tokens objectAtIndex:1] integerValue];
        _stats = [StatObj statsWithStr:[[tokens objectAtIndex:2] integerValue]
                                   Agi:[[tokens objectAtIndex:3] integerValue]
                                   Int:[[tokens objectAtIndex:4] integerValue]
                                    Hp:[[tokens objectAtIndex:5] integerValue]];
        _upgrades = [[[tokens objectAtIndex:6] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] mutableCopy];
        _position = CGPointFromString ([tokens objectAtIndex:7]);
        NSLog(@">[MYLOG]    Created Unit Object:\n%@",self);
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%@/%@/%@",
            self.type, self.experience, self.stats,
            self.upgrades, NSStringFromCGPoint(self.position)];
}
@end

@implementation ScrollObj
@synthesize type = _type, experience = _experience;
@synthesize stats = _stats;

+ (id) scrollObjWithString:(NSString *)string
{
    return [[ScrollObj alloc] initWithString:string];
}

- (id) initWithString:(NSString *)string
{
    self = [super init];
    if ( self ) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        _type = [[tokens objectAtIndex:0] integerValue];
        _experience = [[tokens objectAtIndex:1] integerValue];
        _stats = [StatObj statsWithStr:[[tokens objectAtIndex:2] integerValue]
                                   Agi:[[tokens objectAtIndex:3] integerValue]
                                   Int:[[tokens objectAtIndex:4] integerValue]
                                    Hp:[[tokens objectAtIndex:5] integerValue]];
        NSLog(@">[MYLOG]    Created Scroll Object:\n%@", self);
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%d/%d/%@",
            self.type, self.experience, self.stats];
}
@end
