//
//  Objects.h
//  Legends
//
//  Created by David Zhang on 2013-07-18.
//
//

#import <Foundation/Foundation.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
// @"1/500/0/0/0/0/-1/0,3",
// @"1/50/str:10",


@interface StatObj : NSObject
@property (nonatomic) int strength;
@property (nonatomic) int agility;
@property (nonatomic) int intelligence;
@property (nonatomic) int health;
+ (id) statsWithStr:(int)str Agi:(int)agi Int:(int)inte Hp:(int)hp;
- (id) initWithStr:(int)str Agi:(int)agi Int:(int)inte Hp:(int)hp;
@end

@interface UnitObj : NSObject
@property (nonatomic) int type;
@property (nonatomic) int experience;
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) NSMutableArray *upgrades;
@property (nonatomic, strong) StatObj *stats;

+ (id) unitObjWithString:(NSString *)string;

@end

@interface ScrollObj : NSObject
@property (nonatomic) int type;
@property (nonatomic) int experience;
@property (nonatomic, strong) StatObj *stats;

+ (id) scrollObjWithString:(NSString *)string;
@end