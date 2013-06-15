//
//  MenuItemSprite.m
//  Legends
//
//  Created by David Zhang on 2013-02-05.
//
//

#import "MenuItemSprite.h"

@implementation MenuItemSprite : CCMenuItem
@synthesize normalImage=normalImage_, selectedImage=selectedImage_, disabledImage=disabledImage_;

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector];
}

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:^(id sender) {
		[t performSelector:selector withObject:sender];
	} ];
#pragma clang diagnostic pop
}

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	if ( (self = [super initWithBlock:block] ) ) {
        
		self.normalImage = normalSprite;
		self.selectedImage = selectedSprite;
		self.disabledImage = disabledSprite;
        
		[self setContentSize: [normalImage_ contentSize]];
	}
	return self;
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) {
		image.anchorPoint = CGPointZero;
        
		[self removeChild:normalImage_ cleanup:YES];
		[self addChild:image];
        
		normalImage_ = image;
        
        [self setContentSize: [normalImage_ contentSize]];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ ) {
		image.anchorPoint = CGPointZero;

		[self removeChild:selectedImage_ cleanup:YES];
		[self addChild:image];
        
		selectedImage_ = image;
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ ) {
		image.anchorPoint = CGPointZero;
        
		[self removeChild:disabledImage_ cleanup:YES];
		[self addChild:image];
        
		disabledImage_ = image;
    }
}

-(void) selected
{
	[super selected];
    [self activate];
	if( selectedImage_ && isEnabled_ ) {
        [self setScale:0.775];
		[normalImage_ setVisible:NO];
		[selectedImage_ setVisible:YES];
		[disabledImage_ setVisible:NO];
    }
}

-(void) unselected
{
	[super unselected];
    [self setScale:1];
	[normalImage_ setVisible:YES];
	[selectedImage_ setVisible:NO];
	[disabledImage_ setVisible:NO];
}

-(void) setDisabledImage
{
    [normalImage_ setVisible:NO];
    [selectedImage_ setVisible:NO];
    [disabledImage_ setVisible:YES];
}

- (void) setOpacity: (GLubyte)opacity
{
	[normalImage_ setOpacity:opacity];
	[selectedImage_ setOpacity:opacity];
	[disabledImage_ setOpacity:opacity];
}

-(void) activate
{
    if( block_ )
		block_(self);
}

-(void) setColor:(ccColor3B)color
{
	[normalImage_ setColor:color];
	[selectedImage_ setColor:color];
	[disabledImage_ setColor:color];
}

-(GLubyte) opacity
{
	return [normalImage_ opacity];
}

-(ccColor3B) color
{
	return [normalImage_ color];
}

-(void) setIsEnabled:(BOOL)enabled
{
    isEnabled_ = enabled;
}
@end

