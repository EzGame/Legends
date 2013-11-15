//
//  GeneralUtils.h
//  Legends
//
//  Created by David Zhang on 2013-08-22.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Defines.h"
#import "Constants.h"

@interface GeneralUtils : NSObject

/*  To string  */
+ (NSString *) stringFromType:(UnitType)type;
+ (NSString *) stringFromDirection:(Direction)direction;

//+ (NSString *) stringFromAction:(Action)action;

/*  Image Manipulation */
+ (UIImage *)   convertToGrayscale:(UIImage *)image;
+ (UIImage *)   renderUIImageFromSprite:(CCSprite *)sprite;
+ (CCSprite *)  convertSpriteToGrayscale:(CCSprite *)image;

/*  Math  */
+ (float)       getAngle:(CGPoint)p1 :(CGPoint)p2;
+ (Direction)   getDirection:(CGPoint)start to:(CGPoint)end;

/*  Color  */
+ (BOOL)        ccColor3BCompare:(ccColor3B)color1 :(ccColor3B)color2;
+ (ccColor3B)   darkenColor3B:(ccColor3B) color by:(float)factor;
+ (ccColor3B)   colorFromAction:(Action)action;

/* Algorithms */
+ (NSMutableArray *) getDiamondArea:(int)area;
+ (NSMutableArray *) getDiamondAreaWithMe:(int)area;
+ (NSMutableArray *) getOneArea;

@end
