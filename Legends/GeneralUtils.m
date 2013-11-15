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

//-(CCParticleSystem *) getParticleSystemForPDFile:(NSString*) plistFile
//{
//    if( NSMutableDictionary * dict = [particlesDict objectForKey:plistFile] )
//    {
//        NSMutableArray * arr = [dict objectForKey:@"particle_systems"];
//        
//        for(CCParticleSystemQuad * psq in arr)
//        {
//            if(!psq.particleCount)
//            {
//                //                printf("---- returning reused particle systemn");
//                //                printf("array count : %dn", [arr count]);
//                return psq;
//            }
//        }
//        
//        NSMutableDictionary * PDDict = [dict objectForKey:@"pd_dict"];
//        
//        //        printf("---- returning new particle system from existing dictionaryn");
//        //        printf("array count : %dn", [arr count]);
//        
//        CCParticleSystemQuad * emitter = [CCParticleSystemQuad particleWithDictionary:PDDict];
//        [arr addObject:emitter];
//        
//        return emitter;
//    }
//    
//    //    printf("---- creating new particle system for a new dictionaryn");
//    
//    NSMutableDictionary * newDict = [[NSMutableDictionary alloc] init];
//    
//    NSString *path = [CCFileUtils fullPathFromRelativePath:plistFile];
//    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
//    
//    [newDict setObject:dict forKey:@"pd_dict"];
//    
//    NSMutableArray * emitterArray = [[NSMutableArray alloc] initWithCapacity:5];
//    CCParticleSystemQuad * emitter = [CCParticleSystemQuad particleWithDictionary:dict];
//    [emitterArray addObject:emitter];
//    
//    [newDict setObject:emitterArray forKey:@"particle_systems"];
//    [emitterArray release];
//    
//    [particlesDict setObject:newDict forKey:plistFile];
//    [newDict release];
//    
//    return emitter;
//}

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
        case ActionMove: colour = ccDODGERBLUE;
            break;
        case ActionTeleport: colour = ccDODGERBLUE;
            break;
        case ActionMelee: colour = ccORANGE;
            break;
        case ActionHeal: colour = ccGREEN;
            break;
        case ActionRange: colour = ccORANGE;
            break;
        case ActionMagic: colour = ccORANGE;
            break;
        case ActionParalyze: colour = ccDARKCYAN;
            break;
        case ActionMeleeAOE: colour = ccORANGE;
            break;
        default: NSLog(@"Error! Unknown action occurred: %d", action);
            break;
    }
    return colour;
}

#pragma mark - Algorithms
+ (NSMutableArray *) getDiamond:(int)area
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = -area; i <= area; i++ ) {
        for ( int j = -area; j <= area; j++ ) {
            if ( !i && !j ) continue;
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
            [array addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    return array;
}

+ (NSMutableArray *) getOneArea
{
    return [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
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


@end

