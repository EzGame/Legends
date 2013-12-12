//
//  GeneralUtils.m
//  Legends
//
//  Created by David Zhang on 2013-08-22.
//
//

#import "GeneralUtils.h"
@implementation GeneralUtils

+ (UIImage *)convertToGrayscale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

+ (UIImage *) renderUIImageFromSprite:(CCSprite *)sprite
{
    int tx = sprite.contentSize.width;
    int ty = sprite.contentSize.height;
    
    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:tx height:ty];
    
    sprite.anchorPoint	= CGPointZero;
    
    [renderer begin];
    [sprite visit];
    [renderer end];
    
    return [renderer getUIImage];
}

+ (CCSprite *)convertSpriteToGrayscale:(CCSprite *)image
{
    UIImage* aUIImage = [GeneralUtils convertToGrayscale:[GeneralUtils renderUIImageFromSprite:image]];
        
    CGImageRef sourceImageRef = [aUIImage CGImage];
    
    CCSprite* aSprite = [CCSprite spriteWithCGImage:sourceImageRef key:@"aImageKey"];
    
    return aSprite;
}

#pragma mark - Math
+ (Direction) getDirection:(CGPoint)start to:(CGPoint)end
{
    CGPoint difference = ccpSub(start, end);
    if (difference.x > 0 ) return NW;
    else if (difference.x < 0 ) return SE;
    else if (difference.y > 0 ) return NE;
    else if (difference.y < 0 ) return SW;
    else return NE;
}

+ (int) getDistance:(CGPoint)start to:(CGPoint)end
{
    return abs(end.x - start.x) + abs(end.y - start.y);
}

+ (float) getAngle:(CGPoint)p1 :(CGPoint)p2
{
    float dx, dy, angle;
    
    dx = p2.x - p1.x;
    dy = p2.y - p1.y;
    angle = atan(dy / dx) * 180 / M_PI;
    return ( -angle < 0 )? -angle+180 : -angle;
}

+ (BOOL) ccColor3BCompare:(ccColor3B)color1 :(ccColor3B)color2;
{
    if ((color1.r == color2.r) &&
        (color1.g == color2.g) &&
        (color1.b == color2.b)){
        return YES;
    } else {
        return NO;
    }
}

+ (ccColor3B) darkenColor3B:(ccColor3B)color by:(float)factor
{
    return (ccColor3B){color.r*factor, color.g*factor, color.b*factor};
}

+ (ccColor3B) colorFromAction:(Action)action
{
    ccColor3B colour;
    // Find the colour to highlight ground
    switch ( action ) {
        case ActionMove: colour = ccAQUAMARINE;
            break;
        case ActionTeleport: colour = ccDODGERBLUE;
            break;
        case ActionSkillOne: colour = ccORANGE;
            break;
        case ActionSkillTwo: colour = ccRED;
            break;
        case ActionSkillThree: colour = ccMAROON;
            break;
        default: NSLog(@"Error! Unknown action occurred: %d", action);
            break;
    }
    return colour;
}


+ (ccColor3B) colorFromHeart:(Heart)heart
{
    ccColor3B colour;
    switch (heart) {
        case VoidHeart: colour          = ccWHITE; break;
        /* STR RED */
        case IronHeart: colour          = ccWHITE; break;
        case MuscleHeart: colour        = ccWHITE; break;
        case VindictiveHeart: colour    = ccWHITE; break;
        case BraveHeart: colour         = ccWHITE; break;
        /* AGI PURPLE */
        case NimbleHeart: colour        = ccWHITE; break;
        case JesterHeart: colour        = ccWHITE; break;
        case SilentHeart: colour        = ccWHITE; break;
        case SavageHeart: colour        = ccWHITE; break;
        /* INT BLUE */
        case CunningHeart: colour       = ccWHITE; break;
        case SageHeart: colour          = ccWHITE; break;
        case LogicalHeart: colour       = ccWHITE; break;
        case GiftedHeart: colour        = ccWHITE; break;
        /* SPR YELLOW */
        case DevoutHeart: colour        = ccWHITE; break;
        case SaintlyHeart: colour       = ccWHITE; break;
        case FaithfulHeart: colour      = ccWHITE; break;
        case HolyHeart: colour          = ccWHITE; break;
        /* HP GREEN */
        case RoyalHeart: colour         = ccWHITE; break;
        case TitanHeart: colour         = ccWHITE; break;
        case ThickHeart: colour         = ccWHITE; break;
        case UnholyHeart: colour        = ccWHITE; break;
        default: break;
    }
    return colour;
}

+ (ccColor3B) colorFromAttribute:(Attribute)attribute
{
    ccColor3B colour;
    switch (attribute) {
        case Strength: colour = ccRED; break;
        case Agility: colour = ccGREEN; break;
        case Intellect: colour = ccBLUE; break;
        case Spirit: colour = ccPURPLE; break;
        case Health: colour = ccYELLOW; break;
        default: break;
    }
    return colour;
}

#pragma mark - To String
+ (NSString *) stringFromType:(UnitType)type
{
    NSString *ret;
    if ( type == UnitTypePriest )
        ret = @"priest";
    else
        ret = @"Invalid type";
    return ret;
}

+ (NSString *) stringFromDirection:(Direction)direction
{
    NSString *ret;
    if ( direction == NE )      ret = @"NE";
    else if ( direction == NW ) ret = @"NW";
    else if ( direction == SE ) ret = @"SE";
    else if ( direction == SW ) ret = @"SW";
    return ret;
}

#pragma mark - Algorithms
+ (NSMutableArray *) getDiamondArea:(int)area
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = -area; i <= area; i++ ) {
        for ( int j = -area; j <= area; j++ ) {
            if ( !(!i && !j) && abs(i) + abs(j) <= area )
                [array addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    return array;
}

+ (NSMutableArray *)  getDiamondAreaWithMe:(int)area
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = -area; i <= area; i++ ) {
        for ( int j = -area; j <= area; j++ ) {
            if ( abs(i + j) <= area )
                [array addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    return array;
}

+ (NSMutableArray *) getOneArea
{
    return [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
}

#pragma mark - Animations
+ (void) tint:(CCSprite *)sprite with:(ccColor3B)color by:(int)factor
{
    id tintUp = [CCTintTo actionWithDuration:0.5
                                         red:MIN(color.r+factor,255)
                                       green:MIN(color.g+factor,255)
                                        blue:MIN(color.b+factor,255)
                 ];
    id tintDown = [CCTintTo actionWithDuration:0.5
                                           red:MAX(color.r-factor,0)
                                         green:MAX(color.g-factor,0)
                                          blue:MAX(color.b-factor,0)
                   ];
    id sequence = [CCSequence actionOne:tintUp two:tintDown];
    
    [sprite runAction:[CCRepeatForever actionWithAction:sequence]];
}
@end

