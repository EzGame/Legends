//
//  MenuItem.h
//  Legends
//
//  Created by David Zhang on 2013-02-05.
//
//  Custom Menu items and their behaviour

#import "CCMenuItem.h"
#import "cocos2d.h"

/* Code copied from CCMenuItemSprite */
@interface MenuItemSprite : CCMenuItem <CCRGBAProtocol>
{
	CCNode<CCRGBAProtocol> *__unsafe_unretained normalImage_, *__unsafe_unretained selectedImage_, *__unsafe_unretained disabledImage_;
}

// weak references

@property (nonatomic,readwrite) int costOfButton;
/** the image used when the item is not selected */
@property (nonatomic,readwrite,unsafe_unretained) CCNode<CCRGBAProtocol> *normalImage;
/** the image used when the item is selected */
@property (nonatomic,readwrite,unsafe_unretained) CCNode<CCRGBAProtocol> *selectedImage;
/** the image used when the item is disabled */
@property (nonatomic,readwrite,unsafe_unretained) CCNode<CCRGBAProtocol> *disabledImage;/** creates a menu item with a normal,selected  and disabled image with target/selector.
 The "target" won't be retained.
 */
@property (nonatomic, readwrite) BOOL isUsed;

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block;

- (void) setDisabledImage;

@end