//
//  UnitButton.m
//  Legends
//
//  Created by David Zhang on 2013-11-07.
//
//

#import "UnitButton.h"

@implementation UnitButton
#pragma mark - Setters n Getters
//-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
//{
//    if( image != normalImage_ ) {
//        image.anchorPoint = CGPointZero;
//        
//        [self removeChild:normalImage_ cleanup:YES];
//        [self addChild:image];
//        
//        normalImage_ = image;
//        
//        [self setContentSize: [normalImage_ contentSize]];
//    }
//}
//
//-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
//{
//    if( image != selectedImage_ ) {
//        image.anchorPoint = CGPointZero;
//        
//        [self removeChild:selectedImage_ cleanup:YES];
//        [self addChild:image];
//        
//        selectedImage_ = image;
//    }
//}
//
//-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
//{
//    if( image != disabledImage_ ) {
//        image.anchorPoint = CGPointZero;
//        
//        [self removeChild:disabledImage_ cleanup:YES];
//        [self addChild:image];
//        
//        disabledImage_ = image;
//    }
//}

//-(void) setDisabledImage
//{
//    [normalImage_ setVisible:NO];
//    [selectedImage_ setVisible:NO];
//    [disabledImage_ setVisible:YES];
//}

//- (void) setOpacity: (GLubyte)opacity
//{
//    [normalImage_ setOpacity:opacity];
//    [selectedImage_ setOpacity:opacity];
//    [disabledImage_ setOpacity:opacity];
//}
//
//-(void) activate
//{
//    if( block_ )
//        block_(self);
//}
//
//-(void) setColor:(ccColor3B)color
//{
//    [normalImage_ setColor:color];
//    [selectedImage_ setColor:color];
//    [disabledImage_ setColor:color];
//}
//
//-(GLubyte) opacity
//{
//    return [normalImage_ opacity];
//}
//
//-(ccColor3B) color
//{
//    return [normalImage_ color];
//}
//
//-(void) setIsEnabled:(BOOL)enabled
//{
//    isEnabled_ = enabled;
//}

#pragma mark - Init n shit
+ (id) UnitButtonWithName:(NSString *)name CD:(int)CD MC:(int)MC target:(id)target selector:(SEL)selector
{
    return [[UnitButton alloc] initUnitButtonWithName:name
                                                   CD:CD
                                                   MC:MC
                                               target:target
                                             selector:selector];
}

- (id) initUnitButtonWithName:(NSString *)name CD:(int)CD MC:(int)MC target:(id)target selector:(SEL)selector
{
    CCSprite *buttonSprite = [CCSprite spriteWithFile:
                              [NSString stringWithFormat:@"button_%@.png",name]];

    self = [super initWithNormalSprite:buttonSprite
                        selectedSprite:nil
                        disabledSprite:nil
                                target:target
                              selector:selector];
    
    if ( self ) {
        _isUsed = NO;
        _buttonCD = CD;
        _buttonMC = MC;
        
        _displayCD = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _displayCD.anchorPoint = ccp(0.5, 0.5);
        _displayCD.position = ccp(10.0, 10.0);
        
        _displayMC = [CCLabelBMFont labelWithString:@"" fntFile:NORMALFONTSMALL];
        _displayMC.anchorPoint = ccp(0.5, 0.5);
        _displayMC.position = ccp(10.0,-10.0);
        
        [self addChild:_displayCD z:1];
        [self addChild:_displayMC z:1];
    }
    return self;
}

#pragma mark - Behaviour
-(void) selected
{
    [super selected];
    if( isEnabled_ ) {
        [self setScale:0.8];
        [normalImage_ setVisible:YES];
        [selectedImage_ setVisible:NO];
        [disabledImage_ setVisible:NO];
    }
}

-(void) unselected
{
    [self setScale:1.0];
    [super unselected];
    [normalImage_ setVisible:YES];
    [selectedImage_ setVisible:NO];
    [disabledImage_ setVisible:NO];
}

@end